//
//  Event.m
//  hangouts
//
//  Created by josemurillo on 7/17/19.
//  Copyright © 2019 nev. All rights reserved.
//

#import "Event.h"

@implementation Event

@dynamic name;
@dynamic date;

+ (nonnull NSString *)parseClassName {
    return @"Event";
}

+ (void) createEvent: (NSString * _Nullable )name withDate: ( NSDate * _Nullable )date withCompletion: (PFBooleanResultBlock  _Nullable)completion {
    
    Event *newEvent = [Event new];
    newEvent.name = name;
    newEvent.date = date;
    
    [newEvent saveInBackgroundWithBlock: completion];
}

@end
