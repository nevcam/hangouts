//
//  Friendship.m
//  hangouts
//
//  Created by nev on 7/17/19.
//  Copyright © 2019 nev. All rights reserved.
//

#import "Friendship.h"

@implementation Friendship

@dynamic username;
@dynamic friends;
@dynamic friendRequests;
@dynamic outgoingRequests;
@dynamic incomingRequests;

@dynamic user;

+ (nonnull NSString *)parseClassName {
    return @"Friendship";
}

+ (void) createFriendshipForUser: (PFUser * _Nullable )user withCompletion: (PFBooleanResultBlock  _Nullable)completion {
    Friendship *newFriendship = [Friendship new];
    newFriendship.user = user;
    
    [newFriendship saveInBackgroundWithBlock:completion];
}

@end
