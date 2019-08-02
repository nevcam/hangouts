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

- (void)setProfileFeatures
{
    _usernameLabel.text = self.user[@"username"];
    _fullnameLabel.text = self.user[@"fullname"];
    _emailLabel.text = self.user[@"email"];
    _bioLabel.text = self.user[@"bio"];
    [self setProfileImageLayout];
}

- (void)setProfileImageLayout
{
    PFFileObject *const imageFile = self.user[@"profilePhoto"];
    NSURL *const profilePhotoURL = [NSURL URLWithString:imageFile.url];
    _profilePhotoView.image = nil;
    [_profilePhotoView setImageWithURL:profilePhotoURL];
    _profilePhotoView.layer.cornerRadius = self.profilePhotoView.frame.size.height /2;
    _profilePhotoView.layer.masksToBounds = YES;
    _profilePhotoView.layer.borderWidth = 0;
}

@end
