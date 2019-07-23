//
//  Friendship.h
//  hangouts
//
//  Created by nev on 7/17/19.
//  Copyright © 2019 nev. All rights reserved.
//

#import <Parse/Parse.h>

NS_ASSUME_NONNULL_BEGIN

@interface Friendship : PFObject<PFSubclassing>

@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSArray *friends;
@property (nonatomic, strong) NSArray *friendRequests;
//
@property (nonatomic, strong) NSArray *outgoingRequests;
@property (nonatomic, strong) NSArray *incomingRequests;
@property (nonatomic, strong) PFUser *user;

+ (void) createFriendshipForUser: (NSString * _Nullable )username withCompletion: (PFBooleanResultBlock  _Nullable)completion;

@end

NS_ASSUME_NONNULL_END
