//
//  EventCell.m
//  hangouts
//
//  Created by sroman98 on 7/18/19.
//  Copyright © 2019 nev. All rights reserved.
//

#import "EventCell.h"

@implementation EventCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) configureCell:(Event *)event {
    self.event = event;
    
    self.nameLabel.text = event.name;
    
    // Will do this for now, but should use singleton to instantiate date formatter
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"EEE MMM dd";
    self.dateLabel.text = [formatter stringFromDate:event.date];
    
    self.locationLabel.text = @"900 Hamlin Ct, Sunnyvale";
    self.ownerUsernameLabel.text = event.ownerUsername;
    self.descriptionLabel.text = event.description;
}

@end
