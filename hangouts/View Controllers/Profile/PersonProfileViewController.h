//
//  PersonProfileViewController.h
//  hangouts
//
//  Created by josemurillo on 7/29/19.
//  Copyright © 2019 nev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Parse/Parse.h"
@class PersonProfileViewController;

@protocol SaveCurrentUserFriendsProtocol <NSObject>
- (NSMutableArray *)saveFriendsList;
@end

@interface PersonProfileViewController : UIViewController

@property (nonatomic, strong) PFUser *user;
@property (nonatomic, weak) id <SaveCurrentUserFriendsProtocol> delegate;

@end

