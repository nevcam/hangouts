//
//  Event.h
//  hangouts
//
//  Created by josemurillo on 7/17/19.
//  Copyright © 2019 nev. All rights reserved.
//

@import Parse;
@class Event;
#import <Foundation/Foundation.h>

typedef void (^EventCreationCompletionBlock)(Event *event, NSError *error);

@interface Event : PFObject <PFSubclassing>

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong) NSString *ownerUsername;
@property (nonatomic, strong) NSString *eventDescription;
@property (nonatomic, strong) NSNumber *location_lat;
@property (nonatomic, strong) NSNumber *location_lng;
@property (nonatomic, strong) NSString *location_name;
@property (nonatomic, strong) NSString *location_address;
@property (nonatomic, strong) PFFileObject *eventPhoto;
@property (nonatomic, strong) NSString *duration;

+ (void)createEvent:(NSString *)name
               date:(NSDate *)date
        description:(NSString *)description
                lat:(NSNumber *)lat
                lng:(NSNumber *)lng
               name:(NSString *)locName
            address:(NSString *)locAddress
              photo:(UIImage * )photo
           duration:(NSString *)duration
     withCompletion:(EventCreationCompletionBlock)completion;

+ (PFFileObject *)getPFFileFromImage: (UIImage * _Nullable)image;

@end

