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

@interface AddEventViewController () <UINavigationControllerDelegate, UITextViewDelegate, LocationsViewControllerDelegate, UITextFieldDelegate, SaveFriendsListDelegate, UIImagePickerControllerDelegate>

// Features displayed/edited in the view controller
@property (weak, nonatomic) IBOutlet UILabel *eventLocationField;
@property (weak, nonatomic) IBOutlet UILabel *eventLocationNameField;

@property (weak, nonatomic) IBOutlet UITextField *eventNameField;
@property (weak, nonatomic) IBOutlet UITextView *eventDescriptionField;

@property (weak, nonatomic) IBOutlet UIDatePicker *eventDatePicker;

@property (weak, nonatomic) IBOutlet UIImageView *friend1View;
@property (weak, nonatomic) IBOutlet UIImageView *friend2View;
@property (weak, nonatomic) IBOutlet UIImageView *friend3View;
@property (weak, nonatomic) IBOutlet UITextField *eventDurationField;
@property (weak, nonatomic) IBOutlet UIImageView *eventPhoto;

@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@property (weak, nonatomic) IBOutlet UIButton *inviteFriendsButton;
@property (weak, nonatomic) IBOutlet UIButton *locationButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *createButton;

@end

@implementation AddEventViewController {
    NSNumber *_location_lat;
    NSNumber *_location_lng;
    NSString *_location_name;
    NSString *_location_address;
    NSMutableArray *_invitedFriends;
}

#pragma mark - Loading and Popping Controller

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (!_event) {
        [_eventDatePicker setMinimumDate: [NSDate date]];
        [self setInitialPlaceholder];
        [self getFriendPhotos];
    } else {
        [self setEventPhoto];
        [self setEventMap];
        [self setEventLabels];
        [self setEventIVars];
        _eventDatePicker.date = _event.date;
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
    // Uses class function to check that all fields are not empty
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
            NSDate *const newEventDate = _eventDatePicker.date;
            NSString *const description = _eventDescriptionField.text;
            NSString *const newEventDuration = _eventDurationField.text;
            
            // Calls function that adds objects to class
            [Event createEvent:newEventName
                          date:newEventDate
                   description:description
                           lat:_location_lat
                           lng:_location_lng
                          name:_location_name
                       address:_location_address
                         photo:_eventPhoto.image
                      duration:newEventDuration
                withCompletion:^(Event *event, NSError *error)
             {
                 if (error) {
                     NSLog(@"Unable to create an event");
                 } else {
                     [self handleSuccessCreatingEventWithEvent:event];
                     [self dismissViewControllerAnimated:YES completion:nil];
                 }
             }];
        } else {
            [self updateEvent];
            [self dismissViewControllerAnimated:YES completion:nil];
        }
        
    }
}

// If event is created successfully, we add owner and friends to UserXEvent Class
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

// Triggered when user wants to choose a location
- (IBAction)clickedChooseLocation:(id)sender
{
    [self performSegueWithIdentifier:@"locationsViewSegue" sender:nil];
}
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
    if (name) {
        [self.locationButton setTitle:@"Change" forState:UIControlStateNormal];
    }
    
    if (_location_lng && _location_lat) {
        [_mapView removeAnnotations:_mapView.annotations];
        [self getLocationPoint:_location_lat longitude:_location_lng];
        [_mapView showAnnotations:_mapView.annotations animated:YES];
    }
    
    [self.navigationController popToViewController:self animated:YES];
}

#pragma mark - Load and Invite Friends

// Triggered when user wants to see the list of friends that are invited to the event
- (IBAction)clickedInviteFriends:(id)sender
{
    [self performSegueWithIdentifier:@"eventFriendsSegue" sender:nil];
}
// Follows protocol to save friends list from list view controller
- (void)saveFriendsList:(nonnull NSMutableArray *)friendsList
{
    _invitedFriends = friendsList;
    [self getFriendPhotos];
    if(_invitedFriends && _invitedFriends.count > 0) {
        [_inviteFriendsButton setTitle:@"Invitees" forState:UIControlStateNormal];
    }
}

#pragma mark - Friends and Locations Segues

// Segues to location and friends view controllers
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
    }
}

#pragma mark - Validate Event Information

// RUNS alerts to prevent user from inputing an event with empty fields. Boolean to exit function as soon as an error is encountered
- (BOOL)validateFields
{
    NSArray *fieldsStrings = [NSArray arrayWithObjects:_eventLocationField.text, _eventDescriptionField.text, _eventNameField.text, nil];
    
    // Loops through fields and checks if there is any empty field
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

// Sets placeholder in textView
- (void) setInitialPlaceholder
{
    if (_eventDescriptionField.text.length == 0) {
        _eventDescriptionField.text = @"Description";
        _eventDescriptionField.textColor = [UIColor lightGrayColor];
        [_eventDescriptionField setFont:[UIFont systemFontOfSize:18]];
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
        [_eventDescriptionField setFont:[UIFont systemFontOfSize:18]];
        [_eventDescriptionField resignFirstResponder];
    }
    return YES;
}

#pragma mark - Dismiss Keyboard

// For name text field
- (IBAction)didTapReturn:(id)sender
{
    [self.eventNameField resignFirstResponder];
}

// For description text view
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if([text isEqualToString:@"\n"]) {
        [self.eventDescriptionField resignFirstResponder];
        return NO;
    }
    return YES;
}

#pragma mark - Show Friend Profile Pictures

