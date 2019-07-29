//
//  FriendCell.m
//  hangouts
//
//  Created by nev on 7/17/19.
//  Copyright © 2019 nev. All rights reserved.
//

#import "FriendCell.h"


@implementation FriendCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (IBAction)didTapAddFriend:(id)sender {
    // requesting frienship object that contains user's friendship and friend request information
    PFQuery *query = [Friendship query];
    [query orderByDescending:@"createdAt"];
    [query includeKey:@"user"];
    [query whereKey:@"user" equalTo:self.user];
    query.limit = 20;
    __weak typeof(self) weakSelf = self;
    [query findObjectsInBackgroundWithBlock:^(NSArray<Friendship *> * _Nullable friendships, NSError * _Nullable error) {
        if (friendships) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            strongSelf.userFriendship = friendships[0];
            // changing button titlw to "requested" after user taps add friend
            NSString *title=[sender currentTitle];
            
            if ([title isEqualToString:@"Add Friend"]) {
                [sender setTitle:@"Requested" forState:UIControlStateNormal];
                // adds the new friend request to user's friend incoming requests array and saves it
                [strongSelf.userFriendship addObject:[PFUser currentUser] forKey:@"incomingRequests"];
                [strongSelf.userFriendship saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                    if (!error) {
                    } else {
                        NSLog(@"ERROR REQUEST %@", error.localizedDescription);
                    }
                }];
                // adds the new friend request to user's outgouing requests array
                [strongSelf.currentUserFriendship addObject:self.user forKey:@"outgoingRequests"];
                [strongSelf.currentUserFriendship saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                    if (!error) {
                    } else {
                        NSLog(@"ERROR REQUEST");
                    }
                }];
            }
        } else {
            NSLog(@"Error: %@", error.localizedDescription);
        }
    }];

    /*
    else {
        [sender setTitle:@"Add back" forState:UIControlStateNormal];
     
    }
     */
}

@end
