//
//  UserXEvent.m
//  hangouts
//
//  Created by sroman98 on 7/18/19.
//  Copyright © 2019 nev. All rights reserved.
//

#import "UserXEvent.h"

@implementation UserXEvent

@dynamic username;
@dynamic eventId;
@dynamic type;

+ (nonnull NSString *)parseClassName {
    return @"UserXEvent";
}

+ (void) createUserXEventForUser:(NSString *)username withId:(NSString *)eventId withType:(NSString *)type withCompletion:(PFBooleanResultBlock)completion {
    UserXEvent *newUserXEvent = [UserXEvent new];
    newUserXEvent.username = username;
    newUserXEvent.eventId = eventId;
    newUserXEvent.type = type;
    
    [newUserXEvent saveInBackgroundWithBlock: completion];
}

@end
