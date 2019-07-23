//
//  UserXEvent.h
//  hangouts
//
//  Created by sroman98 on 7/18/19.
//  Copyright © 2019 nev. All rights reserved.
//

#import <Parse/Parse.h>

NS_ASSUME_NONNULL_BEGIN

@interface UserXEvent : PFObject <PFSubclassing>
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *eventId;
@property (nonatomic, strong) NSString *type;

+ (void) createUserXEventForUser:(NSString *)username withId:(NSString *)eventId withType:(NSString *)type withCompletion:(PFBooleanResultBlock)completion;
@end

NS_ASSUME_NONNULL_END
