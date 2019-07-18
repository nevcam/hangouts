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

+ (nonnull NSString *)parseClassName {
    return @"Friendship";
}

+ (void) createFriendshipForUser: (NSString * _Nullable )username withCompletion: (PFBooleanResultBlock  _Nullable)completion {
    Friendship *newFriendship = [Friendship new];
    newFriendship.username = username;
    
    [newFriendship saveInBackgroundWithBlock:completion];
}
@end
