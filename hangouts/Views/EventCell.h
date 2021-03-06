//
//  EventCell.h
//  hangouts
//
//  Created by sroman98 on 7/18/19.
//  Copyright © 2019 nev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Event.h"

NS_ASSUME_NONNULL_BEGIN

@protocol EventCellDelegate

- (void)changedUserXEventTypeTo:(NSString *)type;

@end

@interface EventCell : UITableViewCell

@property (nonatomic, weak) id<EventCellDelegate> delegate;

@property (strong, nonatomic) Event *event;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UILabel *ownerUsernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UIButton *declineButton;
@property (weak, nonatomic) IBOutlet UIButton *acceptButton;
@property (weak, nonatomic) IBOutlet UILabel *ownedLabel;
@property (weak, nonatomic) IBOutlet UIView *cellView;

- (void)configureCell:(Event *)event;

- (void)configureCell:(Event *)event withType:(NSString *)type;

@end

NS_ASSUME_NONNULL_END
