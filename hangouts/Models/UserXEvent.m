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
@dynamic eventsOwned;
@dynamic eventsAccepted;
@dynamic eventsInvited;

+ (nonnull NSString *)parseClassName {
    return @"UserXEvent";
}

+ (void) createUserXEventForUser:(NSString *)username withCompletion:(PFBooleanResultBlock)completion {
    
    UserXEvent *newUserXEvent = [UserXEvent new];
    newUserXEvent.username = [PFUser currentUser].username;
    
    [newUserXEvent saveInBackgroundWithBlock: completion];
}

@end
