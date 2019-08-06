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
#import "CustomPointAnnotation.h"
#import "EventPointAnnotation.h"
#import "UIImageView+AFNetworking.h"
#import "PersonDetailMapView.h"
#import "AddEventViewController.h"
#import "DateFormatterManager.h"
#import "CustomAnnotationButton.h"
#import "EventTabBarController.h"
#import "EventDetailsViewController.h"

@interface MapViewController () <MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
//@property (strong, nonatomic) PersonDetailMapView *customCalloutView;

@end

@implementation MapViewController {
    NSMutableArray *_friendUsers;
    NSMutableArray *_friendships;
    NSMutableArray *_events;
    NSMutableArray *_selectedFriends;
    
//    UIView *_customCalloutView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.mapView.delegate = self;
    _selectedFriends = [NSMutableArray new];
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
    [self fetchEventPointers];
    [self fetchFriendsLocations];
}

#pragma mark - Updating current user location

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
//    NSLog(@"last location %@", [locations lastObject]);
    
    self->currentLocation = [locations objectAtIndex:0];
    [self->locationManager stopUpdatingLocation];
    CLGeocoder *geocoder = [[CLGeocoder alloc] init] ;
    [geocoder reverseGeocodeLocation:self->currentLocation completionHandler:^(NSArray *placemarks, NSError *error)
     {
         if (!(error))
         {
             CLPlacemark *placemark = [placemarks objectAtIndex:0];
             self->centre.latitude = self->currentLocation.coordinate.latitude;
             self->centre.longitude = self->currentLocation.coordinate.longitude;
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
             MKCoordinateRegion adjustedRegion = [self.mapView regionThatFits:MKCoordinateRegionMakeWithDistance(self->centre, 1500, 1500)];
             [self.mapView setRegion:adjustedRegion animated:YES];
         }
         else
         {
             NSLog(@"Geocode failed with error %@", error);
             NSLog(@"\nCurrent Location Not Detected\n");
         }
     }];
}


#pragma mark - Location authorization

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

#pragma mark - Getting Event Locations

- (void)fetchEventPointers {
    PFQuery *userXEventQuery = [UserXEvent query];
    [userXEventQuery whereKey:@"user" equalTo:[PFUser currentUser]];
    [userXEventQuery whereKey:@"type" containedIn:[NSArray arrayWithObjects: @"accepted", @"owned", nil]];
    [userXEventQuery includeKey:@"event"];
    [userXEventQuery selectKeys:[NSArray arrayWithObject:@"event"]];
    
    [userXEventQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable events, NSError * _Nullable error) {
        if (events) {
            [self annotationEvents:events];
        } else {
            NSLog(@"Error getting events: %@", error.localizedDescription);
        }
    }];
}

#pragma mark - Getting Friend Locations

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
                        [strongSelf->_friendships addObjectsFromArray:users];
                        [strongSelf annotationFriends];
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

#pragma mark - Add Annotations

- (void)annotationFriends {
    for (PFUser *friend in self->_friendships){
        CLLocationCoordinate2D coordinate;
        NSNumber *latitude = friend[@"latitude"];
        NSNumber *longitude = friend[@"longitude"];
        coordinate.latitude = latitude.floatValue;
        coordinate.longitude = longitude.floatValue;
        CustomPointAnnotation *myAnnotation = [[CustomPointAnnotation alloc] init];
        myAnnotation.coordinate = coordinate;
        myAnnotation.title = friend[@"fullname"];
        myAnnotation.subtitle = friend[@"username"];
        myAnnotation.friend = friend;
        [myAnnotation setCheckBoxSelected:NO];
        [self.mapView addAnnotation:myAnnotation];
    }
    [self.mapView showAnnotations:self.mapView.annotations animated:YES];
}

- (void) annotationEvents:(NSArray *)events {
    for (UserXEvent *addEvent in events) {
        CLLocationCoordinate2D coordinate;
        NSNumber *latitude = addEvent.event.location_lat;
        NSNumber *longitude = addEvent.event.location_lng;
        coordinate.latitude = latitude.floatValue;
        coordinate.longitude = longitude.floatValue;
        EventPointAnnotation *myAnnotation = [[EventPointAnnotation alloc] init];
        myAnnotation.coordinate = CLLocationCoordinate2DMake(latitude.floatValue, longitude.floatValue);
        myAnnotation.title = addEvent[@"event"][@"name"];
        myAnnotation.event = addEvent[@"event"];
        [self.mapView addAnnotation:myAnnotation];
    }
    [self.mapView showAnnotations:self.mapView.annotations animated:YES];
}

