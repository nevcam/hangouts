//
//  CalendarViewController.m
//  hangouts
//
//  Created by sroman98 on 7/22/19.
//  Copyright © 2019 nev. All rights reserved.
//

#import "CalendarViewController.h"
#import "DateFormatterManager.h"
#import "UserXEvent.h"
#import "EventCell.h"
#import "Event.h"
@import Parse;

@interface CalendarViewController () <UITableViewDataSource, UITableViewDelegate, EventCellDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation CalendarViewController {
    NSMutableArray *_userXEventOrderedArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    [self fetchCalendarEvents];
}

#pragma mark -  Fetch info methods

- (void)fetchCalendarEvents {
    PFQuery *userXEventQuery = [UserXEvent query];
    [userXEventQuery whereKey:@"user" equalTo:[PFUser currentUser]];
    [userXEventQuery whereKey:@"type" notEqualTo:@"declined"];
    [userXEventQuery includeKey:@"event"];
    [userXEventQuery selectKeys:[NSArray arrayWithObjects:@"event",@"type",nil]];
    
    __weak typeof(self) weakSelf = self;
    [userXEventQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable userXEvents, NSError * _Nullable error) {
        if (userXEvents) {
            NSArray *descriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"event.date" ascending:YES]];
            NSArray *sortedArray = [userXEvents sortedArrayUsingDescriptors:descriptors];
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (strongSelf) {
                [strongSelf initArrayWithEvents:sortedArray];
                [strongSelf.tableView reloadData];
            }
        } else {
            NSLog(@"Error getting events: %@", error.localizedDescription);
        }
    }];
}

#pragma mark -  Table View protocol methods

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    EventCell *cell = [_tableView dequeueReusableCellWithIdentifier:@"CalendarEventCell"];
    NSArray *array = _userXEventOrderedArray[indexPath.section];
    UserXEvent *userXEvent = array[indexPath.row];
    [cell configureCell:userXEvent.event withType:userXEvent.type];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    cell.delegate = self;
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_userXEventOrderedArray[section] count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [_userXEventOrderedArray count];
}

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    DateFormatterManager *manager = [DateFormatterManager sharedDateFormatter];
    [manager.formatter setDateFormat:@"EEEE MMMM d, Y"];
    NSArray *array = [_userXEventOrderedArray objectAtIndex:section];
    UserXEvent *userXEvent = array[0];
    Event *event = userXEvent.event;
    NSDate *date = event.date;
    return [self getDayStringOfDate:date];
}

#pragma mark - Event Cell protocol methods

- (void)changedUserXEventTypeTo:(nonnull NSString *)type {
    [self fetchCalendarEvents];
}

#pragma mark -  Date methods

- (NSString *) getDayStringOfDate:(NSDate *)date {
    DateFormatterManager *manager = [DateFormatterManager sharedDateFormatter];
    [manager.formatter setDateFormat:@"EEEE MMMM d, Y"];
    return [manager.formatter stringFromDate:date];
}

- (void)initArrayWithEvents:(NSArray *)userXEvents {
    _userXEventOrderedArray = [NSMutableArray new];
    NSString *pastKey = @"";
    int i = -1;
    for (UserXEvent *userXEvent in userXEvents) {
        Event *event = userXEvent.event;
        NSDate *date = event.date;
        NSString *key = [self getDayStringOfDate:date];
        if([pastKey isEqualToString:key]) {
            NSMutableArray *array = _userXEventOrderedArray[i];
            [array addObject:userXEvent];
        } else {
            i++;
            pastKey = key;
            NSMutableArray *array = [NSMutableArray arrayWithObject:userXEvent];
            [_userXEventOrderedArray addObject:array];
        }
    }
}

@end
