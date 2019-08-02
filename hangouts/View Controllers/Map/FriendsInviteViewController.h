//
//  FriendsInviteViewController.h
//  hangouts
//
//  Created by josemurillo on 7/19/19.
//  Copyright © 2019 nev. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol SaveFriendsListDelegate <NSObject>
- (void)saveFriendsList:(NSMutableArray *)friendsList;
- (void)getFriendPhotos;
@end

@interface FriendsInviteViewController : UIViewController

@property (nonatomic, weak) id <SaveFriendsListDelegate> delegate;
@property (nonatomic, strong) NSMutableArray *invitedFriends;

@end

NS_ASSUME_NONNULL_END
