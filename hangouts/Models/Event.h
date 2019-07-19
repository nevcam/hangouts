//
//  Event.h
//  hangouts
//
//  Created by josemurillo on 7/17/19.
//  Copyright © 2019 nev. All rights reserved.
//

@import Parse;
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Event : PFObject <PFSubclassing>

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong) NSString *ownerUsername;
@property (nonatomic, strong) NSString *description;
@property (nonatomic, strong) NSNumber *location_lat;
@property (nonatomic, strong) NSNumber *location_lng;
@property (nonatomic, strong) NSString *location_name;
@property (nonatomic, strong) NSString *location_address;

+ (void) createEvent: (NSString * _Nullable)name withDate: (NSDate * _Nullable)date withDescription:(NSString * _Nullable)description withLat:(NSNumber *)lat withLng:(NSNumber *)lng withName:(NSString *)locName withAddress:(NSString *)locAddress withCompletion: (PFBooleanResultBlock  _Nullable)completion;

@end

NS_ASSUME_NONNULL_END
