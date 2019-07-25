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
{
    __weak NSNumber *_location_lat;
    __weak NSNumber *_location_lng;
    __weak NSString *_location_name;
    __weak NSString *_location_address;
           NSMutableArray *_invitedFriends;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.eventLocationField.delegate = self;
    
    // Layout for fields and date picker
    [self setInitialPlaceholder];
    [self.eventDatePicker setMinimumDate: [NSDate date]];
}


// Closes "Add Event" view controller when user clicks respective button
- (IBAction)clickedCancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
// Adds an event to database
- (IBAction)clickedCreateEvent:(id)sender {
    
    // Uses class function to check that all fields are not empty
    if (![self validateFields]) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Event Creation Error" message:@"Please fill all the fields" preferredStyle:(UIAlertControllerStyleAlert)];
        
        // create a try again action, notifying the user that an error occured
        UIAlertAction *tryAgainAction = [UIAlertAction actionWithTitle:@"Try Again!" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action){
            // function calls itself to try again!
        }];
        
        // add the cancel action to the alertController
        [alert addAction:tryAgainAction];
        
        [self presentViewController:alert animated:YES completion:^{
        }];
        
    } else {
        // Sets necessary objects
        NSString *newEventName = self.eventNameField.text;
        NSDate *newEventDate = self.eventDatePicker.date;
        NSString *description = self.eventDescriptionField.text;
        NSString *location_name = _location_name;
        
        // Calls function that adds objects to class
        [Event createEvent:newEventName withDate:newEventDate withDescription:description withLat:_location_lat withLng:_location_lng withName:location_name withAddress:_location_address users_invited:_invitedFriends withCompletion:^(Event *event, NSError *error) {
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
- (void) handleSuccessCreatingEventWithEvent:(Event *)event {
    [UserXEvent createUserXEventForUser:[PFUser currentUser] withEvent:event withType:@"owned" withCompletion:^(BOOL succeeded, NSError *error) {
        if (error) {
            NSLog(@"Failed to add owner to UserXEvent class");
        }
    }];
    
    for (PFUser *friend in _invitedFriends) {
        [UserXEvent createUserXEventForUser:friend withEvent:event withType:@"invited" withCompletion:^(BOOL succeeded, NSError *error) {
            if (error) {
                NSLog(@"Failed to add user to UserXEvent class");
            }
        }];
    }
}


// Triggered when user wants to choose a location
- (IBAction)clickedChooseLocation:(id)sender {
    [self performSegueWithIdentifier:@"locationsViewSegue" sender:nil];
}
// Locally saves location if user has chosen one
- (void)locationsViewController:(LocationsViewController *)controller didPickLocationWithLatitude:(NSNumber *)latitude longitude:(NSNumber *)longitude name:(NSString *)name address:(NSString *)address {
    
    _location_lat = latitude;
    _location_lng = longitude;
    _location_address = address;
    _location_name = name;
    
    // We show the name, rather than the address because not all locations have address
    self.eventLocationField.text = name;
    
    [self.navigationController popToViewController:self animated:YES];
}

// Triggered when user wants to see the list of friends that are invited to the event
- (IBAction)clickedInviteFriends:(id)sender {
    [self performSegueWithIdentifier:@"eventFriendsSegue" sender:nil];
}
// Follows protocol to save friends list from list view controller
- (void)saveFriendsList:(nonnull NSMutableArray *)friendsList {
    self->_invitedFriends = friendsList;
    [self.inviteFriendsButton setTitle:@"Invitees" forState:UIControlStateNormal];
}


// Segues to location and friends view controllers
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"locationsViewSegue"]) {
        UINavigationController *locationController = [segue destinationViewController];
        locationController.delegate = self;
    }
    else if ([segue.identifier isEqualToString:@"eventFriendsSegue"]) {
        FriendsInviteViewController *friendsInvitedController = [segue destinationViewController];
        friendsInvitedController.delegate = self;
        friendsInvitedController.invitedFriends = _invitedFriends;
    }
}

// RUNS alerts to prevent user from inputing an event with empty fields. Boolean to exit function as soon as an error is encountered
- (BOOL)validateFields {
    NSArray *fieldsStrings = [NSArray arrayWithObjects:self.eventLocationField.text, self.eventDescriptionField.text, self.eventNameField.text, nil];
    
    // Loops through fields and checks if there is any empty field
    for (NSString *string in fieldsStrings) {
        NSString *stringNoSpaces = [string stringByReplacingOccurrencesOfString:@" " withString:@""];
        if([stringNoSpaces isEqualToString:@""]) {
            return NO;
        }
    }
    return YES;
}


// VIEW CONTROLLER LAYOUT CODE
// Disables field to prevent users from adding random locations
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    return NO;
}

// Sets placeholder in textView
- (void) setInitialPlaceholder {
    if (self.eventDescriptionField.text.length == 0) {
        self.eventDescriptionField.text = @"Description";
        self.eventDescriptionField.textColor = [UIColor lightGrayColor];
        [self.eventDescriptionField setFont:[UIFont systemFontOfSize:18]];
        self.eventDescriptionField.delegate = self;
    }
}
- (BOOL) textViewShouldBeginEditing:(UITextView *)textView {
    if ([self.eventDescriptionField.text isEqual: @"Description"]) {
        self.eventDescriptionField.text = @"";
    }
    self.eventDescriptionField.textColor = [UIColor blackColor];
    return YES;
}
-(void) textViewDidChange:(UITextView *)textView {
    if(self.eventDescriptionField.text.length == 0) {
        self.eventDescriptionField.textColor = [UIColor lightGrayColor];
        self.eventDescriptionField.text = @"Description";
        [self.eventDescriptionField resignFirstResponder];
    }
}
-(void) textViewShouldEndEditing:(UITextView *)textView {
    if(self.eventDescriptionField.text.length == 0) {
        self.eventDescriptionField.textColor = [UIColor lightGrayColor];
        self.eventDescriptionField.text = @"Description";
        [self.eventDescriptionField setFont:[UIFont systemFontOfSize:18]];
        [self.eventDescriptionField resignFirstResponder];
    }
}

@end
