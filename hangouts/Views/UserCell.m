//
//  UserCell.m
//  hangouts
//
//  Created by sroman98 on 8/1/19.
//  Copyright © 2019 nev. All rights reserved.
//

#import "UserCell.h"
#import "UIImageView+AFNetworking.h"

@implementation UserCell

- (void) configureCell:(PFUser *)user {
    _user = user;
    _nameLabel.text = [NSString stringWithFormat:@"@%@", user.username];
    [self setProfileImage];
}

- (void) setProfileImage {
    PFFileObject *const imageFile = _user[@"profilePhoto"];
    NSURL *const profilePhotoURL = [NSURL URLWithString:imageFile.url];
    _profileImageView.image = nil;
    [_profileImageView setImageWithURL:profilePhotoURL];
    _profileImageView.layer.cornerRadius = _profileImageView.frame.size.height /2;
    _profileImageView.layer.masksToBounds = YES;
    _profileImageView.layer.borderWidth = 0;
}

@end
