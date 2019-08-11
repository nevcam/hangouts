//
//  AddEventViewController.m
//  hangouts
//
//  Created by josemurillo on 7/17/19.
//  Copyright © 2019 nev. All rights reserved.
//

#import "AddEventViewController.h"
#import "Event.h"
#import <MapKit/MapKit.h>
#import "LocationsViewController.h"
#import "FriendsInviteViewController.h"
#import "UserXEvent.h"
#import "UIImageView+AFNetworking.h"
#include "DateTableViewController.h"
#import <SVProgressHUD/SVProgressHUD.h>
#import "UserCell.h"

@interface AddEventViewController () <UINavigationControllerDelegate, UITextViewDelegate, UITextFieldDelegate, UIImagePickerControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource, LocationsViewControllerDelegate, SaveFriendsListDelegate, DateTableViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *eventLocationField;
@property (weak, nonatomic) IBOutlet UILabel *eventLocationNameField;

@property (weak, nonatomic) IBOutlet UITextField *eventNameField;
@property (weak, nonatomic) IBOutlet UITextView *eventDescriptionField;

@property (weak, nonatomic) IBOutlet UIImageView *eventPhoto;

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIButton *mapPlaceholderButton;

@property (weak, nonatomic) IBOutlet UIButton *inviteFriendsButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *createButton;

@property (weak, nonatomic) IBOutlet UICollectionView *invitedCollectionView;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end

@implementation AddEventViewController {
    NSNumber *_location_lat;
    NSNumber *_location_lng;
    NSString *_location_name;
    NSString *_location_address;
    NSDate *_startDate;
    NSDate *_endDate;
}

#pragma mark - Loading and Popping Controller

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _invitedCollectionView.delegate = self;
    _invitedCollectionView.dataSource = self;
    _startDate = [NSDate date];
    _endDate = [_startDate dateByAddingTimeInterval:(60*60)];
    
    if (!_event) {
        _invitedFriends = [[NSMutableArray alloc] initWithArray:_friendsToInvite];
        [self setInitialPlaceholder];
    } else {
        [self setEventPhoto];
        [self setEventMap];
        [self setEventLabels];
        [self setEventIVars];
    }
}

// Closes "Add Event" view controller when user clicks respective button
- (IBAction)clickedCancel:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Load New Event to Parse

// Adds an event to database
- (IBAction)clickedCreateEvent:(id)sender
{
    [SVProgressHUD show];
    
    if (![self validateFields]) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Event Creation Error" message:@"Please fill all the fields" preferredStyle:(UIAlertControllerStyleAlert)];
        UIAlertAction *tryAgainAction = [UIAlertAction actionWithTitle:@"Try Again!" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action){
        }];
        [alert addAction:tryAgainAction];
        
        [self presentViewController:alert animated:YES completion:^{
        }];
        
    } else {
        if(!_event) {
            NSString *const newEventName = _eventNameField.text;
            NSString *const description = _eventDescriptionField.text;
            
            // Calls function that adds objects to class
            [Event createEvent:newEventName
                          date:_startDate
                       endDate:_endDate
                   description:description
                           lat:_location_lat
                           lng:_location_lng
                          name:_location_name
                       address:_location_address
                         photo:_eventPhoto.image
                      duration:nil
                withCompletion:^(Event *event, NSError *error)
             {
                 [SVProgressHUD dismiss];
                 if (error) {
                     NSLog(@"Unable to create an event");
                 } else {
                     [self handleSuccessCreatingEventWithEvent:event];
                     [self dismissViewControllerAnimated:YES completion:nil];
                 }
             }];
        } else {
            [self updateEvent];
            [self updateInvites];
        }
        
    }
}

- (void) handleSuccessCreatingEventWithEvent:(Event *)event
{
    [UserXEvent createUserXEventForUser:[PFUser currentUser]
                                  event:event
                                   type:@"owned"
                         withCompletion:^(BOOL succeeded, NSError *error)
    {
        if (error) {
            NSLog(@"Failed to add owner to UserXEvent class");
        }
    }];
    
    for (PFUser *friend in _invitedFriends)
    {
        [UserXEvent createUserXEventForUser:friend
                                      event:event
                                       type:@"invited"
                             withCompletion:^(BOOL succeeded, NSError *error)
        {
            if (error) {
                NSLog(@"Failed to add user to UserXEvent class");
            }
        }];
    }
}

