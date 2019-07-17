//
//  LoginViewController.m
//  hangouts
//
//  Created by sroman98 on 7/17/19.
//  Copyright © 2019 nev. All rights reserved.
//

#import "LoginViewController.h"
#import "SignUpViewController.h"
@import Parse;

@interface LoginViewController () <SignUpViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UILabel *errorLabel;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([[segue identifier] isEqualToString:@"registerSegue"]) {
        UINavigationController *navigationController = [segue destinationViewController];
        SignUpViewController *signupController = (SignUpViewController*)navigationController.topViewController;
        signupController.delegate = self;
    }
}


// MARK: class methods

// This method dismisses the keyboard when you hit return
- (IBAction)didTapReturn:(id)sender {
    [self.usernameField resignFirstResponder];
    [self.passwordField resignFirstResponder];
}

- (void)loginUser {
    NSString *username = self.usernameField.text;
    NSString *password = self.passwordField.text;
    
    [PFUser logInWithUsernameInBackground:username password:password block:^(PFUser * user, NSError *  error) {
        if (error != nil) {
            self.errorLabel.text = @"Incorrect user/password";
            self.errorLabel.backgroundColor = [UIColor redColor];
            [self.errorLabel setHidden:NO];
            NSLog(@"User log in failed: %@", error.localizedDescription);
        } else {
            [self.errorLabel setHidden:YES];
            NSLog(@"User logged in successfully");
            // display view controller that needs to shown after successful login
            [self performSegueWithIdentifier:@"loginSegue" sender:self];
        }
    }];
}

- (IBAction)didTapLogin:(id)sender {
    [self loginUser];
}

// MARK: protocol methods
- (void)registerUserWithStatus:(BOOL)successful {
    if(successful) {
        self.errorLabel.text = @"Account registered successfully!";
        self.errorLabel.backgroundColor = [UIColor greenColor];
        [self.errorLabel setHidden:NO];
    }
}

@end
