//
//  FriendRequestsViewController.h
//  hangouts
//
//  Created by nev on 7/17/19.
//  Copyright © 2019 nev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Friendship.h"

NS_ASSUME_NONNULL_BEGIN

@interface FriendRequestsViewController : UIViewController
@property (nonatomic, weak) NSMutableArray *friendRequests;
@property (nonatomic, weak) NSMutableArray *users;
@property (nonatomic, weak) Friendship *currentUserFriendship;
@end

NS_ASSUME_NONNULL_END
