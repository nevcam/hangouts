//
//  UserXEvent.h
//  hangouts
//
//  Created by sroman98 on 7/18/19.
//  Copyright © 2019 nev. All rights reserved.
//

#import <Parse/Parse.h>
#import "Event.h"

NS_ASSUME_NONNULL_BEGIN

@interface UserXEvent : PFObject <PFSubclassing>

@property (nonatomic, strong) PFUser *user;
@property (nonatomic, strong) Event *event;
@property (nonatomic, strong) NSString *type;

+ (void) createUserXEventForUser:(PFUser *)user withEvent:(Event *)event withType:(NSString *)type withCompletion:(PFBooleanResultBlock)completion;

@end

NS_ASSUME_NONNULL_END