#pragma mark - Annotation customization

- (MKAnnotationView *)mapView:(MKMapView *)map viewForAnnotation:(id<MKAnnotation>)annotation {
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        return nil;
    }
    
    // friend annotations
    if ([annotation isKindOfClass:[CustomPointAnnotation class]]) {
        CustomPointAnnotation *customAnnotation = (CustomPointAnnotation *)annotation;
        static NSString *AnnotationViewID = @"annotationView";
        MKAnnotationView *annotationView = (MKAnnotationView *)[self.mapView dequeueReusableAnnotationViewWithIdentifier:AnnotationViewID];
        if (annotationView == nil){
            annotationView = [[MKAnnotationView alloc] initWithAnnotation:customAnnotation reuseIdentifier:AnnotationViewID];
            annotationView.canShowCallout = YES;
        } else {
            annotationView.annotation = annotation;
        }
   
        // add profile photo to annotation
        PFFileObject *imageFile = customAnnotation.friend[@"profilePhoto"];
        NSURL *profilePhotoURL = [NSURL URLWithString:imageFile.url];
        UIImage *imageForAnnotation = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:profilePhotoURL]];
        UIImage *circleImage = [self circularScaleAndCropImage:imageForAnnotation frame:CGRectMake(0, 0, 40, 40)];
        UIImageView *photoView = [[UIImageView alloc] initWithImage:circleImage];
        [annotationView addSubview:photoView];
        annotationView.frame = photoView.frame;
        UIImageView *leftIconView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
        leftIconView.image = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:profilePhotoURL]];
        annotationView.leftCalloutAccessoryView = leftIconView;
        
        // add custom view to callout
        UIView *myView = [UIView new];
        [myView addConstraint:[NSLayoutConstraint constraintWithItem:myView attribute:NSLayoutAttributeWidth  relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:100]];
        [myView addConstraint:[NSLayoutConstraint constraintWithItem:myView attribute:NSLayoutAttributeHeight  relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:30]];
        CLLocation *startLocation = self->currentLocation;
        NSNumber *lat = customAnnotation.friend[@"latitude"];
        NSNumber *lon = customAnnotation.friend[@"longitude"];
        CLLocation *endLocation = [[CLLocation alloc] initWithLatitude:lat.floatValue longitude:lon.floatValue];
        CLLocationDistance distance = [startLocation distanceFromLocation:endLocation];
        UILabel *distLabel = [[UILabel alloc] initWithFrame:CGRectMake(2, 0, 200, 20)];
        distLabel.text = [NSString stringWithFormat:@"%.1f miles away",(distance/1609.344)];
        [distLabel setTextColor:[UIColor blackColor]];
        [distLabel setBackgroundColor:[UIColor clearColor]];
        [distLabel setFont:[UIFont fontWithName: @"Trebuchet MS" size: 14.0f]];
        [myView addSubview:distLabel];
        annotationView.detailCalloutAccessoryView = myView;

        // right button to add friend
        CustomAnnotationButton *rightButton = [CustomAnnotationButton buttonWithType:UIButtonTypeContactAdd];
        if (customAnnotation.checkBoxSelected) {
            rightButton.tag = 1;
        } else {
            rightButton.tag = 0;
        }
        rightButton.friendUser = customAnnotation.friend;
        [rightButton addTarget:self action:@selector(didClickDetailDisclosure:) forControlEvents:UIControlEventTouchUpInside];
        if ([rightButton isSelected]) {
            [customAnnotation setCheckBoxSelected:YES];
        } else {
            [customAnnotation setCheckBoxSelected:NO];
        }
        annotationView.rightCalloutAccessoryView = rightButton;
 
        return annotationView;
    } else {
        EventPointAnnotation *eventAnnotation = (EventPointAnnotation *)annotation;
        static NSString *EventAnnotationViewID = @"eventAnnotationView";
        MKAnnotationView *eventAnnotationView = (MKAnnotationView *)[self.mapView dequeueReusableAnnotationViewWithIdentifier:EventAnnotationViewID];
        
        if (eventAnnotationView == nil){
            eventAnnotationView = [[MKMarkerAnnotationView alloc] initWithAnnotation:eventAnnotation reuseIdentifier:EventAnnotationViewID];
            eventAnnotationView.canShowCallout = YES;
        } else {
            eventAnnotationView.annotation = annotation;
        }
        
        UIView *myView = [UIView new];
        [myView addConstraint:[NSLayoutConstraint constraintWithItem:myView attribute:NSLayoutAttributeWidth  relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:100]];
        [myView addConstraint:[NSLayoutConstraint constraintWithItem:myView attribute:NSLayoutAttributeHeight  relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:30]];
        
        UILabel *dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(2, 0, 200, 20)];
        DateFormatterManager *manager = [DateFormatterManager sharedDateFormatter];
        [manager.formatter setDateFormat:@"EEE MMM dd"];
        dateLabel.text = [manager.formatter stringFromDate:eventAnnotation.event.date];
        [dateLabel setTextColor:[UIColor blackColor]];
        [dateLabel setBackgroundColor:[UIColor clearColor]];
        [dateLabel setFont:[UIFont fontWithName: @"Trebuchet MS" size: 14.0f]];
        [myView addSubview:dateLabel];
        eventAnnotationView.detailCalloutAccessoryView = myView;
        
        CustomAnnotationButton *rightButton = [CustomAnnotationButton buttonWithType:UIButtonTypeDetailDisclosure];
        rightButton.event = eventAnnotation.event;
        [rightButton addTarget:self action:@selector(didClickEventDetail:) forControlEvents:UIControlEventTouchUpInside];
        eventAnnotationView.rightCalloutAccessoryView = rightButton;
        return eventAnnotationView;
    }
}

