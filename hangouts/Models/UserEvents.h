//
//  UserEvents.h
//  hangouts
//
//  Created by sroman98 on 7/18/19.
//  Copyright © 2019 nev. All rights reserved.
//

#import <Parse/Parse.h>

NS_ASSUME_NONNULL_BEGIN

@interface UserEvents : PFObject <PFSubclassing>

@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSArray *eventsOwned;
@property (nonatomic, strong) NSArray *eventsAccepted;
@property (nonatomic, strong) NSArray *eventsInvited;

+ (void) createUserEventsForUser: (NSString * _Nullable)username withCompletion: (PFBooleanResultBlock  _Nullable)completion;

@end

NS_ASSUME_NONNULL_END
