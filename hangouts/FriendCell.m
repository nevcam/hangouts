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
//    NSMutableArray *friends = [PFUser currentUser][@"friends"];
    NSLog(@"CURRENT USER: %@", [PFUser currentUser]);

    if ([title isEqualToString:@"Add Friend"]) {
        [sender setTitle:@"Requested" forState:UIControlStateNormal];
        
        [self.user addObject:[PFUser currentUser].username forKey:@"friendRequests"];

        NSLog(@"req: %@", self.user[@"friendRequests"]);

        [self.user saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            if (!error) {
                NSLog(@"SUCCESS REQUEST");
            } else {
                // handle error
                NSLog(@"ERROR REQUEST");
            }
        }];
//        [self.user saveInBackground];
        NSLog(@"user: %@", self.user);
    }
    /*
    else {
        [sender setTitle:@"Add back" forState:UIControlStateNormal];
     
    }
     */
}

@end
