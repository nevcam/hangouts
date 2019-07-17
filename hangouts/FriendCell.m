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
    NSString *title=[sender currentTitle];
    NSMutableArray *friends = [PFUser currentUser][@"friends"];
    NSMutableArray *friendRequests = self.user[@"friendRequests"];
//    if([friends containsObject:self.usernameLabel.text]) {
//
//    }
    if ([title isEqualToString:@"Add Friend"]) {
        [sender setTitle:@"Requested" forState:UIControlStateNormal];
        [friendRequests addObject:[PFUser currentUser][@"username"]];
        [self.user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (!error) {
                NSLog(@"SUCCESS REQUEST");
            } else {
                // handle error
            }
        }];
    }
    /*
    else {
        [sender setTitle:@"Add back" forState:UIControlStateNormal];
     
    }
     */
}

@end
