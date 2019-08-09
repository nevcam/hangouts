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
    
    _acceptButton.backgroundColor = [UIColor colorWithRed:0.65 green:0.88 blue:0.97 alpha:1.0];

    // Sets gesture for tapping on freind's profile image, which will then redirect users to the respecrive friend's profile page
    UITapGestureRecognizer *profileTapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(didTapUserProfile:)];
    [self.profilePhotoView addGestureRecognizer:profileTapGestureRecognizer];
    [self.profilePhotoView setUserInteractionEnabled:YES];
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
            break;
        }
    }
    self.currentUserFriendship.incomingRequests = (NSPointerArray *)friendRequests;
    __weak typeof(self) weakSelf = self;
    [self.currentUserFriendship saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!error) {
            strongSelf.acceptButton.enabled = NO;
            strongSelf.denyButton.enabled = NO;
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
            __strong typeof(weakSelf) strongSelf = weakSelf;
            strongSelf.cellUserFriendship = friendships[0];
            NSMutableArray *cellUserOutgoingRequests = (NSMutableArray *)strongSelf.cellUserFriendship.outgoingRequests;
            for (PFUser *outgoingRequestUser in cellUserOutgoingRequests) {
                if ([[PFUser currentUser].objectId isEqual:outgoingRequestUser.objectId]) {
                    [cellUserOutgoingRequests removeObject:outgoingRequestUser];
                    break;
                }
            }
            strongSelf.cellUserFriendship.outgoingRequests = (NSPointerArray *)cellUserOutgoingRequests;
            [strongSelf.cellUserFriendship saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
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
    [query whereKey:@"user" equalTo:self.user];
    __weak typeof(self) weakSelf = self;
    [query findObjectsInBackgroundWithBlock:^(NSArray<Friendship *> * _Nullable friendships, NSError * _Nullable error) {
        if (friendships) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            strongSelf.cellUserFriendship = friendships[0];
            [strongSelf.cellUserFriendship addObject:[PFUser currentUser] forKey:@"friends"];
            [strongSelf.cellUserFriendship saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
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

- (void) didTapUserProfile:(UITapGestureRecognizer *)sender{
    [_delegate tapProfile:self didTap:self.user];
}

@end
