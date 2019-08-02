//
//  ProfileFriendsCollectionViewCell.h
//  hangouts
//
//  Created by josemurillo on 8/2/19.
//  Copyright © 2019 nev. All rights reserved.
//

#import <UIKit/UIKit.h>
@import Parse;

NS_ASSUME_NONNULL_BEGIN

@interface ProfileFriendsCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (nonatomic, weak) PFUser *user;

@end

NS_ASSUME_NONNULL_END
