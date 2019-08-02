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
@property (weak, nonatomic) IBOutlet UILabel *eventLocatinNameField;
@property (weak, nonatomic) IBOutlet UITextField *eventNameField;
@property (weak, nonatomic) IBOutlet UIDatePicker *eventDatePicker;
@property (weak, nonatomic) IBOutlet UITextView *eventDescriptionField;
@property (weak, nonatomic) IBOutlet UIButton *inviteFriendsButton;
@property (weak, nonatomic) IBOutlet UIButton *locationButton;
@property (weak, nonatomic) IBOutlet UIImageView *friend1View;
@property (weak, nonatomic) IBOutlet UIImageView *friend2View;
@property (weak, nonatomic) IBOutlet UIImageView *friend3View;
@property (weak, nonatomic) IBOutlet UIImageView *eventImageView;
@property (weak, nonatomic) IBOutlet UITextField *eventDurationField;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIImageView *eventPhoto;

@end

@implementation AddEventViewController

#pragma mark - Global Variables

{
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
    
    [self setInitialPlaceholder];
    [_eventDatePicker setMinimumDate: [NSDate date]];
    [self getFriendPhotos];
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
        
        // create a try again action, notifying the user that an error occured
        UIAlertAction *tryAgainAction = [UIAlertAction actionWithTitle:@"Try Again!" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action){
        }];
        [alert addAction:tryAgainAction];
        
        [self presentViewController:alert animated:YES completion:^{
        }];
        
    } else {
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

#pragma mark - Load and Choose Event Location

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
    
    _eventLocatinNameField.text = name;
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

#pragma mark - Show Map in View Controller

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

#pragma mark - Can Edit/Add Progile

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

@end
