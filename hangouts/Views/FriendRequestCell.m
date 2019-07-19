//
//  FriendRequestCell.m
//  hangouts
//
//  Created by nev on 7/18/19.
//  Copyright © 2019 nev. All rights reserved.
//

#import "FriendRequestCell.h"
#import "Friendship.h"

@implementation FriendRequestCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)didTapAccept:(id)sender {
    //update current users friends list
    [self addToCurrentUsersFriends];
    [self addToAddedUsersFriends];
    [self removeFromFriendRequests];
}

- (IBAction)didTapDeny:(id)sender {
    [self removeFromFriendRequests];
}


- (void) removeFromFriendRequests {
    NSMutableArray *friendRequests = self.currentUserFriendship[@"friendRequests"];
    [friendRequests removeObject:self.user[@"username"]];
    self.currentUserFriendship[@"friendRequests"] = friendRequests;
    [self.currentUserFriendship saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            NSLog(@"success");
            self.acceptButton.enabled = NO;
            self.denyButton.enabled = NO;
        } else {
            NSLog(@"error");
        }
    }];
}

- (void) addToCurrentUsersFriends {
    NSString *username = self.user[@"username"];
    [self.currentUserFriendship addObject:username forKey:@"friends"];
    [self.currentUserFriendship saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            NSLog(@"success");
        } else {
            NSLog(@"error");
        }
    }];
}

- (void) addToAddedUsersFriends {
    PFQuery *query = [Friendship query];
    [query orderByDescending:@"createdAt"];
    query.limit = 1;
    [query whereKey:@"username" equalTo:self.user[@"username"]];
    [query findObjectsInBackgroundWithBlock:^(NSArray<Friendship *> * _Nullable friendships, NSError * _Nullable error) {
        if (friendships) {
            Friendship *cellUserFriendship = friendships[0];
            [cellUserFriendship addObject:[PFUser currentUser][@"username"] forKey:@"friends"];
            [cellUserFriendship saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (!error) {
                    NSLog(@"success");
                } else {
                    NSLog(@"error");
                }
            }];
        } else {
            NSLog(@"Error: %@", error.localizedDescription);
        }
    }];
    
}

@end
