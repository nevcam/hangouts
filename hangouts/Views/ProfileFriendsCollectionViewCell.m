//
//  ProfileFriendsCollectionViewCell.m
//  hangouts
//
//  Created by josemurillo on 8/2/19.
//  Copyright © 2019 nev. All rights reserved.
//

#import "ProfileFriendsCollectionViewCell.h"

@implementation ProfileFriendsCollectionViewCell


- (void)awakeFromNib {
    [super awakeFromNib];

    // Sets gesture for tapping on freind's profile image, which will then redirect users to the respecrive friend's profile page
    UITapGestureRecognizer *profileTapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(didTapUserProfile:)];
    [self.profileImageView addGestureRecognizer:profileTapGestureRecognizer];
    [self.profileImageView setUserInteractionEnabled:YES];
}

- (void) didTapUserProfile:(UITapGestureRecognizer *)sender{
    [_delegate tapProfile:self didTap:self.user];
}

@end
