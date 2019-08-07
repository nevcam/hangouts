//
//  FriendsToEventCell.m
//  hangouts
//
//  Created by josemurillo on 7/19/19.
//  Copyright © 2019 nev. All rights reserved.
//

#import "FriendsToEventCell.h"

@implementation FriendsToEventCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self changeButtonLayout:NO];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    // Sets gesture for tapping on freind's profile image, which will then redirect users to the respecrive friend's profile page
    UITapGestureRecognizer *profileTapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(didTapUserProfile:)];
    [_profilePhotoView addGestureRecognizer:profileTapGestureRecognizer];
    [_profilePhotoView setUserInteractionEnabled:YES];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    if (_invited) {
        [self changeButtonLayout:YES];
    } else {
        [self changeButtonLayout:NO];
    }
}

- (IBAction)clickedInvite:(id)sender {
    if ([[sender currentTitle] isEqualToString:@"Invite"]) {
        [self changeButtonLayout:YES];
        [_delegate addFriendToEvent:_user remove:NO];
    }
    else {
        [self changeButtonLayout:NO];
        [self.delegate addFriendToEvent:_user remove:YES];
    }
}

// Sets layout for invite button
- (void)changeButtonLayout:(BOOL)invited {
    if (invited) {
        [_addFriendButton setTitle:@"Uninvite" forState:UIControlStateNormal];
        _addFriendButton.backgroundColor = [UIColor colorWithRed:0.87 green:0.88 blue:0.86 alpha:1.0];
    } else {
        [_addFriendButton setTitle:@"Invite" forState:UIControlStateNormal];
        _addFriendButton.backgroundColor = [UIColor colorWithRed:0.69 green:0.93 blue:0.57 alpha:1.0];
    }
}

- (void) didTapUserProfile:(UITapGestureRecognizer *)sender{
    [_delegate tapProfile:self didTap:self.user];
}

@end
