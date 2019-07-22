//
//  MyEventsViewController.m
//  hangouts
//
//  Created by sroman98 on 7/18/19.
//  Copyright © 2019 nev. All rights reserved.
//

#import "MyEventsViewController.h"
#import "UserXEvent.h"
#import "EventCell.h"
@import Parse;

@interface MyEventsViewController () <UITableViewDataSource, UITableViewDelegate, EventCellDelegate>
@property (weak, nonatomic) IBOutlet UITableView *invitedTableView;
@property (weak, nonatomic) IBOutlet UITableView *acceptedTableView;

@property (nonatomic, strong) NSMutableArray *invitedEvents;
@property (nonatomic, strong) NSMutableArray *acceptedEvents;

@property (nonatomic, strong) UIRefreshControl *invitedRefreshControl;
@end

@implementation MyEventsViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.invitedTableView.dataSource = self;
    self.invitedTableView.delegate = self;
    
    self.acceptedTableView.dataSource = self;
    self.acceptedTableView.delegate = self;
    
    [self fetchEventsOfType:@"invited"];
    [self fetchEventsOfType:@"accepted"];
    
    self.invitedRefreshControl = [[UIRefreshControl alloc] init];
    [self.invitedRefreshControl addTarget:self action:@selector(fetchInvitedEvents) forControlEvents:UIControlEventValueChanged];
    [self.invitedTableView insertSubview:self.invitedRefreshControl atIndex:0];
}
// MARK: Getting data
- (void)fetchEventsOfType:(NSString *)type {
    PFQuery *userXEventQuery = [UserXEvent query];
    [userXEventQuery whereKey:@"username" equalTo:[PFUser currentUser].username];
    [userXEventQuery whereKey:@"type" equalTo:type];
    
    PFQuery *eventQuery = [Event query];
    [eventQuery whereKey:@"objectId" matchesKey:@"eventId" inQuery:userXEventQuery];
    
    [eventQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable events, NSError * _Nullable error) {
        [self.invitedRefreshControl endRefreshing];
        if (events) {
            if([type isEqualToString:@"accepted"]) {
                self.acceptedEvents = [[NSMutableArray alloc] initWithArray:events];
                [self.acceptedTableView reloadData];
            } else {
                self.invitedEvents = [[NSMutableArray alloc] initWithArray:events];
                [self.invitedTableView reloadData];
            }
        } else {
            NSLog(@"Error getting events: %@", error.localizedDescription);
        }
    }];
}
// Had to add the following two methods to use refresh control (cannot pass arguments in @selector)
- (void)fetchInvitedEvents {
    [self fetchEventsOfType:@"invited"];
}
- (void)changedUserXEventTypeTo:(NSString *)type {
    if([type isEqualToString:@"accepted"]) {
        [self fetchEventsOfType:@"accepted"];
    }
    [self fetchEventsOfType:@"invited"];
}
// MARK: Table view protocols methods
- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    NSString *cellIdentifier;
    Event *event;
    if(tableView == self.acceptedTableView) {
        cellIdentifier = @"AcceptedEventCell";
        event = self.acceptedEvents[indexPath.row];
    } else {
        cellIdentifier = @"InvitedEventCell";
        event = self.invitedEvents[indexPath.row];
    }
    EventCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    [cell configureCell:event];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    cell.delegate = self;
    return cell;
}
- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(tableView == self.acceptedTableView) {
        return self.acceptedEvents.count;
    }
    return self.invitedEvents.count;
}
@end
