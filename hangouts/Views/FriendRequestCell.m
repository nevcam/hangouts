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
    [self.delegate deleteCellForIndexPath: self.indexPath];
}

- (IBAction)didTapDeny:(id)sender {
    [self removeFromFriendRequests];
//    [self.delegate deleteCellForIndexPath: self.indexPath];
}


- (void) removeFromFriendRequests {
    // remove incoming request
    NSMutableArray *friendRequests = (NSMutableArray *)self.currentUserFriendship.incomingRequests;
    for (PFUser *requestUser in friendRequests) {
        if ([self.user.objectId isEqual:requestUser.objectId]) {
            [friendRequests removeObject:requestUser];
        }
    }
    self.currentUserFriendship.incomingRequests = (NSPointerArray *)friendRequests;
    [self.currentUserFriendship saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            NSLog(@"success");
            self.acceptButton.enabled = NO;
            self.denyButton.enabled = NO;
        } else {
            NSLog(@"error");
        }
    }];
    
    // remove outgoing request
    PFQuery *query = [Friendship query];
    [query orderByDescending:@"createdAt"];
    query.limit = 1;
    [query includeKey:@"user"];
    [query whereKey:@"user" equalTo:self.user];
    [query findObjectsInBackgroundWithBlock:^(NSArray<Friendship *> * _Nullable friendships, NSError * _Nullable error) {
        if (friendships) {
            self.cellUserFriendship = friendships[0];
            NSMutableArray *cellUserOutgoingRequests = (NSMutableArray *)self.cellUserFriendship.outgoingRequests;
            for (PFUser *outgoingRequestUser in cellUserOutgoingRequests) {
                if ([[PFUser currentUser].objectId isEqual:outgoingRequestUser.objectId]) {
                    [cellUserOutgoingRequests removeObject:outgoingRequestUser];
                }
            }
            self.cellUserFriendship.outgoingRequests = (NSPointerArray *)cellUserOutgoingRequests;
            [self.cellUserFriendship saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
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

- (void) addToCurrentUsersFriends {
//    NSString *username = self.user[@"username"];
    [self.currentUserFriendship addObject:self.user forKey:@"friends"];
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
    [query includeKey:@"user"];
    [query whereKey:@"user" equalTo:self.user];;
    [query findObjectsInBackgroundWithBlock:^(NSArray<Friendship *> * _Nullable friendships, NSError * _Nullable error) {
        if (friendships) {
            self.cellUserFriendship = friendships[0];
            [self.cellUserFriendship addObject:[PFUser currentUser] forKey:@"friends"];
            [self.cellUserFriendship saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
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
