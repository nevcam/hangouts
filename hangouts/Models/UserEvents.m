//
//  UserEvents.m
//  hangouts
//
//  Created by sroman98 on 7/18/19.
//  Copyright © 2019 nev. All rights reserved.
//

#import "UserEvents.h"

@implementation UserEvents

@dynamic username;
@dynamic eventsOwned;
@dynamic eventsAccepted;
@dynamic eventsInvited;

+ (nonnull NSString *)parseClassName {
    return @"userEvents";
}

+ (void) createUserEventsForUser:(NSString *)username withCompletion:(PFBooleanResultBlock)completion {
    
    UserEvents *newUserEvents = [UserEvents new];
    newUserEvents.username = [PFUser currentUser].username;
    
    [newUserEvents saveInBackgroundWithBlock: completion];
}

@end
