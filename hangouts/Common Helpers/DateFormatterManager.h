//
//  DateFormatterManager.h
//  hangouts
//
//  Created by sroman98 on 7/23/19.
//  Copyright © 2019 nev. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DateFormatterManager : NSObject {
    NSDateFormatter *formatter;
}

@property (nonatomic, retain) NSDateFormatter *formatter;

+ (id)sharedDateFormatter;

@end

NS_ASSUME_NONNULL_END
