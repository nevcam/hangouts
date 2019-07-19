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
#import "ProfileEditViewController.h"
@import Parse;

@interface ProfileViewController () <ProfileEditViewControllerDelegate>

@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.user = [PFUser currentUser];
    self.usernameLabel.text = self.user[@"username"];
    self.fullnameLabel.text = self.user[@"fullname"];
    self.emailLabel.text = self.user[@"email"];
    self.bioLabel.text = self.user[@"bio"];
    
    PFFileObject *imageFile = self.user[@"profilePhoto"];
    NSURL *profilePhotoURL = [NSURL URLWithString:imageFile.url];
    self.profilePhotoView.image = nil;
    [self.profilePhotoView setImageWithURL:profilePhotoURL];
    // make profile photo a circle
    self.profilePhotoView.layer.cornerRadius = self.profilePhotoView.frame.size.height /2;
    self.profilePhotoView.layer.masksToBounds = YES;
    self.profilePhotoView.layer.borderWidth = 0;
    
}

- (IBAction)didTapEditProfile:(id)sender {
    [self performSegueWithIdentifier:@"profileEditSegue" sender:nil];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier  isEqual: @"profileEditSegue"]){
        PFUser *user = self.user;
        ProfileEditViewController *profileEditViewController = [segue destinationViewController];
        profileEditViewController.user = user;
        profileEditViewController.delegate = self;
    }
}


// MARK: logout functions
- (IBAction)didTapLogout:(id)sender {
    [PFUser logOutInBackgroundWithBlock:^(NSError * _Nullable error) {
        // PFUser.current() will now be nil
        if(PFUser.currentUser == nil) {
            AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            LoginViewController *loginViewController = [storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
            appDelegate.window.rootViewController = loginViewController;
        } else {
            NSLog(@"Error logging out: %@", error);
        }
    }];
}

- (void)didSave {
    PFQuery *query = [PFUser query];
    [query orderByDescending:@"createdAt"];
    query.limit = 1;
    [query whereKey:@"username" equalTo:self.user[@"username"]];
    [query findObjectsInBackgroundWithBlock:^(NSArray<PFUser *> * _Nullable users, NSError * _Nullable error) {
        if (users) {
            PFUser *user = users[0];
            self.fullnameLabel.text = user[@"fullname"];
            self.bioLabel.text = user[@"bio"];
            PFFileObject *imageFile = user[@"profilePhoto"];
            NSURL *photoURL = [NSURL URLWithString:imageFile.url];
            self.profilePhotoView.image = nil;
            [self.profilePhotoView setImageWithURL:photoURL];
            self.profilePhotoView.layer.cornerRadius = self.profilePhotoView.frame.size.width / 2;
            self.profilePhotoView.layer.masksToBounds = YES;
            [self.view addSubview: self.profilePhotoView];
        } else {
            NSLog(@"Error: %@", error.localizedDescription);
        }
    }];
}

@end
