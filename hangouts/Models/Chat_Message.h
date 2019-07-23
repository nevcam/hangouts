//
//  Chat_Message.h
//  hangouts
//
//  Created by nev on 7/22/19.
//  Copyright © 2019 nev. All rights reserved.
//

#import <Parse/Parse.h>

NS_ASSUME_NONNULL_BEGIN

@interface Chat_Message : PFObject<PFSubclassing>
@property (nonatomic, strong) NSString *message;
@property (nonatomic, strong) PFUser *user;

@end

NS_ASSUME_NONNULL_END