- (void)didClickDetailDisclosure: (id) sender {
    CustomAnnotationButton *button = (CustomAnnotationButton *)sender;
    if ([button isSelected]) {
        [button setSelected:NO];
        button.tag = 0;
        if ([_selectedFriends containsObject:button.friendUser]) {
            [_selectedFriends removeObject:button.friendUser];
        }
    } else {
        [button setSelected:YES];
        button.tag = 1;
        if (![_selectedFriends containsObject:button.friendUser]) {
            [_selectedFriends addObject:button.friendUser];
        }
    }
}

- (void)didClickEventDetail: (id) sender {
    [self performSegueWithIdentifier:@"mapToEventSegue" sender:sender];
}

- (UIImage*)circularScaleAndCropImage:(UIImage*)image frame:(CGRect)frame {
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(frame.size.width, frame.size.height), NO, 0.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGFloat imageWidth = image.size.width;
    CGFloat imageHeight = image.size.height;
    CGFloat rectWidth = frame.size.width;
    CGFloat rectHeight = frame.size.height;
    CGFloat scaleFactorX = rectWidth/imageWidth;
    CGFloat scaleFactorY = rectHeight/imageHeight;
    CGFloat imageCentreX = rectWidth/2;
    CGFloat imageCentreY = rectHeight/2;
    CGFloat radius = rectWidth/2;
    CGContextBeginPath (context);
    CGContextAddArc (context, imageCentreX, imageCentreY, radius, 0, 2*M_PI, 0);
    CGContextClosePath (context);
    CGContextClip (context);

    CGContextScaleCTM (context, scaleFactorX, scaleFactorY);
    CGRect myRect = CGRectMake(0, 0, imageWidth, imageHeight);
    [image drawInRect:myRect];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

// Allows user to create an event
- (IBAction)clickedAddEvent:(id)sender {
    [self performSegueWithIdentifier:@"addEventSegue" sender:nil];
}

#pragma mark - Segue

// Segue to present modally "Add Event" view controller
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"mapToEventSegue"]) {
        CustomAnnotationButton *button = (CustomAnnotationButton *)sender;
        Event *event = button.event;
        EventTabBarController *tabBarViewControllers = [segue destinationViewController];
        UINavigationController *navController = tabBarViewControllers.viewControllers[0];
        EventDetailsViewController *destinationViewController = (EventDetailsViewController *)navController.topViewController;
        destinationViewController.event = event;
    } else {
        AddEventViewController *addEventViewController = (AddEventViewController *)[(UINavigationController*)segue.destinationViewController topViewController];

        NSString *lat = [NSString stringWithFormat:@"%f", self->currentLocation.coordinate.latitude];
        NSString *lon = [NSString stringWithFormat:@"%f", self->currentLocation.coordinate.longitude];
        NSString *latLong = [NSString stringWithFormat:@"%@,%@", lat, lon];

        addEventViewController.userLocation = latLong;
        addEventViewController.friendsToInvite = _selectedFriends;
    }
}

//- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
//
//    if ([view.annotation isKindOfClass:[EventPointAnnotation class]]) {
//
//    } else if ([view.annotation isKindOfClass:[CustomPointAnnotation class]]) {
//
//    }
//}
//
//- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
//
//}

@end
