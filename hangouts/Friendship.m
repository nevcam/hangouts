//
//  Friendship.m
//  hangouts
//
//  Created by nev on 7/17/19.
//  Copyright © 2019 nev. All rights reserved.
//

#import "Friendship.h"

@implementation Friendship
@dynamic friendRequests;
@dynamic friends;
@dynamic username;

+ (nonnull NSString *)parseClassName {
    return @"Friendship";
}
@end
