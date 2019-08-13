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
    _event = event;
    _nameLabel.text = event.name;
    DateFormatterManager *manager = [DateFormatterManager sharedDateFormatter];
    [manager.formatter setDateFormat:@"EEE MMM dd"];
    _dateLabel.text = [manager.formatter stringFromDate:event.date];
    _locationLabel.text = event.location_name;
    _ownerUsernameLabel.text = [NSString stringWithFormat:@"%@'s hangout",event.ownerUsername];
    _descriptionLabel.text = event.eventDescription;
}

- (void)configureCell:(Event *)event withType:(NSString *)type {
    [self configureCell:event];
    if([type isEqualToString:@"invited"]) {
        [_acceptButton setHidden:NO];
        [_declineButton setHidden:NO];
        [_ownedLabel setHidden:YES];
    } else if ([type isEqualToString:@"owned"]) {
        [_acceptButton setHidden:YES];
        [_declineButton setHidden:YES];
        [_ownedLabel setHidden:NO];
    } else {
        [_acceptButton setHidden:YES];
        [_declineButton setHidden:YES];
        [_ownedLabel setHidden:YES];
    }
}

#pragma mark -  buttons methods

- (void)updateType: (NSString *)type {
    PFQuery *userXEventQuery = [UserXEvent query];
    [userXEventQuery whereKey:@"event" equalTo:_event];
    [userXEventQuery whereKey:@"user" equalTo:[PFUser currentUser]];
    
    __weak typeof(self) weakSelf = self;
    [userXEventQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable userXEvents, NSError * _Nullable error) {
        if (userXEvents) {
            UserXEvent *userXEvent = [userXEvents objectAtIndex:0];
            userXEvent[@"type"] = type;
            [UserXEvent saveAllInBackground:userXEvents block:^(BOOL succeeded, NSError * _Nullable error) {
                __strong typeof(weakSelf) strongSelf = weakSelf;
                if(strongSelf) {
                    if(!error) {
                        [strongSelf.delegate changedUserXEventTypeTo:type];
                    } else {
                        NSLog(@"Unable to update event type");
                    }
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
