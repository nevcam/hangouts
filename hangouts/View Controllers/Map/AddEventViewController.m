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

@interface AddEventViewController () <UINavigationControllerDelegate, UITextViewDelegate, LocationsViewControllerDelegate, UITextFieldDelegate, SaveFriendsListDelegate>

// Features displayed/edited in the view controller
@property (weak, nonatomic) IBOutlet UITextField *eventLocationField;
@property (weak, nonatomic) IBOutlet UITextField *eventNameField;
@property (weak, nonatomic) IBOutlet UIDatePicker *eventDatePicker;
@property (weak, nonatomic) IBOutlet UITextView *eventDescriptionField;
@property (weak, nonatomic) IBOutlet UIButton *inviteFriendsButton;

// @property (strong, nonatomic) NSMutableArray *invitedFriends;

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
    
    _eventLocationField.delegate = self;
    
    // Layout for fields and date picker
    [self setInitialPlaceholder];
    [_eventDatePicker setMinimumDate: [NSDate date]];
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
        NSString *const location_name = _location_name;
        
        // Calls function that adds objects to class
        [Event createEvent:newEventName
                      date:newEventDate
               description:description
                       lat:_location_lat
                       lng:_location_lng
                      name:location_name
                   address:_location_address
             users_invited:_invitedFriends
            withCompletion:^(Event *event, NSError *error)
        {
            if (error) {
                NSLog(@"Not working");
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
    
    // We show the name, rather than the address because not all locations have address
    _eventLocationField.text = name;
    
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
    [_inviteFriendsButton setTitle:@"Invitees" forState:UIControlStateNormal];
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


@end
