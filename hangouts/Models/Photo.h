//
//  Photo.h
//  hangouts
//
//  Created by josemurillo on 7/26/19.
//  Copyright © 2019 nev. All rights reserved.
//

#import <Parse/Parse.h>
#import "Event.h"

NS_ASSUME_NONNULL_BEGIN

@interface Photo : PFObject<PFSubclassing>

@property (nonatomic, strong) PFFileObject *photo;
@property (nonatomic, strong) PFUser *user;
@property (nonatomic, strong) Event *event;

+ (void) addPhoto:(UIImage * _Nullable )photo
            event:(Event *)event
   withCompletion:(PFBooleanResultBlock  _Nullable)completion;

+ (PFFileObject *)getPFFileFromImage: (UIImage * _Nullable)image;

@end

NS_ASSUME_NONNULL_END
