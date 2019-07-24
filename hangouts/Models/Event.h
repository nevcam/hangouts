//
//  Event.h
//  hangouts
//
//  Created by josemurillo on 7/17/19.
//  Copyright © 2019 nev. All rights reserved.
//

@import Parse;
#import <Foundation/Foundation.h>

typedef void (^EventCreationCompletionBlock)(NSString *eventID, NSError *error);

@interface Event : PFObject <PFSubclassing>

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong) NSString *ownerUsername;
@property (nonatomic, strong) NSString *eventDescription;
@property (nonatomic, strong) NSNumber *location_lat;
@property (nonatomic, strong) NSNumber *location_lng;
@property (nonatomic, strong) NSString *location_name;
@property (nonatomic, strong) NSString *location_address;
@property (nonatomic, strong) NSMutableArray *friends;

+ (void)createEvent:(NSString *)name
           withDate:(NSDate *)date
    withDescription:(NSString *)description
            withLat:(NSNumber *)lat
            withLng:(NSNumber *)lng
           withName:(NSString *)locName
        withAddress:(NSString *)locAddress
        withFriends:(NSMutableArray *)friends
     withCompletion:(EventCreationCompletionBlock)completion;

@end

