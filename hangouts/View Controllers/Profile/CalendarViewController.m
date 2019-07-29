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
@import EventKit;
@import EventKitUI;

@interface CalendarViewController () <UITableViewDataSource, UITableViewDelegate, EventCellDelegate, EKEventEditViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation CalendarViewController {
    NSMutableArray *userXEventOrderedArray;
    NSMutableArray *eventArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
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
            typeof(weakSelf) strongSelf = weakSelf; // works with weakself as well (??)
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
    EventCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"CalendarEventCell"];
    NSArray *array = self->userXEventOrderedArray[indexPath.section];
    UserXEvent *userXEvent = array[indexPath.row];
    [cell configureCell:userXEvent.event withType:userXEvent.type];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    cell.delegate = self;
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self->userXEventOrderedArray[section] count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self->userXEventOrderedArray count];
}

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    DateFormatterManager *manager = [DateFormatterManager sharedDateFormatter];
    [manager.formatter setDateFormat:@"EEEE MMMM d, Y"];
    NSArray *array = [self->userXEventOrderedArray objectAtIndex:section];
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
    self->userXEventOrderedArray = [NSMutableArray new];
    self->eventArray = [NSMutableArray new];
    NSString *pastKey = @"";
    int i = -1;
    for (UserXEvent *userXEvent in userXEvents) {
        Event *event = userXEvent.event;
        [self->eventArray addObject:event];
        NSDate *date = event.date;
        NSString *key = [self getDayStringOfDate:date];
        if([pastKey isEqualToString:key]) {
            NSMutableArray *array = self->userXEventOrderedArray[i];
            [array addObject:userXEvent];
        } else {
            i++;
            pastKey = key;
            NSMutableArray *array = [NSMutableArray arrayWithObject:userXEvent];
            [self->userXEventOrderedArray addObject:array];
        }
    }
}

#pragma mark - Sync Calendar methods

- (IBAction)didTapSync:(id)sender {
    EKEventStore *store = [[EKEventStore alloc] init];
    [store requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError * _Nullable error) {
        NSArray *calendars = [store calendarsForEntityType:EKEntityTypeEvent];
        for (EKCalendar *calendar in calendars) {
            if([calendar.title isEqualToString:@"Hangouts"]) {
                for (Event *event in self->eventArray) {
                    EKEvent *ekEvent = [EKEvent eventWithEventStore:store];
                    ekEvent.calendar = calendar;
                    ekEvent.title = event.name;
                    ekEvent.startDate = event.date;
                    ekEvent.endDate = [ekEvent.startDate dateByAddingTimeInterval:(60*60)];;
                    
                    if(![store saveEvent:ekEvent span:EKSpanThisEvent commit:YES error:nil]) {
                        NSLog(@"Could not add event.");
                    }
                }
            }
        }
    }];
    
}

- (void)eventEditViewController:(nonnull EKEventEditViewController *)controller didCompleteWithAction:(EKEventEditViewAction)action {
    NSLog(@"%lu", action);
}

@end
