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

@interface AddEventViewController () <UITextViewDelegate, LocationsViewControllerDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *eventLocationField;
@property (weak, nonatomic) IBOutlet UITextField *eventNameField;
@property (weak, nonatomic) IBOutlet UIDatePicker *eventDatePicker;
@property (weak, nonatomic) IBOutlet UITextView *eventDescriptionField;
@property (strong, nonatomic) NSNumber *location_lat;
@property (strong, nonatomic) NSNumber *location_lng;
@property (strong, nonatomic) NSString *location_name;
@property (strong, nonatomic) NSString *location_address;

@end

@implementation AddEventViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.eventDescriptionField.text = @"Write caption here";
    self.eventDescriptionField.textColor = [UIColor lightGrayColor];
    [self.eventDescriptionField setFont:[UIFont systemFontOfSize:18]];
    self.eventDescriptionField.delegate = self;
    
    self.eventLocationField.delegate = self;
}

// Closes "Add Event" view controller when user clicks respective button
- (IBAction)clickedClose:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

// Adds an event to database
- (IBAction)clickedCreateEvent:(id)sender {
    
    // Sets necessary objects
    NSString *newEventName = self.eventNameField.text;
    NSDate *newEventDate = self.eventDatePicker.date;
    NSString *description = self.eventDescriptionField.text;
    NSString *location_name = self.location_name;
    
    NSLog(@"%@", location_name);
    
    // Calls function that adds objects to class
    [Event createEvent:newEventName withDate:newEventDate withDescription:description withLat:self.location_lat withLng:self.location_lng withName:location_name withAddress:self.location_address withCompletion:^(BOOL succeeded, NSError *error) {
        if (error) {
            NSLog(@"Not working");
        } else {
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }];
}

// Sets placeholder in textView
- (BOOL) textViewShouldBeginEditing:(UITextView *)textView {
    self.eventDescriptionField.text = @"";
    self.eventDescriptionField.textColor = [UIColor blackColor];
    return YES;
}
-(void) textViewDidChange:(UITextView *)textView {
    if(self.eventDescriptionField.text.length == 0) {
        self.eventDescriptionField.textColor = [UIColor lightGrayColor];
        self.eventDescriptionField.text = @"Write caption here";
        [self.eventDescriptionField resignFirstResponder];
    }
}
-(void) textViewShouldEndEditing:(UITextView *)textView {
    if(self.eventDescriptionField.text.length == 0) {
        self.eventDescriptionField.textColor = [UIColor lightGrayColor];
        self.eventDescriptionField.text = @"Write caption here";
        [self.eventDescriptionField setFont:[UIFont systemFontOfSize:18]];
        [self.eventDescriptionField resignFirstResponder];
    }
}

// Triggered when user wants to choose a location
- (IBAction)clickedChooseLocation:(id)sender {
    [self performSegueWithIdentifier:@"locationsViewSegue" sender:nil];
}

- (void)locationsViewController:(LocationsViewController *)controller didPickLocationWithLatitude:(NSNumber *)latitude longitude:(NSNumber *)longitude name:(NSString *)name address:(NSString *)address {
    
    self.location_lat = latitude;
    self.location_lng = longitude;
    self.location_address = address;
    self.location_name = name;
    
    // We show the name, rather than the address because not all locations have address
    self.eventLocationField.text = name;
    
    [self.navigationController popToViewController:self animated:YES];
}

// Disables field to prevent users from adding random locations
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    return NO;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    UINavigationController *locationController = [segue destinationViewController];
    
    locationController.delegate = self;
    
}

@end
