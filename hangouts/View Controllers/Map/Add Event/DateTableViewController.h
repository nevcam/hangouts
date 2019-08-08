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

@end

@interface DateTableViewController : UITableViewController

@property (nonatomic, weak) id<DateTableViewControllerDelegate> delegate;
@property (nonatomic, strong) NSDate *date;

@end

NS_ASSUME_NONNULL_END
