//
//  SignUpViewController.m
//  hangouts
//
//  Created by sroman98 on 7/17/19.
//  Copyright © 2019 nev. All rights reserved.
//

#import "SignUpViewController.h"
@import Parse;

@interface SignUpViewController ()

@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UILabel *errorLabel;

@end

@implementation SignUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

// MARK: class methods

- (IBAction)didTapRegister:(id)sender {
    // initialize a user object
    PFUser *newUser = [PFUser user];
    
    // set user properties
    newUser.username = self.usernameField.text;
    newUser.email = self.emailField.text;
    newUser.password = self.passwordField.text;
    
    [newUser setObject:self.nameField.text forKey:@"fullname"];
    
    /*NSData *imageData;
    if(self.photo != nil) {
        imageData = UIImageJPEGRepresentation(self.photo, 1.0);
    } else {
        UIImage *pic = [UIImage imageNamed:@"profile_tab"];
        imageData = UIImageJPEGRepresentation(pic, 1.0);
    }
    PFFileObject *img = [PFFileObject fileObjectWithName:@"profilePic.png" data:imageData];
    [img saveInBackground];
    
    [newUser setObject:img forKey:@"image"];
    [newUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            NSLog(@"Uploaded profile pic!");
        } else {
            NSLog(@"Error uploading profile pic: %@", error);
        }
    }];*/
    
    NSString *usernameNoSpaces = [self.usernameField.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSString *nameNoSpaces = [self.nameField.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSString *emailNoSpaces = [self.emailField.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    if([usernameNoSpaces isEqualToString:@""] || [newUser.password isEqualToString:@""] || [nameNoSpaces isEqualToString:@""] || [emailNoSpaces isEqualToString:@""]) {
        self.errorLabel.text = @"Please fill in all fields";
        [self.errorLabel setHidden:NO];
        NSLog(@"Didn't fill out all fields.");
    } else {
        [self.errorLabel setHidden:YES];
        [self registerUser:newUser];
    }
}

- (void)registerUser:(PFUser *)newUser {
    // call sign up function on the object
    [newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError * error) {
        if (error != nil) {
            self.errorLabel.text = [NSString stringWithFormat:@"%@",error.localizedDescription];
            [self.errorLabel setHidden:NO];
            NSLog(@"Error: %@", error.localizedDescription);
        } else {
            [self.errorLabel setHidden:YES];
            NSLog(@"User registered successfully");
            // manually segue to logged in view
            [self performSegueWithIdentifier:@"registeredSegue" sender:self];
        }
    }];
}

- (IBAction)didTapCancel:(id)sender {
    [self dismissViewControllerAnimated:true completion:nil];
}

// This method dismisses the keyboard when you hit return
- (IBAction)didTapReturn:(id)sender {
    [self.nameField resignFirstResponder];
    [self.usernameField resignFirstResponder];
    [self.emailField resignFirstResponder];
    [self.passwordField resignFirstResponder];
}

@end
