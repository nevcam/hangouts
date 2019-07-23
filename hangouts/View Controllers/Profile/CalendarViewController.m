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
    [cell configureCell:self.events[indexPath.section]];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    return cell;
}
- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return self.events.count;
}
- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    // Will do this for now, but should use singleton to instantiate date formatter
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"EEEE MMMM d, Y"];
    Event *event = [self.events objectAtIndex:section];
    NSDate *date = event.date;
    NSString *sectionTitle = [formatter stringFromDate:date];
    return sectionTitle;
}
@end