#pragma mark - Event Location

// Locally saves location if user has chosen one
- (void)locationsViewController:(LocationsViewController *)controller
    didPickLocationWithLatitude:(NSNumber *)latitude
                      longitude:(NSNumber *)longitude
                           name:(NSString *)name
                        address:(NSString *)address
{
    _location_lat = latitude;
    _location_lng = longitude;
    _location_address = address;
    _location_name = name;
    
    _eventLocationNameField.text = name;
    // Not all locations have an address
    if (address) {
        _eventLocationField.text = address;
    }
    
    if (_location_lng && _location_lat) {
        [_mapView removeAnnotations:_mapView.annotations];
        [self getLocationPoint:_location_lat longitude:_location_lng];
        [_mapView showAnnotations:_mapView.annotations animated:YES];
    }
    
    [self.navigationController popToViewController:self animated:YES];
}

#pragma mark - Load and Invite Friends

// Follows protocol to save friends list from list view controller
- (void)saveFriendsList:(nonnull NSMutableArray *)friendsList {
    _invitedFriends = friendsList;
    [_invitedCollectionView reloadData];
}

#pragma mark - Friends and Locations Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"locationsViewSegue"]) {
        LocationsViewController *locationController = [segue destinationViewController];
        locationController.delegate = self;
        locationController.userLocation = _userLocation;
    }
    else if ([segue.identifier isEqualToString:@"eventFriendsSegue"]) {
        FriendsInviteViewController *friendsInvitedController = [segue destinationViewController];
        friendsInvitedController.delegate = self;
        friendsInvitedController.invitedFriends = _invitedFriends;
    } else if ([segue.identifier isEqualToString:@"DatepickerEmbeddedSegue"]) {
        DateTableViewController *dateTableViewController = [segue destinationViewController];
        if(_event) {
            dateTableViewController.startDate = _event.date;
            dateTableViewController.endDate = _event.endDate;
        }
        dateTableViewController.delegate = self;
    }
}

#pragma mark - Validate Event Information

- (BOOL)validateFields
{
    NSArray *fieldsStrings = [NSArray arrayWithObjects:_eventLocationNameField.text, _eventDescriptionField.text, _eventNameField.text, nil];

    for (NSString *string in fieldsStrings) {
        NSString *const stringNoSpaces = [string stringByReplacingOccurrencesOfString:@" " withString:@""];
        if([stringNoSpaces isEqualToString:@""]) {
            return NO;
        }
    }
    return YES;
}

#pragma mark - View Controller Layout Code

// Disables field to prevent users from adding random locations
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return NO;
}

- (void) setInitialPlaceholder
{
    if (_eventDescriptionField.text.length == 0) {
        _eventDescriptionField.text = @"Description";
        _eventDescriptionField.textColor = [UIColor lightGrayColor];
        _eventDescriptionField.delegate = self;
    }
}
- (BOOL) textViewShouldBeginEditing:(UITextView *)textView
{
    if ([_eventDescriptionField.text isEqual: @"Description"]) {
        _eventDescriptionField.text = @"";
    }
    _eventDescriptionField.textColor = [UIColor blackColor];
    return YES;
}
-(void) textViewDidChange:(UITextView *)textView
{
    if(_eventDescriptionField.text.length == 0) {
        _eventDescriptionField.textColor = [UIColor lightGrayColor];
        _eventDescriptionField.text = @"Description";
        [_eventDescriptionField resignFirstResponder];
    }
}
-(BOOL) textViewShouldEndEditing:(UITextView *)textView
{
    if(_eventDescriptionField.text.length == 0) {
        _eventDescriptionField.textColor = [UIColor lightGrayColor];
        _eventDescriptionField.text = @"Description";
        [_eventDescriptionField resignFirstResponder];
    }
    return YES;
}

