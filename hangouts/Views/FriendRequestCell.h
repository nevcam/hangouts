//
//  FriendRequestCell.h
//  hangouts
//
//  Created by nev on 7/18/19.
//  Copyright © 2019 nev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Parse/Parse.h"
#import "Friendship.h"
@class FriendRequestCell;
NS_ASSUME_NONNULL_BEGIN

@protocol FriendRequestCellDelegate <NSObject>
- (void)deleteCellForIndexPath:(NSIndexPath *)indexPath;
- (void)tapProfile:(FriendRequestCell *)friendCell didTap: (PFUser *)user;
@end

@interface FriendRequestCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *profilePhotoView;
@property (weak, nonatomic) IBOutlet UILabel *fullnameLabel;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UIButton *acceptButton;
@property (weak, nonatomic) IBOutlet UIButton *denyButton;
@property (nonatomic, weak) PFUser *user;
@property (nonatomic, weak) Friendship *currentUserFriendship;
@property (nonatomic, weak) Friendship *cellUserFriendship;
@property (nonatomic, weak) id <FriendRequestCellDelegate > delegate;
@property (nonatomic, weak) NSIndexPath *indexPath;
@end

NS_ASSUME_NONNULL_END
