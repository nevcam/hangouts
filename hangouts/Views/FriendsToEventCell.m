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
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)clickedInvite:(id)sender {
    if ([[sender currentTitle] isEqualToString:@"Invite"]) {
        [sender setTitle:@"Uninvite" forState:UIControlStateNormal];
    }
    else {
        [sender setTitle:@"Invite" forState:UIControlStateNormal];
    }
}
@end