#pragma mark - Dismiss Keyboard

- (IBAction)didTapReturn:(id)sender
{
    [self.eventNameField resignFirstResponder];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if([text isEqualToString:@"\n"]) {
        [self.eventDescriptionField resignFirstResponder];
        return NO;
    }
    return YES;
}

#pragma mark - Map

- (void)getLocationPoint:(NSNumber *)latitude longitude:(NSNumber *)longitude {
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(latitude.floatValue, longitude.floatValue);
    
    MKPointAnnotation *annotation = [MKPointAnnotation new];
    annotation.coordinate = coordinate;
    if (_location_name) {
        annotation.title = _location_name;
    } else {
        annotation.title = @"New Event!";
    }
    [self.mapView addAnnotation:annotation];
}
- (IBAction)didTapMapPlaceholder:(id)sender {
    [_mapPlaceholderButton setHidden:YES];
    [self performSegueWithIdentifier:@"locationsViewSegue" sender:self];
}

#pragma mark - Event photo methods

- (IBAction)didTapPhoto:(id)sender {
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        [actionSheet dismissViewControllerAnimated:YES completion:nil];
    }]];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Select Photo" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self selectPhoto];
    }]];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Take Photo" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self takePhoto];
    }]];

    [self presentViewController:actionSheet animated:YES completion:nil];
}

- (void) selectPhoto {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self presentViewController:picker animated:YES completion:NULL];
}

