//
//  PersonProfileViewController.m
//  hangouts
//
//  Created by josemurillo on 7/29/19.
//  Copyright © 2019 nev. All rights reserved.
//

#import "PersonProfileViewController.h"
#import "UIImageView+AFNetworking.h"

@interface PersonProfileViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *profilePhotoView;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UITextField *fullnameLabel;
@property (weak, nonatomic) IBOutlet UITextField *bioLabel;
@property (weak, nonatomic) IBOutlet UIButton *addFriendButton;
@property (weak, nonatomic) IBOutlet UILabel *emailLabel;

@end

@implementation PersonProfileViewController

#pragma mark - Set Profile Basic Features
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setProfileFeatures];
}

// REMOVE REMOVE
- (void)setProfileFeatures {
    _usernameLabel.text = self.user[@"username"];
    self.fullnameLabel.text = self.user[@"fullname"];
    self.emailLabel.text = self.user[@"email"];
    self.bioLabel.text = self.user[@"bio"];
    [self setProfileImageLayout];
}

// NO SPACING AFTER VIOID - PARANTHESIS AFTER LINE
- (void) setProfileImageLayout {
    // CONST - CAN'T CHANGE
    PFFileObject *const imageFile = self.user[@"profilePhoto"];
    NSURL *profilePhotoURL = [NSURL URLWithString:imageFile.url];
    self.profilePhotoView.image = nil;
    [self.profilePhotoView setImageWithURL:profilePhotoURL];
    self.profilePhotoView.layer.cornerRadius = self.profilePhotoView.frame.size.height /2;
    self.profilePhotoView.layer.masksToBounds = YES;
    self.profilePhotoView.layer.borderWidth = 0;
}

@end
