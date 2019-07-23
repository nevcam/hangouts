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

@interface MapViewController ()

@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self fetchEventPointers];
}

// Makes request for locations of accepted events to add respective pointers in the map
- (void)fetchEventPointers {
    PFQuery *userXEventQuery = [UserXEvent query];
    [userXEventQuery whereKey:@"username" equalTo:[PFUser currentUser].username];
    [userXEventQuery whereKey:@"type" containedIn:[NSArray arrayWithObjects: @"accepted", @"owned", nil]];

    PFQuery *eventQuery = [Event query];
    [eventQuery whereKey:@"objectId" matchesKey:@"eventId" inQuery:userXEventQuery];
    
    [eventQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable events, NSError * _Nullable error) {
        if (events) {
            for (Event *event in events) {
                [self getLocationPoint:event.location_lat longitude:event.location_lng];
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
    NSLog(@"created");
}

// Allows user to create an event
- (IBAction)clickedAddEvent:(id)sender {
    [self performSegueWithIdentifier:@"addEventSegue" sender:nil];
}

// Segue to present modally "Add Event" view controller
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
}

@end
