//
//  Photo.m
//  hangouts
//
//  Created by josemurillo on 7/26/19.
//  Copyright © 2019 nev. All rights reserved.
//

#import "Photo.h"

@implementation Photo

@dynamic photo;
@dynamic user;
@dynamic event;

+ (void) addPhoto:(UIImage * _Nullable )photo
            event:(Event *)event
   withCompletion:(PFBooleanResultBlock  _Nullable)completion {
    
    Photo *newPhoto = [Photo new];
    newPhoto.photo = [self getPFFileFromImage:photo];
    newPhoto.user = [PFUser currentUser];
    newPhoto.event = event;
    
    [newPhoto saveInBackgroundWithBlock: completion];
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

+ (nonnull NSString *)parseClassName {
    return @"Photo";
}

@end