- (void)takePhoto {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    [self presentViewController:picker animated:YES completion:NULL];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    UIImage *editedImage = info[UIImagePickerControllerEditedImage];
    UIImage *resizedImage = [self resizeImage:editedImage withSize:CGSizeMake(350, 350)];
    _eventPhoto.image = resizedImage;
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (UIImage *)resizeImage:(UIImage *)image withSize:(CGSize)size {
    UIImageView *resizeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    resizeImageView.contentMode = UIViewContentModeScaleAspectFill;
    resizeImageView.image = image;
    
    UIGraphicsBeginImageContext(size);
    [resizeImageView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

#pragma mark - Edit Event Setup Methods

- (void)setEventMap {
    [_mapPlaceholderButton setHidden:YES];
    double lat = [_event.location_lat doubleValue];
    double lng = [_event.location_lng doubleValue];
    MKPointAnnotation *myAnnotation = [[MKPointAnnotation alloc] init];
    myAnnotation.coordinate = CLLocationCoordinate2DMake(lat, lng);
    if (_event.location_name) {
        myAnnotation.title = _event.location_name;
    }
    
    [_mapView addAnnotation:myAnnotation];
    MKCoordinateRegion adjustedRegion = [_mapView regionThatFits:MKCoordinateRegionMakeWithDistance(myAnnotation.coordinate, 500, 500)];
    [_mapView setRegion:adjustedRegion animated:YES];
    [_mapView setUserInteractionEnabled:NO];
}

- (void)setEventPhoto {
    if(_event.eventPhoto) {
        PFFileObject *const imageFile = _event.eventPhoto;
        NSURL *const profilePhotoURL = [NSURL URLWithString:imageFile.url];
        _eventPhoto.image = nil;
        [_eventPhoto setImageWithURL:profilePhotoURL];
    } else {
        _eventPhoto.image = [UIImage imageNamed:@"img-placeholder"];
    }
}

- (void)setEventLabels {
    _eventLocationField.text = _event.location_address;
    _eventLocationNameField.text = _event.location_name;
    _eventNameField.text = _event.name;
    _eventDescriptionField.text = _event.eventDescription;
    [_createButton setTitle:@"Save"];
}

- (void)setEventIVars {
    _location_lat = _event.location_lat;
    _location_lng = _event.location_lng;
    _location_name = _event.location_name;
    _location_address = _event.location_address;
}

#pragma mark - Update queries

- (void)updateEvent {
    PFQuery *eventQuery = [Event query];
    __weak typeof(self) weakSelf = self;
    [eventQuery getObjectInBackgroundWithId:_event.objectId block:^(PFObject * _Nullable object, NSError * _Nullable error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if(strongSelf) {
            if(object) {
                Event *event = (Event *)object;
                [strongSelf updateDataBaseEvent:event];
            } else {
                [strongSelf.delegate didEditEvent:nil];
            }
        }
    }];
}

- (void)updateDataBaseEvent:(Event *)event {
    [self updateInfoOfEvent:event];
    __weak typeof(self) weakSelf = self;
    [event saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        [SVProgressHUD dismiss];
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if(strongSelf) {
            if (error) {
                [strongSelf.delegate didEditEvent:nil];
                NSLog(@"Error updating event: %@", error);
            } else {
                [strongSelf.delegate didEditEvent:event];
            }
            [strongSelf dismissViewControllerAnimated:YES completion:nil];
        }
    }];
}

- (void) inviteFriends:(NSArray *)newInvites {
    if(newInvites) {
        for (PFUser *friend in newInvites) {
            [UserXEvent createUserXEventForUser:friend event:_event type:@"invited" withCompletion:^(BOOL succeeded, NSError *error) {
                 if (error) {
                     NSLog(@"Failed to add user to UserXEvent class");
                 }
             }];
        }
    }
}

- (void) uninviteFriends:(NSArray *)removedInvites {
    if(removedInvites) {
        PFQuery *userXEventQuery = [UserXEvent query];
        [userXEventQuery whereKey:@"event" equalTo:_event];
        [userXEventQuery whereKey:@"user" containedIn:removedInvites];
        
        [userXEventQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
            if(objects && !error) {
                [UserXEvent deleteAllInBackground:objects block:^(BOOL succeeded, NSError * _Nullable error) {
                    if(error) {
                        NSLog(@"Could not delete uninvited UserXEvents");
                    }
                }];
            }
        }];
    }
}

#pragma mark - Update methods

- (void)updateInfoOfEvent:(Event *)event {
    [self assignImageToEvent:event];
    event.name = _eventNameField.text;
    event.eventDescription = _eventDescriptionField.text;
    event.date = _startDate;
    event.endDate = _endDate;
    event.location_name = _eventLocationNameField.text;
    event.location_address = _eventLocationField.text;
    event.location_lat = _location_lat;
    event.location_lng = _location_lng;
}

- (void)assignImageToEvent: (Event *)event {
    NSData *imageData;
    if(_eventPhoto.image != nil) {
        imageData = UIImageJPEGRepresentation(_eventPhoto.image, 1.0);
    } else {
        UIImage *pic = [UIImage imageNamed:@"img-placeholder"];
        imageData = UIImageJPEGRepresentation(pic, 1.0);
    }
    PFFileObject *img = [PFFileObject fileObjectWithName:@"eventPic.png" data:imageData];
    event.eventPhoto = img;
}

- (void) updateInvites {
    NSMutableArray *newInvites = [NSMutableArray new];
    for (PFUser *user in _invitedFriends) {
        if ([_goingFriends containsObject:user]) {
            [_goingFriends removeObject:user];
        } else if ([_pendingFriends containsObject:user]) {
            [_pendingFriends removeObject:user];
        } else {
            [newInvites addObject:user];
        }
    }
    [self inviteFriends:newInvites];
    
    NSMutableArray *removedInvites = [NSMutableArray new];
    for (PFUser *user in _goingFriends) {
        [removedInvites addObject:user];
    }
    for (PFUser *user in _pendingFriends) {
        [removedInvites addObject:user];
    }
    [self uninviteFriends:removedInvites];
}

#pragma mark - Date Picker Controller Protocol Methods

- (void)changedStartDateTo:(NSDate *)startDate {
    _startDate = startDate;
}

- (void)changedEndDateTo:(NSDate *)endDate {
    _endDate = endDate;
}

#pragma mark - Collection View Protocol Methods

- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    UserCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"InvitedUserCell" forIndexPath:indexPath];
    PFUser *user = _invitedFriends[indexPath.item];
    [cell configureCell:user];
    return cell;
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _invitedFriends.count;
}

@end
