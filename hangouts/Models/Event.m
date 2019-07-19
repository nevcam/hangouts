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
@dynamic ownerUsername;
@dynamic description;
@dynamic location_lat;
@dynamic location_lng;
@dynamic location_name;
@dynamic location_address;

+ (nonnull NSString *)parseClassName {
    return @"Event";
}

// Method to create events from Add Events view controller
+ (void) createEvent: (NSString * _Nullable )name withDate: (NSDate * _Nullable)date withDescription:(NSString * _Nullable)description withLat:(NSNumber *)lat withLng:(NSNumber *)lng withName:(NSString *)locName withAddress:(NSString *)locAddress withCompletion: (PFBooleanResultBlock  _Nullable)completion {
    
    // Assigns features to event
    Event *newEvent = [Event new];
    newEvent.name = name;
    newEvent.date = date;
    newEvent.ownerUsername = [PFUser currentUser].username;
    newEvent.description = description;
    newEvent.location_address = locAddress;
    newEvent.location_name = locName;
    newEvent.location_lat = lat;
    newEvent.location_lng = lng;
    
    [newEvent saveInBackgroundWithBlock: completion];
}

@end
