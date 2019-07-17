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
//@property (nonatomic, strong) NSString *ownerUsername;
//@property (nonatomic, strong) NSString *description;

+ (void) createEvent: (NSString * _Nullable )name withDate: ( NSDate * _Nullable )date withCompletion: (PFBooleanResultBlock  _Nullable)completion;

@end

NS_ASSUME_NONNULL_END
