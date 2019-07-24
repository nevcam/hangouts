//
//  Chat_Message.m
//  hangouts
//
//  Created by nev on 7/22/19.
//  Copyright © 2019 nev. All rights reserved.
//

#import "Chat_Message.h"

@implementation Chat_Message
@dynamic message;
@dynamic user;

+ (nonnull NSString *)parseClassName {
    return @"Chat_Message";
}

@end
