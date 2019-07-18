//
//  FriendRequestsViewController.h
//  hangouts
//
//  Created by nev on 7/17/19.
//  Copyright © 2019 nev. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FriendRequestsViewController : UIViewController
@property (nonatomic, weak) NSMutableArray *friendRequests;
@property (nonatomic, weak) NSMutableArray *users;
@end

NS_ASSUME_NONNULL_END
