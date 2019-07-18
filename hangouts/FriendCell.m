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

    PFQuery *query = [Friendship query];
    [query orderByDescending:@"createdAt"];
    [query includeKey:@"username"];
    [query whereKey:@"username" equalTo:self.userFriendship.username];
    query.limit = 20;
    [query findObjectsInBackgroundWithBlock:^(NSArray<Friendship *> * _Nullable friendships, NSError * _Nullable error) {
        if (friendships) {
            self.userFriendship = friendships[0];
        } else {
            NSLog(@"Error: %@", error.localizedDescription);
        }
    }];
    NSString *title=[sender currentTitle];
    NSString *currentUsername = [PFUser currentUser][@"username"];

    if ([title isEqualToString:@"Add Friend"]) {
        [sender setTitle:@"Requested" forState:UIControlStateNormal];
        
        [self.userFriendship addObject:currentUsername forKey:@"friendRequests"];

        [self.userFriendship saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            if (!error) {
            } else {
                NSLog(@"ERROR REQUEST");
            }
        }];
        NSLog(@"user: %@", self.user);
    }
    /*
    else {
        [sender setTitle:@"Add back" forState:UIControlStateNormal];
     
    }
     */
}

@end