- (void) getFriendPhotos {
    if (_invitedFriends) {
        if (_invitedFriends.count > 2)
        {
            PFFileObject *const imageFile = _invitedFriends[2][@"profilePhoto"];
            NSURL *const profilePhotoURL = [NSURL URLWithString:imageFile.url];
            _friend3View.image = nil;
            [_friend3View setImageWithURL:profilePhotoURL];
            _friend3View.layer.cornerRadius = _friend3View.frame.size.height /2;
            _friend3View.layer.masksToBounds = YES;
            _friend3View.layer.borderWidth = 0;
        }
        else
        {
            _friend3View.image = [UIImage imageNamed:@"profile"];
        }
        if (_invitedFriends.count > 1)
        {
            PFFileObject *const imageFile = _invitedFriends[1][@"profilePhoto"];
            NSURL *const profilePhotoURL = [NSURL URLWithString:imageFile.url];
            _friend2View.image = nil;
            [_friend2View setImageWithURL:profilePhotoURL];
            _friend2View.layer.cornerRadius = _friend2View.frame.size.height /2;
            _friend2View.layer.masksToBounds = YES;
            _friend2View.layer.borderWidth = 0;
        }
        else
        {
            _friend2View.image = [UIImage imageNamed:@"profile"];
        }
        if (_invitedFriends.count > 0)
        {
            PFFileObject *const imageFile = _invitedFriends[0][@"profilePhoto"];
            NSURL *const profilePhotoURL = [NSURL URLWithString:imageFile.url];
            _friend1View.image = nil;
            [_friend1View setImageWithURL:profilePhotoURL];
            _friend1View.layer.cornerRadius = _friend1View.frame.size.height /2;
            _friend1View.layer.masksToBounds = YES;
            _friend1View.layer.borderWidth = 0;
        }
        else
        {
            _friend1View.image = [UIImage imageNamed:@"profile"];
        }
    }
}

#pragma mark - Map

// Creates a pointer im the map
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

#pragma mark - Can Edit/Add Profile

- (IBAction)clickedAddPhoto:(id)sender {
    UIImagePickerController *imagePickerVC = [UIImagePickerController new];
    imagePickerVC.delegate = self;
    imagePickerVC.allowsEditing = YES;
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        imagePickerVC.sourceType = UIImagePickerControllerSourceTypeCamera;
    }
    else {
        imagePickerVC.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    
    [self presentViewController:imagePickerVC animated:YES completion:nil];
}

// Saves photo when image has been chosen
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    
    UIImage *const originalImage = info[UIImagePickerControllerOriginalImage];
    
    _eventPhoto.image = originalImage;
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Edit Event Setup Methods

- (void)setEventMap {
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
    PFFileObject *const imageFile = _event.eventPhoto;
    NSURL *const profilePhotoURL = [NSURL URLWithString:imageFile.url];
    _eventPhoto.image = nil;
    [_eventPhoto setImageWithURL:profilePhotoURL];
    _eventDurationField.text = _event.duration;
}

- (void)setEventLabels {
    _eventLocationField.text = _event.location_address;
    _eventLocationNameField.text = _event.location_name;
    _eventNameField.text = _event.name;
    _eventDescriptionField.text = _event.eventDescription;
    [_locationButton setTitle:@"Change" forState:UIControlStateNormal];
    [_createButton setTitle:@"Save"];
}

- (void)setEventIVars {
    _location_lat = _event.location_lat;
    _location_lng = _event.location_lng;
    _location_name = _event.location_name;
    _location_address = _event.location_address;
    // _invitedFriends (??)
}

- (void)updateEvent {
    PFQuery *eventQuery = [Event query];
    __weak typeof(self) weakSelf = self;
    [eventQuery getObjectInBackgroundWithId:_event.objectId block:^(PFObject * _Nullable object, NSError * _Nullable error) {
        if(object) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if(strongSelf) {
                Event *event = (Event *)object;
                [strongSelf updateDataBaseEvent:event];
            }
        }
    }];
}

- (void)updateDataBaseEvent:(Event *)event {
//    NSData *imageData;
//    if(_eventPhoto.image != nil) {
//        imageData = UIImageJPEGRepresentation(_eventPhoto.image, 1.0);
//    } else {
//        UIImage *pic = [UIImage imageNamed:@"profile"];
//        imageData = UIImageJPEGRepresentation(pic, 1.0);
//    }
//    PFFileObject *img = [PFFileObject fileObjectWithName:@"eventPhoto.png" data:imageData];
//    [img saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
//        [event setObject:img forKey:@"eventPhoto"];
//        [event saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
//            if (error) {
//                NSLog(@"Error updating event: %@", error);
//            } else {
//                NSLog(@"Updated event");
//            }
//        }];
//    }];
    [self updateInfoOfEvent:event];
    [event saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (error) {
            NSLog(@"Error updating event: %@", error);
        } else {
            NSLog(@"Updated event");
        }
    }];
}

- (void)updateInfoOfEvent:(Event *)event {
    [self assignImageToEvent:event];
    event.name = _eventNameField.text;
    event.date = _eventDatePicker.date;
    event.eventDescription = _eventDescriptionField.text;
    event.location_name = _eventLocationNameField.text;
    event.location_address = _eventLocationField.text;
    event.location_lat = _location_lat;
    event.location_lng = _location_lng;
    event.duration = _eventDurationField.text;
}

- (void)assignImageToEvent: (Event *)event {
    NSData *imageData;
    if(_eventPhoto.image != nil) {
        imageData = UIImageJPEGRepresentation(_eventPhoto.image, 1.0);
    } else {
        UIImage *pic = [UIImage imageNamed:@"profile"]; //!!
        imageData = UIImageJPEGRepresentation(pic, 1.0);
    }
    PFFileObject *img = [PFFileObject fileObjectWithName:@"eventPic.png" data:imageData];
    //probar asi y luego sin saveinbackground
    event.eventPhoto = img;
//    [img saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
//        if(succeeded) {
//
//        }
//    }];
}

@end
