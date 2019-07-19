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
    // Will do this for now, but should use singleton to instantiate date formatter
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"EEE MMM dd";
    self.dateLabel.text = [formatter stringFromDate:event.date];
    self.locationLabel.text = event.location_name;
    self.ownerUsernameLabel.text = [NSString stringWithFormat:@"@%@",event.ownerUsername];
    self.descriptionLabel.text = event.eventDescription;
}
// MARK: buttons methods
- (void)updateType: (NSString *)type {
    PFQuery *userXEventQuery = [UserXEvent query];
    [userXEventQuery whereKey:@"eventId" equalTo:self.event.objectId];
    [userXEventQuery whereKey:@"username" equalTo:[PFUser currentUser].username];
    
    [userXEventQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable userXEvents, NSError * _Nullable error) {
        if (userXEvents) {
            UserXEvent *userXEvent = [userXEvents objectAtIndex:0];
            userXEvent[@"type"] = type;
            [UserXEvent saveAllInBackground:userXEvents block:^(BOOL succeeded, NSError * _Nullable error) {
                if(!error) {
                    [self.delegate changedUserXEventType];
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
