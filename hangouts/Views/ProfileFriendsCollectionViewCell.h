//
//  ProfileFriendsCollectionViewCell.h
//  hangouts
//
//  Created by josemurillo on 8/2/19.
//  Copyright © 2019 nev. All rights reserved.
//

#import <UIKit/UIKit.h>
@import Parse;
@class ProfileFriendsCollectionViewCell;

@protocol ProfileFriendViewCellDelegate <NSObject>
- (void)tapProfile:(ProfileFriendsCollectionViewCell *)friendCell didTap: (PFUser *)user;
@end

@interface ProfileFriendsCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (nonatomic, weak) PFUser *user;

@property (nonatomic, weak) id <ProfileFriendViewCellDelegate> delegate;

@end

