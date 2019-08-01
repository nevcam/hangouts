//
//  EventDetailsViewController.m
//  hangouts
//
//  Created by nev on 7/22/19.
//  Copyright © 2019 nev. All rights reserved.
//

#import "EventDetailsViewController.h"
#import "DateFormatterManager.h"
#import "UserXEvent.h"
#import "UserCell.h"
#import <MapKit/MapKit.h>

@interface EventDetailsViewController () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *ownerUsernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationAddressLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet MKMapView *locationMapView;
@property (weak, nonatomic) IBOutlet UICollectionView *goingCollectionView;

@end

@implementation EventDetailsViewController {
    NSArray *_goingUserXEvents;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    UINavigationController *navController = (UINavigationController *) self.parentViewController;
    EventTabBarController *tabBar = (EventTabBarController *)navController.parentViewController;
    tabBar.event = _event;
    
    _goingCollectionView.delegate = self;
    _goingCollectionView.dataSource = self;
    
    [self setLabels];
    [self setMap];
    [self fetchGoingUsers];
}

- (IBAction)didTapClose:(id)sender {
    [self dismissViewControllerAnimated:true completion:nil];
}

#pragma mark - Labels Methods

- (void)setLabels {
    _nameLabel.text = _event.name;
    _ownerUsernameLabel.text = [NSString stringWithFormat:@"@%@", _event.ownerUsername];
    DateFormatterManager *manager = [DateFormatterManager sharedDateFormatter];
    [manager.formatter setDateFormat:@"EEEE MMMM dd, Y"];
    _dateLabel.text = [manager.formatter stringFromDate:_event.date];
    _locationNameLabel.text = _event.location_name;
    _locationAddressLabel.text = _event.location_address;
    _descriptionLabel.text = _event.eventDescription;
}

#pragma mark - Map Methods

- (void)setMap {
    double lat = [_event.location_lat doubleValue];
    double lng = [_event.location_lng doubleValue];
    MKPointAnnotation *myAnnotation = [[MKPointAnnotation alloc] init];
    myAnnotation.coordinate = CLLocationCoordinate2DMake(lat, lng);
    
    [_locationMapView addAnnotation:myAnnotation];
    MKCoordinateRegion adjustedRegion = [_locationMapView regionThatFits:MKCoordinateRegionMakeWithDistance(myAnnotation.coordinate, 500, 500)];
    [_locationMapView setRegion:adjustedRegion animated:YES];
    [_locationMapView setUserInteractionEnabled:NO];
}

- (IBAction)didTapMap:(id)sender {
    double lat = [_event.location_lat doubleValue];
    double lng = [_event.location_lng doubleValue];
    CLLocationCoordinate2D location = CLLocationCoordinate2DMake(lat,lng);

    //Apple Maps, using the MKMapItem class
    MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:location addressDictionary:nil];
    MKMapItem *item = [[MKMapItem alloc] initWithPlacemark:placemark];
    item.name = _event.location_name;
    [item openInMapsWithLaunchOptions:nil];
}

#pragma mark - Fetching methods

- (void)fetchGoingUsers {
    PFQuery *acceptedUserXEventQuery = [UserXEvent query];
    [acceptedUserXEventQuery whereKey:@"event" equalTo:_event];
    [acceptedUserXEventQuery whereKey:@"type" equalTo:@"accepted"];
    [acceptedUserXEventQuery includeKey:@"user"];
    [acceptedUserXEventQuery selectKeys:[NSArray arrayWithObject:@"user"]];
    
    __weak typeof(self) weakSelf = self;
    [acceptedUserXEventQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable userXEvents, NSError * _Nullable error) {
        if (userXEvents) {
            __strong typeof(weakSelf) strongSelf = self;
            if(strongSelf) {
                strongSelf->_goingUserXEvents = [[NSMutableArray alloc] initWithArray:userXEvents];
                [strongSelf.goingCollectionView reloadData];
            }
        } else {
            NSLog(@"Error getting events: %@", error.localizedDescription);
        }
    }];
}

#pragma mark - Collection View Protocol Methods

- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    UserCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"GoingUserCell" forIndexPath:indexPath];
    UserXEvent *userXEvent = _goingUserXEvents[indexPath.item];
    [cell configureCell:userXEvent.user];
    return cell;
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _goingUserXEvents.count;
}

@end
