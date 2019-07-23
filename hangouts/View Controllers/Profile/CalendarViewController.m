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
@property (strong, nonatomic) NSMutableArray *eventArray;

@end

@implementation CalendarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self fetchCalendarEvents];
}

#pragma mark -  Fetch info methods

- (void)fetchCalendarEvents {
    PFQuery *userXEventQuery = [UserXEvent query];
    [userXEventQuery whereKey:@"username" equalTo:[PFUser currentUser].username];
    [userXEventQuery whereKey:@"type" notEqualTo:@"declined"];
    
    PFQuery *eventQuery = [Event query];
    [eventQuery whereKey:@"objectId" matchesKey:@"eventId" inQuery:userXEventQuery];
    [eventQuery orderByAscending:@"date"];
    
    [eventQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable events, NSError * _Nullable error) {
        if (events) {
            [self initArrayWithEvents:events];
            [self.tableView reloadData];
        } else {
            NSLog(@"Error getting events: %@", error.localizedDescription);
        }
    }];
}

#pragma mark -  Table View protocol methods

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    EventCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"CalendarEventCell"];
    NSArray *array = self.eventArray[indexPath.section];
    [cell configureCell:array[indexPath.row]];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.eventArray[section] count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.eventArray count];
}

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    // Will do this for now, but should use singleton to instantiate date formatter
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"EEEE MMMM d, Y"];
    NSArray *array = [self.eventArray objectAtIndex:section];
    Event *event = array[0];
    NSDate *date = event.date;
     return [self getDayStringOfDate:date];
}

#pragma mark -  Date methods

- (NSString *) getDayStringOfDate:(NSDate *)date {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"EEEE MMMM d, Y"];
    return [formatter stringFromDate:date];
}

- (void)initArrayWithEvents:(NSArray *)events {
    self.eventArray = [[NSMutableArray alloc] init];
    NSString *pastKey = @"";
    int i = -1;
    for (Event *event in events) {
        NSDate *date = event.date;
        NSString *key = [self getDayStringOfDate:date];
        if([pastKey isEqualToString:key]) {
            NSMutableArray *array = self.eventArray[i];
            [array addObject:event];
        } else {
            i++;
            pastKey = key;
            NSMutableArray *array = [NSMutableArray arrayWithObject:event];
            [self.eventArray addObject:array];
        }
    }
}

@end
