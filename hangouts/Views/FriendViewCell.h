//
//  FriendViewCell.h
//  hangouts
//
//  Created by nev on 7/19/19.
//  Copyright © 2019 nev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Parse/Parse.h"
@class FriendViewCell;

NS_ASSUME_NONNULL_BEGIN

@protocol FriendViewCellDelegate <NSObject>
- (void)tapProfile:(FriendViewCell *)friendCell didTap: (PFUser *)user;
@end


@interface FriendViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *profilePhotoView;
@property (weak, nonatomic) IBOutlet UILabel *fullnameLabel;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (nonatomic, weak) PFUser *user;

@property (nonatomic, weak) id <FriendViewCellDelegate > delegate;

@end

NS_ASSUME_NONNULL_END
