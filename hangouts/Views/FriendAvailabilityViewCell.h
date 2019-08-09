//
//  FriendAvailabilityViewCell.h
//  hangouts
//
//  Created by josemurillo on 8/6/19.
//  Copyright © 2019 nev. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FriendAvailabilityViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIView *cellView;

@end

NS_ASSUME_NONNULL_END
