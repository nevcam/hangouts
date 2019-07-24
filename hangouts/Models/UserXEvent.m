//
//  UserXEvent.m
//  hangouts
//
//  Created by sroman98 on 7/18/19.
//  Copyright © 2019 nev. All rights reserved.
//

#import "UserXEvent.h"

@implementation UserXEvent

@dynamic user;
@dynamic event;
@dynamic type;

+ (nonnull NSString *)parseClassName {
    return @"UserXEvent";
}

+ (void) createUserXEventForUser:(PFUser *)user withEvent:(Event *)event withType:(NSString *)type withCompletion:(PFBooleanResultBlock)completion {
    UserXEvent *newUserXEvent = [UserXEvent new];
    newUserXEvent.user = user;
    newUserXEvent.event = event;
    newUserXEvent.type = type;
    
    [newUserXEvent saveInBackgroundWithBlock: completion];
}

@end
