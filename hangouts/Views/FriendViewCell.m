//
//  FriendViewCell.m
//  hangouts
//
//  Created by nev on 7/19/19.
//  Copyright © 2019 nev. All rights reserved.
//

#import "FriendViewCell.h"

@implementation FriendViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    // Sets gesture for tapping on freind's profile image, which will then redirect users to the respecrive friend's profile page
    UITapGestureRecognizer *profileTapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(didTapUserProfile:)];
    [self.profilePhotoView addGestureRecognizer:profileTapGestureRecognizer];
    [self.profilePhotoView setUserInteractionEnabled:YES];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) didTapUserProfile:(UITapGestureRecognizer *)sender{
    [_delegate tapProfile:self didTap:self.user];
}

@end
