//
//  EventCell.m
//  hangouts
//
//  Created by sroman98 on 7/18/19.
//  Copyright © 2019 nev. All rights reserved.
//

@import Parse;
#import "EventCell.h"
#import "UserXEvent.h"
#import "DateFormatterManager.h"

@implementation EventCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void) configureCell:(Event *)event {
    self.event = event;
    self.nameLabel.text = event.name;
    DateFormatterManager *manager = [DateFormatterManager sharedDateFormatter];
    [manager.formatter setDateFormat:@"EEE MMM dd"];
    self.dateLabel.text = [manager.formatter stringFromDate:event.date];
    self.locationLabel.text = event.location_name;
    self.ownerUsernameLabel.text = [NSString stringWithFormat:@"@%@",event.ownerUsername];
    self.descriptionLabel.text = event.eventDescription;
}

- (void)configureCell:(Event *)event withType:(NSString *)type {
    [self configureCell:event];
    if([type isEqualToString:@"invited"]) {
        [self.acceptButton setHidden:NO];
        [self.declineButton setHidden:NO];
    } else {
        [self.acceptButton setHidden:YES];
        [self.declineButton setHidden:YES];
    }
}

#pragma mark -  buttons methods

- (void)updateType: (NSString *)type {
    PFQuery *userXEventQuery = [UserXEvent query];
    [userXEventQuery whereKey:@"event" equalTo:self.event];
    [userXEventQuery whereKey:@"user" equalTo:[PFUser currentUser]];
    
    [userXEventQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable userXEvents, NSError * _Nullable error) {
        if (userXEvents) {
            UserXEvent *userXEvent = [userXEvents objectAtIndex:0];
            userXEvent[@"type"] = type;
            [UserXEvent saveAllInBackground:userXEvents block:^(BOOL succeeded, NSError * _Nullable error) {
                if(!error) {
                    [self.delegate changedUserXEventTypeTo:type];
                } else {
                    NSLog(@"Unable to update event type");
                }
            }];
        } else {
            NSLog(@"Error getting events: %@", error.localizedDescription);
        }
    }];
}

- (IBAction)didTapDecline:(id)sender {
    [self updateType:@"declined"];
}

- (IBAction)didTapAccept:(id)sender {
    [self updateType:@"accepted"];
}

@end
