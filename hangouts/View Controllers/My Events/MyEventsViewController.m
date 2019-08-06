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

@interface MyEventsViewController () <UITableViewDataSource, UITableViewDelegate, EventCellDelegate, EditEventControllerDelegate>

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
    PFQuery *acceptedUserXEventQuery = [UserXEvent query];
    [acceptedUserXEventQuery whereKey:@"user" equalTo:[PFUser currentUser]];
    [acceptedUserXEventQuery whereKey:@"type" equalTo:@"accepted"];
    
    PFQuery *ownedUserXEventQuery = [UserXEvent query];
    [ownedUserXEventQuery whereKey:@"user" equalTo:[PFUser currentUser]];
    [ownedUserXEventQuery whereKey:@"type" equalTo:@"owned"];
    
    PFQuery *userXEventQuery = [PFQuery orQueryWithSubqueries:@[acceptedUserXEventQuery,ownedUserXEventQuery]];
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger numOfSections = 1;
    if ([_invitedUserXEvents count] > 0)
    {
        self.invitedTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        self.invitedTableView.backgroundView = nil;
    }
    else if ([_invitedUserXEvents count] == 0)
    {
        UILabel *noDataLabel         = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.invitedTableView.bounds.size.width, self.invitedTableView.bounds.size.height)];
        noDataLabel.text             = @"No invites!";
        noDataLabel.textColor        = [UIColor blackColor];
        noDataLabel.textAlignment    = NSTextAlignmentCenter;
        self.invitedTableView.backgroundView = noDataLabel;
        self.invitedTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    } else if ([_acceptedUserXEvents count] == 0)
    {
        UILabel *noDataLabel         = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.acceptedTableView.bounds.size.width, self.acceptedTableView.bounds.size.height)];
        noDataLabel.text             = @"No events!";
        noDataLabel.textColor        = [UIColor blackColor];
        noDataLabel.textAlignment    = NSTextAlignmentCenter;
        self.acceptedTableView.backgroundView = noDataLabel;
        self.acceptedTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return numOfSections;
}

#pragma mark - Edit Event Controller Delegate Methods

- (void)didEditEvent:(Event *)event {
    [self fetchAcceptedEvents];
}

 #pragma mark - Navigation
 
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
     UITableViewCell *tappedCell = sender;
     NSIndexPath *indexPath;
     UserXEvent *userxevent;
     if ([segue.identifier isEqualToString: @"AcceptedEventDetailsSegue"]) {
         indexPath = [_acceptedTableView indexPathForCell:tappedCell];
         userxevent = _acceptedUserXEvents[indexPath.row];
     } else if ([segue.identifier isEqualToString:@"InvitedEventDetailsSegue"]) {
         indexPath = [_invitedTableView indexPathForCell:tappedCell];
         userxevent = _invitedUserXEvents[indexPath.row];
     }
     Event *event = userxevent.event;
     EventTabBarController *tabBarViewControllers = [segue destinationViewController];
     UINavigationController *navController = tabBarViewControllers.viewControllers[0];
     EventDetailsViewController *destinationViewController = (EventDetailsViewController *)navController.topViewController;
     destinationViewController.event = event;
     destinationViewController.delegate = self;
 }

@end
