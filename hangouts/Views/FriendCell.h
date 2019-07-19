//
//  FriendCell.h
//  hangouts
//
//  Created by nev on 7/17/19.
//  Copyright © 2019 nev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Parse/Parse.h"
#import "Friendship.h"

NS_ASSUME_NONNULL_BEGIN

@interface FriendCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *profilePhotoView;
@property (weak, nonatomic) IBOutlet UILabel *fullnameLabel;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UIButton *addFriendButton;
@property (nonatomic, weak) PFUser *user;
@property (nonatomic, weak) Friendship *userFriendship;
@property (nonatomic, weak) NSMutableArray *friends;
@property (nonatomic, weak) NSMutableArray *friendRequests;
@end

NS_ASSUME_NONNULL_END
