//
//  FriendsToEventCell.h
//  hangouts
//
//  Created by josemurillo on 7/19/19.
//  Copyright © 2019 nev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Parse/Parse.h"
#import "Friendship.h"


NS_ASSUME_NONNULL_BEGIN

@protocol FriendEventCellDelegate <NSObject>
- (void)addFriendToEvent:(PFUser *)friend remove:(BOOL)remove;
@end


@interface FriendsToEventCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *profilePhotoView;
@property (weak, nonatomic) IBOutlet UILabel *fullnameLabel;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UIButton *addFriendButton;

@property (nonatomic, weak) PFUser *user;
@property (nonatomic, weak) Friendship *userFriendship;

@property (nonatomic, weak) id <FriendEventCellDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
