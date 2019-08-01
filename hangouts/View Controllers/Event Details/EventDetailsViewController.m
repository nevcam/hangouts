//
//  EventDetailsViewController.m
//  hangouts
//
//  Created by nev on 7/22/19.
//  Copyright © 2019 nev. All rights reserved.
//

#import "EventDetailsViewController.h"
#import "DateFormatterManager.h"
#import <MapKit/MapKit.h>

@interface EventDetailsViewController ()

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *ownerUsernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationAddressLabel;
@property (weak, nonatomic) IBOutlet MKMapView *locationMapView;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;

@end

@implementation EventDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    UINavigationController *navController = (UINavigationController *) self.parentViewController;
    EventTabBarController *tabBar = (EventTabBarController *)navController.parentViewController;
    tabBar.event = _event;
    
    _nameLabel.text = _event.name;
    _ownerUsernameLabel.text = _event.ownerUsername;
    DateFormatterManager *manager = [DateFormatterManager sharedDateFormatter];
    [manager.formatter setDateFormat:@"EEE MMM dd"];
    _dateLabel.text = [manager.formatter stringFromDate:_event.date];
    _locationNameLabel.text = _event.location_name;
    _locationAddressLabel.text = _event.location_address;
    _descriptionLabel.text = _event.eventDescription;
    
    double lat = [_event.location_lat doubleValue];
    double lng = [_event.location_lng doubleValue];
    MKPointAnnotation *myAnnotation = [[MKPointAnnotation alloc] init];
    myAnnotation.coordinate = CLLocationCoordinate2DMake(lat, lng);
    
    [_locationMapView addAnnotation:myAnnotation];
    MKCoordinateRegion adjustedRegion = [_locationMapView regionThatFits:MKCoordinateRegionMakeWithDistance(myAnnotation.coordinate, 500, 500)];
    [_locationMapView setRegion:adjustedRegion animated:YES];
    [_locationMapView setUserInteractionEnabled:NO];
}

- (IBAction)didTapClose:(id)sender {
    [self dismissViewControllerAnimated:true completion:nil];
}

@end
