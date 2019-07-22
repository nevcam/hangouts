//
//  CalendarViewController.m
//  hangouts
//
//  Created by sroman98 on 7/22/19.
//  Copyright © 2019 nev. All rights reserved.
//

#import "CalendarViewController.h"
#import "UserXEvent.h"
#import "EventCell.h"
#import "Event.h"
@import Parse;

@interface CalendarViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *events;
@end

@implementation CalendarViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self fetchCalendarEvents];
}
// MARK: Fetch info methods
- (void)fetchCalendarEvents {
    PFQuery *userXEventQuery = [UserXEvent query];
    [userXEventQuery whereKey:@"username" equalTo:[PFUser currentUser].username];
    [userXEventQuery whereKey:@"type" notEqualTo:@"declined"];
    
    PFQuery *eventQuery = [Event query];
    [eventQuery whereKey:@"objectId" matchesKey:@"eventId" inQuery:userXEventQuery];
    [eventQuery orderByAscending:@"date"];
    
    [eventQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable events, NSError * _Nullable error) {
        if (events) {
            NSLog(@"Eventos: %@",events);
            self.events = [[NSMutableArray alloc] initWithArray:events];
            [self.tableView reloadData];
        } else {
            NSLog(@"Error getting events: %@", error.localizedDescription);
        }
    }];
}
// MARK: Table View protocol methods
- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    EventCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"CalendarEventCell"];
    [cell configureCell:self.events[indexPath.row]];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.events.count;
}
@end
