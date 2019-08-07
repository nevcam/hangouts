//
//  LoginViewController.m
//  hangouts
//
//  Created by sroman98 on 7/17/19.
//  Copyright © 2019 nev. All rights reserved.
//

#import "LoginViewController.h"
#import "SignUpViewController.h"
#import <SVProgressHUD/SVProgressHUD.h>
@import Parse;

@interface LoginViewController () <SignUpViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UILabel *errorLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end

@implementation LoginViewController

#pragma mark -  class methods

// This method dismisses the keyboard when you hit return
- (IBAction)didTapReturn:(id)sender {
    [_usernameField resignFirstResponder];
    [_passwordField resignFirstResponder];
}

- (void)loginUser {
    NSString *username = _usernameField.text;
    NSString *password = _passwordField.text;
    
    __weak typeof(self) weakSelf = self;
    [PFUser logInWithUsernameInBackground:username password:password block:^(PFUser * user, NSError *  error) {
        [SVProgressHUD dismiss];
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if(strongSelf) {
            if (error != nil) {
                if(error.code == 100) {
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Cannot Connect" message:@"The Internet connection appears to be offline." preferredStyle:(UIAlertControllerStyleAlert)];
                    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleCancel handler:nil];
                    [alert addAction:okAction];
                    [strongSelf presentViewController:alert animated:YES completion:nil];
                } else {
                    strongSelf.errorLabel.text = @"Invalid username/password";
                    strongSelf.errorLabel.backgroundColor = [UIColor redColor];
                    [strongSelf.errorLabel setHidden:NO];
                }
            } else {
                [strongSelf.errorLabel setHidden:YES];
                [strongSelf performSegueWithIdentifier:@"loginSegue" sender:self];
            }
        }
        
    }];
}

- (IBAction)didTapLogin:(id)sender {
    [SVProgressHUD show];
    [self loginUser];
}

#pragma mark -  protocol methods

- (void)registerUserWithStatus:(BOOL)successful {
    if(successful) {
        _errorLabel.text = @"Account registered successfully!";
        _errorLabel.backgroundColor = [UIColor greenColor];
        [_errorLabel setHidden:NO];
    }
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([[segue identifier] isEqualToString:@"registerSegue"]) {
        UINavigationController *navigationController = [segue destinationViewController];
        SignUpViewController *signupController = (SignUpViewController*)navigationController.topViewController;
        signupController.delegate = self;
    }
}

@end
