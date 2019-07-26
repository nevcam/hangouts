//
//  MapViewController.m
//  hangouts
//
//  Created by josemurillo on 7/17/19.
//  Copyright © 2019 nev. All rights reserved.
//

#import "MapViewController.h"
#import <MapKit/MapKit.h>
#import "Parse/Parse.h"
#import "UserXEvent.h"
#import "Event.h"
#import "Friendship.h"
#import "UIImageView+AFNetworking.h"

@interface MapViewController () <MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@end

@implementation MapViewController {
    NSMutableArray* _friendUsers;
    NSMutableArray *_friendships;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.mapView.delegate = self;
    [self fetchEventPointers];
    
    self->locationManager = [[CLLocationManager alloc] init];
    self->locationManager.delegate = self;
    self->locationManager.distanceFilter = kCLDistanceFilterNone;
    self->locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0 &&
        [CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorizedWhenInUse
        //[CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorizedAlways
        ) {
        // Will open an confirm dialog to get user's approval
        [self->locationManager requestWhenInUseAuthorization];
//        [self->locationManager requestAlwaysAuthorization];
    } else {
        [self->locationManager startUpdatingLocation]; //Will update location immediately
    }
    [self fetchFriendsLocations];
}

- (void)fetchFriendsLocations {
    PFQuery *query = [Friendship query];
    [query orderByDescending:@"createdAt"];
    [query includeKey:@"user"];
    [query whereKey:@"user" equalTo:[PFUser currentUser]];
    query.limit = 1;
    
    __weak typeof(self) weakSelf = self;
    [query findObjectsInBackgroundWithBlock:^(NSArray<Friendship *> * _Nullable friendships, NSError * _Nullable error) {
        if (friendships) {
            NSMutableArray *friendPointers = (NSMutableArray *)friendships[0][@"friends"];
            NSMutableArray *friendIds = [NSMutableArray new];
            for (PFUser *friendPointer in friendPointers) {
                [friendIds addObject:friendPointer.objectId];
            }
            PFQuery *query = [PFUser query];
            [query orderByDescending:@"createdAt"];
            [query whereKey:@"objectId" containedIn:friendIds];
            
            [query findObjectsInBackgroundWithBlock:^(NSArray<PFUser *> * _Nullable users, NSError * _Nullable error) {
                if (users) {
                    __strong typeof(self) strongSelf = weakSelf;
                    if (!strongSelf->_friendships) {
                        strongSelf->_friendships = [NSMutableArray new];
                        strongSelf->_friendUsers = [NSMutableArray new];
                        
                        [strongSelf->_friendships addObjectsFromArray:users];
                        
                        if (strongSelf->_friendships.count == friendPointers.count) {
                            strongSelf->_friendUsers = strongSelf->_friendships;
                            [self annotationFriends];
                        }
                    } else {
                        NSLog(@"Error");
                    }
                } else {
                    NSLog(@"Error: %@", error.localizedDescription);
                }
            }];
        } else {
            NSLog(@"Error: %@", error.localizedDescription);
        }
    }];
}

- (void)annotationFriends {
    for (PFUser *friend in self->_friendUsers){
        CLLocationCoordinate2D coordinate;
        NSNumber *latitude = friend[@"latitude"];
        NSNumber *longitude = friend[@"longitude"];
        coordinate.latitude = latitude.floatValue;
        coordinate.longitude = longitude.floatValue;
        MKPointAnnotation *myAnnotation = [[MKPointAnnotation alloc] init];
        myAnnotation.coordinate = coordinate;
        myAnnotation.title = friend[@"username"];
        [self.mapView addAnnotation:myAnnotation];
    }
}

