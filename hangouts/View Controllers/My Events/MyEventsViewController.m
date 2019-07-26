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
#import "EventDetailsViewController.h"
#import "EventTabBarController.h"
@import Parse;

@interface MyEventsViewController () <UITableViewDataSource, UITableViewDelegate, EventCellDelegate>

@property (weak, nonatomic) IBOutlet UITableView *invitedTableView;
@property (weak, nonatomic) IBOutlet UITableView *acceptedTableView;

@property (nonatomic, strong) NSMutableArray *invitedUserXEvents;
@property (nonatomic, strong) NSMutableArray *acceptedUserXEvents;

@property (nonatomic, strong) UIRefreshControl *invitedRefreshControl;
@property (nonatomic, strong) UIRefreshControl *acceptedRefreshControl;

@end

@implementation MyEventsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.invitedTableView.dataSource = self;
    self.invitedTableView.delegate = self;
    
    self.acceptedTableView.dataSource = self;
    self.acceptedTableView.delegate = self;
    
    [self fetchInvitedEvents];
    [self fetchAcceptedEvents];
    
    self.invitedRefreshControl = [[UIRefreshControl alloc] init];
    [self.invitedRefreshControl addTarget:self action:@selector(fetchInvitedEvents) forControlEvents:UIControlEventValueChanged];
    [self.invitedTableView insertSubview:self.invitedRefreshControl atIndex:0];
    
    self.acceptedRefreshControl = [[UIRefreshControl alloc] init];
    [self.acceptedRefreshControl addTarget:self action:@selector(fetchAcceptedEvents) forControlEvents:UIControlEventValueChanged];
    [self.acceptedTableView insertSubview:self.acceptedRefreshControl atIndex:0];
}

#pragma mark -  Getting data

- (void)fetchInvitedEvents {
    PFQuery *userXEventQuery = [UserXEvent query];
    [userXEventQuery whereKey:@"user" equalTo:[PFUser currentUser]];
    [userXEventQuery whereKey:@"type" equalTo:@"invited"];
    [userXEventQuery includeKey:@"event"];
    [userXEventQuery selectKeys:[NSArray arrayWithObjects:@"event", @"type", nil]];
    
    [userXEventQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable events, NSError * _Nullable error) {
        if (events) {
            [self.invitedRefreshControl endRefreshing];
            self.invitedUserXEvents = [[NSMutableArray alloc] initWithArray:events];
            [self.invitedTableView reloadData];
        } else {
            NSLog(@"Error getting events: %@", error.localizedDescription);
        }
    }];
}

- (void)fetchAcceptedEvents {
    PFQuery *userXEventQuery1 = [UserXEvent query];
    [userXEventQuery1 whereKey:@"user" equalTo:[PFUser currentUser]];
    [userXEventQuery1 whereKey:@"type" equalTo:@"accepted"];
    
    PFQuery *userXEventQuery2 = [UserXEvent query];
    [userXEventQuery2 whereKey:@"user" equalTo:[PFUser currentUser]];
    [userXEventQuery2 whereKey:@"type" equalTo:@"owned"];
    
    PFQuery *userXEventQuery = [PFQuery orQueryWithSubqueries:@[userXEventQuery1,userXEventQuery2]];
    [userXEventQuery includeKey:@"event"];
    [userXEventQuery selectKeys:[NSArray arrayWithObjects:@"event", @"type", nil]];
    
    [userXEventQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable events, NSError * _Nullable error) {
        if (events) {
            [self.acceptedRefreshControl endRefreshing];
            self.acceptedUserXEvents = [[NSMutableArray alloc] initWithArray:events];
            [self.acceptedTableView reloadData];
        } else {
            NSLog(@"Error getting events: %@", error.localizedDescription);
        }
    }];
}

#pragma mark - Even Cell protocol methods

- (void)changedUserXEventTypeTo:(NSString *)type {
    if([type isEqualToString:@"accepted"]) {
        [self fetchAcceptedEvents];
    }
    [self fetchInvitedEvents];
}

#pragma mark -  Table view protocols methods

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    NSString *cellIdentifier;
    UserXEvent *userXEvent;
    if(tableView == self.acceptedTableView) {
        cellIdentifier = @"AcceptedEventCell";
        userXEvent = self.acceptedUserXEvents[indexPath.row];
    } else {
        cellIdentifier = @"InvitedEventCell";
        userXEvent = self.invitedUserXEvents[indexPath.row];
    }
    Event *event = userXEvent.event;
    EventCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    [cell configureCell:event withType:userXEvent.type];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    cell.delegate = self;
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(tableView == self.acceptedTableView) {
        return self.acceptedUserXEvents.count;
    } else {
        return self.invitedUserXEvents.count;
    }
}

 #pragma mark - Navigation
 
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
     if ([segue.identifier  isEqual: @"eventDetailsSegue"]) {
         UITableViewCell *tappedCell = sender;
         NSIndexPath *indexPath = [self.acceptedTableView indexPathForCell:tappedCell];
         UserXEvent *userxevent = self.acceptedUserXEvents[indexPath.row];
         Event *event = userxevent.event;
//         NSLog(@"EVENT %@", event);
         EventTabBarController *tabBarViewControllers = [segue destinationViewController];
         UINavigationController *navController = tabBarViewControllers.viewControllers[0];
         EventDetailsViewController *destinationViewController = (EventDetailsViewController *)navController.topViewController;
         destinationViewController.event = event;
     }
 }

@end
