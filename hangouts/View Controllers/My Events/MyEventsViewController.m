//
//  MyEventsViewController.m
//  hangouts
//
//  Created by sroman98 on 7/18/19.
//  Copyright © 2019 nev. All rights reserved.
//

#import "MyEventsViewController.h"
#import "UserEvents.h"
#import "EventCell.h"
@import Parse;

@interface MyEventsViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *invitedTableView;
@property (weak, nonatomic) IBOutlet UITableView *acceptedTableView;

@property (nonatomic, strong) NSMutableArray *invitedEvents;
@property (nonatomic, strong) NSMutableArray *acceptedEvents;

@end

@implementation MyEventsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.invitedTableView.dataSource = self;
    self.invitedTableView.delegate = self;
    
    [self fetchEventsInvited];
}

// MARK: Getting data
- (void)fetchEventsInvited {
    // construct query
    PFQuery *userEventQuery = [UserEvents query];
    [userEventQuery whereKey:@"username" equalTo:[PFUser currentUser].username];
    [userEventQuery whereKey:@"type" equalTo:@"invited"];
    
    PFQuery *eventQuery = [Event query];
    [eventQuery whereKey:@"objectId" matchesKey:@"eventId" inQuery:userEventQuery];
    
    // fetch data asynchronously
    [eventQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable events, NSError * _Nullable error) {
        if (!error) {
            NSLog(@"Successfully loaded invited events.");
            self.invitedEvents = [[NSMutableArray alloc] initWithArray:events];
            [self.invitedTableView reloadData];
        } else {
            NSLog(@"Error getting events: %@", error.localizedDescription);
        }
    }];
}

// MARK: Table view protocols methods
- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    EventCell *cell = [tableView dequeueReusableCellWithIdentifier:@"EventCell"];
    Event *event = self.invitedEvents[indexPath.row];
    [cell configureCell:event];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.invitedEvents.count;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
