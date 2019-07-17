//
//  AddEventViewController.m
//  hangouts
//
//  Created by josemurillo on 7/17/19.
//  Copyright © 2019 nev. All rights reserved.
//

#import "AddEventViewController.h"
#import "Event.h"

@interface AddEventViewController ()

@property (weak, nonatomic) IBOutlet UITextField *eventNameField;
@property (weak, nonatomic) IBOutlet UIDatePicker *eventDatePicker;


@end

@implementation AddEventViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

// Closes "Add Event" view controller when user clicks respective button
- (IBAction)clickedClose:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)clickedCreateEvent:(id)sender {
    
//    NSLog(@"%@", self.eventNameField.text);
//
//    NSDate *chosenDate = self.eventDatePicker.date;
//    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
//    [formatter setDateFormat:@"YYYY-MM-dd"];
//    NSLog(@"%@",[formatter stringFromDate:chosenDate]);
    
    NSString *newEventName = self.eventNameField.text;
    NSDate *newEventDate = self.eventDatePicker.date;
    
    [Event createEvent:newEventName withDate:newEventDate withCompletion:^(BOOL succeeded, NSError *error) {
        if (error) {
            NSLog(@"Not working");
        } else {
            
            [self dismissViewControllerAnimated:YES completion:nil];
            
            NSLog(@"Success");
        }
    }];
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
