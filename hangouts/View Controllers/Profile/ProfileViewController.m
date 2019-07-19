//
//  ProfileViewController.m
//  hangouts
//
//  Created by sroman98 on 7/17/19.
//  Copyright © 2019 nev. All rights reserved.
//

#import "ProfileViewController.h"
#import "LoginViewController.h"
#import "AppDelegate.h"
#import "UIImageView+AFNetworking.h"
@import Parse;

@interface ProfileViewController ()

@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.user = [PFUser currentUser];
    self.usernameLabel.text = self.user[@"username"];
    self.fullnameLabel.text = self.user[@"fullname"];
    self.emailLabel.text = self.user[@"email"];
    
    PFFileObject *imageFile = self.user[@"profilePhoto"];
    NSURL *profilePhotoURL = [NSURL URLWithString:imageFile.url];
    self.profilePhotoView.image = nil;
    [self.profilePhotoView setImageWithURL:profilePhotoURL];
    // make profile photo a circle
    self.profilePhotoView.layer.cornerRadius = self.profilePhotoView.frame.size.height /2;
    self.profilePhotoView.layer.masksToBounds = YES;
    self.profilePhotoView.layer.borderWidth = 0;
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

// MARK: logout functions
- (IBAction)didTapLogout:(id)sender {
    [PFUser logOutInBackgroundWithBlock:^(NSError * _Nullable error) {
        // PFUser.current() will now be nil
        if(PFUser.currentUser == nil) {
            AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            LoginViewController *loginViewController = [storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
            appDelegate.window.rootViewController = loginViewController;
            
            NSLog(@"User logged out successfully");
        } else {
            NSLog(@"Error logging out: %@", error);
        }
    }];
}

@end
