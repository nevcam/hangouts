//
//  DateFormatterManager.m
//  hangouts
//
//  Created by sroman98 on 7/23/19.
//  Copyright © 2019 nev. All rights reserved.
//

#import "DateFormatterManager.h"

@implementation DateFormatterManager

@synthesize formatter;

#pragma mark Singleton Methods

+ (id)sharedDateFormatter {
    static DateFormatterManager *sharedDateFormatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedDateFormatter = [[self alloc] init];
        NSLog(@"Created new date formatter");
    });
    return sharedDateFormatter;
}

- (id)init {
    if (self = [super init]) {
        formatter = [[NSDateFormatter alloc] init];
    }
    return self;
}

@end
