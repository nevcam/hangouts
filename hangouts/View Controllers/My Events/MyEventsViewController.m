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

@end

@implementation MyEventsViewController {
    NSMutableArray *_invitedUserXEvents;
    NSMutableArray *_acceptedUserXEvents;
    
    UIRefreshControl *_invitedRefreshControl;
    UIRefreshControl *_acceptedRefreshControl;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _invitedTableView.dataSource = self;
    _invitedTableView.delegate = self;
    
    _acceptedTableView.dataSource = self;
    _acceptedTableView.delegate = self;
    
    [self fetchInvitedEvents];
    [self fetchAcceptedEvents];
    
    _invitedRefreshControl = [[UIRefreshControl alloc] init];
    [_invitedRefreshControl addTarget:self action:@selector(fetchInvitedEvents) forControlEvents:UIControlEventValueChanged];
    [_invitedTableView insertSubview:_invitedRefreshControl atIndex:0];
    
    _acceptedRefreshControl = [[UIRefreshControl alloc] init];
    [_acceptedRefreshControl addTarget:self action:@selector(fetchAcceptedEvents) forControlEvents:UIControlEventValueChanged];
    [_acceptedTableView insertSubview:_acceptedRefreshControl atIndex:0];
}

#pragma mark -  Getting data

- (void)fetchInvitedEvents {
    PFQuery *userXEventQuery = [UserXEvent query];
    [userXEventQuery whereKey:@"user" equalTo:[PFUser currentUser]];
    [userXEventQuery whereKey:@"type" equalTo:@"invited"];
    [userXEventQuery includeKey:@"event"];
    [userXEventQuery selectKeys:[NSArray arrayWithObjects:@"event", @"type", nil]];
    
    __weak typeof(self) weakSelf = self;
    [userXEventQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable events, NSError * _Nullable error) {
        if (events) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if(strongSelf) {
                [strongSelf->_invitedRefreshControl endRefreshing];
                strongSelf->_invitedUserXEvents = [[NSMutableArray alloc] initWithArray:events];
                [strongSelf.invitedTableView reloadData];
            }
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
    
    __weak typeof(self) weakSelf = self;
    [userXEventQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable events, NSError * _Nullable error) {
        if (events) {
            __strong typeof(weakSelf) strongSelf = self;
            if(strongSelf) {
                [strongSelf->_acceptedRefreshControl endRefreshing];
                strongSelf->_acceptedUserXEvents = [[NSMutableArray alloc] initWithArray:events];
                [strongSelf.acceptedTableView reloadData];
            }
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
    if(tableView == _acceptedTableView) {
        cellIdentifier = @"AcceptedEventCell";
        userXEvent = _acceptedUserXEvents[indexPath.row];
    } else {
        cellIdentifier = @"InvitedEventCell";
        userXEvent = _invitedUserXEvents[indexPath.row];
    }
    Event *event = userXEvent.event;
    EventCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    [cell configureCell:event withType:userXEvent.type];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    cell.delegate = self;
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(tableView == _acceptedTableView) {
        return _acceptedUserXEvents.count;
    } else {
        return _invitedUserXEvents.count;
    }
}

 #pragma mark - Navigation
 
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
     if ([segue.identifier  isEqual: @"eventDetailsSegue"]) {
         UITableViewCell *tappedCell = sender;
         NSIndexPath *indexPath = [_acceptedTableView indexPathForCell:tappedCell];
         UserXEvent *userxevent = _acceptedUserXEvents[indexPath.row];
         Event *event = userxevent.event;
         EventTabBarController *tabBarViewControllers = [segue destinationViewController];
         UINavigationController *navController = tabBarViewControllers.viewControllers[0];
         EventDetailsViewController *destinationViewController = (EventDetailsViewController *)navController.topViewController;
         destinationViewController.event = event;
     }
 }

@end
