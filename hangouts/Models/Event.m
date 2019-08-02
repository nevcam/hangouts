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
@dynamic eventDescription;
@dynamic location_lat;
@dynamic location_lng;
@dynamic location_name;
@dynamic location_address;
@dynamic eventPhoto;
@dynamic duration;

+ (nonnull NSString *)parseClassName {
    return @"Event";
}

// Method to create events from Add Events view controller
+ (void)createEvent:(NSString *)name
               date:(NSDate *)date
        description:(NSString *)description
                lat:(NSNumber *)lat
                lng:(NSNumber *)lng
               name:(NSString *)locName
            address:(NSString *)locAddress
              photo:(UIImage * )photo
           duration:(NSString *)duration
     withCompletion:(EventCreationCompletionBlock)completion
{
    
    // Assigns features to event
    Event *newEvent = [Event new];
    newEvent.name = name;
    newEvent.date = date;
    newEvent.ownerUsername = [PFUser currentUser].username;
    newEvent.eventDescription = description;
    newEvent.location_address = locAddress;
    newEvent.location_name = locName;
    newEvent.location_lat = lat;
    newEvent.location_lng = lng;
    newEvent.eventPhoto = [self getPFFileFromImage:photo];
    newEvent.duration = duration;
    
    [newEvent saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            completion(newEvent, error);
        } else {
            completion(nil, error);
            NSLog(@"Could not retrieve ObjectId. Error:%@", error);
        }
    }];
}

+ (PFFileObject *)getPFFileFromImage: (UIImage * _Nullable)image {
    
    if (!image) {
        return nil;
    }
    
    NSData *imageData = UIImagePNGRepresentation(image);
    // get image data and check if that is not nil
    if (!imageData) {
        return nil;
    }
    
    return [PFFileObject fileObjectWithName:@"image.png" data:imageData];
}

@end
