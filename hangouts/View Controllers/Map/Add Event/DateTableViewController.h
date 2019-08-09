//
//  DateTableViewController.h
//  hangouts
//
//  Created by sroman98 on 8/8/19.
//  Copyright © 2019 nev. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol DateTableViewControllerDelegate

- (void)changedStartDateTo:(NSDate *)startDate;
- (void)changedEndDateTo:(NSDate *)endDate;

@end

@interface DateTableViewController : UITableViewController

@property (nonatomic, weak) id<DateTableViewControllerDelegate> delegate;
@property (nonatomic, strong) NSDate *startDate;
@property (nonatomic, strong) NSDate *endDate;

@end

NS_ASSUME_NONNULL_END