//- (MKAnnotationView *)mapView:(MKMapView *)map viewForAnnotation:(id <MKAnnotation>)annotation {
//    static NSString *AnnotationViewID = @"annotationView";
//
//    MKAnnotationView *annotationView = (MKAnnotationView *)[self.mapView dequeueReusableAnnotationViewWithIdentifier:AnnotationViewID];
//
//    if (annotationView == nil){
//        annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:AnnotationViewID];
//    }
////    PFFileObject *imageFile = [PFUser currentUser][@"profilePhoto"];
////    NSURL *profilePhotoURL = [NSURL URLWithString:imageFile.url];
//
////    annotationView.image = [UIImage imageNamed:@"dog.png"];
////    [annotationView.image setImageWithURL:profilePhotoURL];
//    annotationView.annotation = annotation;
//
//    return annotationView;
//}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    NSLog(@"last location %@", [locations lastObject]);
    NSLog(@"locations %@", locations);

    self->currentLocation = [locations objectAtIndex:0];
    [self->locationManager stopUpdatingLocation];
    CLGeocoder *geocoder = [[CLGeocoder alloc] init] ;
    [geocoder reverseGeocodeLocation:self->currentLocation completionHandler:^(NSArray *placemarks, NSError *error)
     {
         if (!(error))
         {
             CLPlacemark *placemark = [placemarks objectAtIndex:0];
             NSLog(@"\nCurrent Location Detected\n");
             NSLog(@"placemark %@",placemark);
             /*
             NSString *Area = [[NSString alloc]initWithString:placemark.locality];
             NSString *Country = [[NSString alloc]initWithString:placemark.country];
             NSString *CountryArea = [NSString stringWithFormat:@"%@, %@", Area,Country];
             NSLog(@"%@",CountryArea);
             NSLog(@"%@",placemark.region);
             NSLog(@"%@",placemark.country);
             NSLog(@"%@",placemark.locality);
             NSLog(@"%@",placemark.name);
             NSLog(@"%@",placemark.postalCode);
             NSLog(@"%@",placemark.location);
             */
             self->centre.latitude = self->currentLocation.coordinate.latitude;    // getting latitude
             self->centre.longitude = self->currentLocation.coordinate.longitude;  // getting longitude
             PFUser *user = [PFUser currentUser];
             NSNumber *lat = [NSNumber numberWithDouble:placemark.location.coordinate.latitude];
             NSNumber *lon =[NSNumber numberWithDouble:placemark.location.coordinate.longitude];
             user[@"latitude"] = lat;
             user[@"longitude"] = lon;
             [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                 if (!error) {
                 } else {
                 }
             }];
             MKCoordinateRegion adjustedRegion = [self.mapView regionThatFits:MKCoordinateRegionMakeWithDistance(self->centre, 600, 600)];
             [self.mapView setRegion:adjustedRegion animated:YES];
         }
         else
         {
             NSLog(@"Geocode failed with error %@", error);
             NSLog(@"\nCurrent Location Not Detected\n");
         }
     }];
}

// location authorization status
- (void)locationManager:(CLLocationManager*)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    switch (status) {
        case kCLAuthorizationStatusNotDetermined: {
            NSLog(@"User still thinking..");
        } break;
        case kCLAuthorizationStatusDenied: {
        } break;
        case kCLAuthorizationStatusAuthorizedWhenInUse:
        case kCLAuthorizationStatusAuthorizedAlways: {
            [self->locationManager startUpdatingLocation]; //Will update location immediately
        } break;
        default:
            break;
    }
}

// Makes request for locations of accepted events to add respective pointers in the map
- (void)fetchEventPointers {
    PFQuery *userXEventQuery = [UserXEvent query];
    [userXEventQuery whereKey:@"user" equalTo:[PFUser currentUser]];
    [userXEventQuery whereKey:@"type" containedIn:[NSArray arrayWithObjects: @"accepted", @"owned", nil]];
    [userXEventQuery includeKey:@"event"];
    [userXEventQuery selectKeys:[NSArray arrayWithObject:@"event"]];
    
    [userXEventQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable events, NSError * _Nullable error) {
        if (events) {
            for (UserXEvent *addEvent in events) {
                [self getLocationPoint:addEvent.event.location_lat longitude:addEvent.event.location_lng];
            }
        } else {
            NSLog(@"Error getting events: %@", error.localizedDescription);
        }
    }];
}

// Creates a pointer im the map
- (void)getLocationPoint:(NSNumber *)latitude longitude:(NSNumber *)longitude {
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(latitude.floatValue, longitude.floatValue);
    
    MKPointAnnotation *annotation = [MKPointAnnotation new];
    annotation.coordinate = coordinate;
    annotation.title = @"Event!";
    [self.mapView addAnnotation:annotation];
}

// Allows user to create an event
- (IBAction)clickedAddEvent:(id)sender {
    [self performSegueWithIdentifier:@"addEventSegue" sender:nil];
}

// Segue to present modally "Add Event" view controller
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
}

@end
