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
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    if (self.invited) {
        [self changeButtonLayout:YES];
    } else {
        [self changeButtonLayout:NO];
    }
}

- (IBAction)clickedInvite:(id)sender {
    if ([[sender currentTitle] isEqualToString:@"Invite"]) {
        [self changeButtonLayout:YES];
        [self.delegate addFriendToEvent:self.user remove:NO];
    }
    else {
        [self changeButtonLayout:NO];
        [self.delegate addFriendToEvent:self.user remove:YES];
    }
}

// Sets layout for invite button
- (void)changeButtonLayout:(BOOL)invited {
    if (invited) {
        [self.addFriendButton setTitle:@"Uninvite" forState:UIControlStateNormal];
        self.addFriendButton.backgroundColor = [UIColor colorWithRed:0.87 green:0.88 blue:0.86 alpha:1.0];
    } else {
        [self.addFriendButton setTitle:@"Invite" forState:UIControlStateNormal];
        self.addFriendButton.backgroundColor = [UIColor colorWithRed:0.69 green:0.93 blue:0.57 alpha:1.0];
    }
}

@end
