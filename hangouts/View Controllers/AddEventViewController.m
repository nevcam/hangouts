//
//  AddEventViewController.m
//  hangouts
//
//  Created by josemurillo on 7/17/19.
//  Copyright © 2019 nev. All rights reserved.
//

#import "AddEventViewController.h"
#import "Event.h"

@interface AddEventViewController () <UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UITextField *eventNameField;
@property (weak, nonatomic) IBOutlet UIDatePicker *eventDatePicker;
@property (weak, nonatomic) IBOutlet UITextView *eventDescriptionField;


@end

@implementation AddEventViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.eventDescriptionField.text = @"Write caption here";
    self.eventDescriptionField.textColor = [UIColor lightGrayColor];
    [self.eventDescriptionField setFont:[UIFont systemFontOfSize:18]];
    self.eventDescriptionField.delegate = self;
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
    
    // Calls function that adds objects to class
    [Event createEvent:newEventName withDate:newEventDate withDescription:description withCompletion:^(BOOL succeeded, NSError *error) {
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


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
