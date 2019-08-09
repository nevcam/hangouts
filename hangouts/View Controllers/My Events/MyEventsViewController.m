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
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (weak, nonatomic) IBOutlet UIView *segmentedContainerView;
@property (weak, nonatomic) IBOutlet UIImageView *noDataImage;


@end

@implementation MyEventsViewController {
    NSMutableArray *_invitedUserXEvents;
    NSMutableArray *_acceptedUserXEvents;
    NSMutableArray *_ownedUserXEvents;
    UIRefreshControl *_invitedRefreshControl;
    UIRefreshControl *_acceptedRefreshControl;
    UIView *_buttonBar;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _noDataImage.hidden = YES;
    
    _invitedTableView.dataSource = self;
    _invitedTableView.delegate = self;
    
    [self designSegmentedControl];
   
    [_invitedTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    [self fetchInvitedEvents];
    
    _invitedRefreshControl = [[UIRefreshControl alloc] init];
    [_invitedRefreshControl addTarget:self action:@selector(fetchInvitedEvents) forControlEvents:UIControlEventValueChanged];
    [_invitedTableView insertSubview:_invitedRefreshControl atIndex:0];
    
}

#pragma mark - Segmented Control Methods

- (void)designSegmentedControl {
    _segmentedControl.translatesAutoresizingMaskIntoConstraints = NO;
    _segmentedControl.backgroundColor = [UIColor clearColor];
    _segmentedControl.tintColor = [UIColor clearColor];
    NSMutableDictionary *attributesDictionaryNormal = [NSMutableDictionary dictionary];
    [attributesDictionaryNormal setObject:[UIFont systemFontOfSize:18] forKey:NSFontAttributeName];
    [attributesDictionaryNormal setObject:[UIColor lightGrayColor] forKey:NSForegroundColorAttributeName];
    [_segmentedControl setTitleTextAttributes:attributesDictionaryNormal forState:UIControlStateNormal];
    NSMutableDictionary *attributesDictionarySelected = [NSMutableDictionary dictionary];
    [attributesDictionarySelected setObject:[UIFont systemFontOfSize:18] forKey:NSFontAttributeName];
    [attributesDictionarySelected setObject:[UIColor colorWithRed:0.40 green:0.11 blue:0.75 alpha:1.0] forKey:NSForegroundColorAttributeName];
    [_segmentedControl setTitleTextAttributes:attributesDictionarySelected forState:UIControlStateSelected];
    
    _buttonBar = [UIView new];
    _buttonBar.translatesAutoresizingMaskIntoConstraints = NO;
    _buttonBar.backgroundColor = [UIColor colorWithRed:0.40 green:0.11 blue:0.75 alpha:1.0];
    [_segmentedContainerView addSubview:_buttonBar];
    [_segmentedContainerView addConstraint:[NSLayoutConstraint constraintWithItem:_buttonBar attribute:NSLayoutAttributeTop  relatedBy:NSLayoutRelationEqual toItem:_segmentedControl attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
    [_segmentedContainerView addConstraint:[NSLayoutConstraint constraintWithItem:_buttonBar attribute:NSLayoutAttributeHeight  relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:5]];
    [_segmentedContainerView addConstraint:[NSLayoutConstraint constraintWithItem:_buttonBar attribute:NSLayoutAttributeLeft  relatedBy:NSLayoutRelationEqual toItem:_segmentedControl attribute:NSLayoutAttributeLeft multiplier:1 constant:0]];
    [_segmentedContainerView addConstraint:[NSLayoutConstraint constraintWithItem:_buttonBar attribute:NSLayoutAttributeWidth  relatedBy:NSLayoutRelationEqual toItem:_segmentedControl attribute:NSLayoutAttributeWidth multiplier:1/3 constant:_segmentedControl.frame.size.width/3]];
}

- (IBAction)didChangeSegment {
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.3 animations:^{self->_buttonBar.alpha = 1;} completion:^(BOOL finished) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if(strongSelf) {
            CGRect myFrame = strongSelf->_buttonBar.frame;
            myFrame.origin.x = (strongSelf->_segmentedControl.frame.size.width / self->_segmentedControl.numberOfSegments) * strongSelf->_segmentedControl.selectedSegmentIndex;
            strongSelf->_buttonBar.frame = myFrame;
            if (strongSelf->_segmentedControl.selectedSegmentIndex==1) {
                [self fetchAcceptedEvents];
            } else if (strongSelf->_segmentedControl.selectedSegmentIndex==2) {
                [self fetchOwnedEvents];
            } else {
                [self fetchInvitedEvents];
            }
            [strongSelf.invitedTableView reloadData];
        }
    }];
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
            NSArray *descriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"event.date" ascending:YES]];
            NSArray *sortedArray = [events sortedArrayUsingDescriptors:descriptors];
            if(strongSelf) {
                [strongSelf->_invitedRefreshControl endRefreshing];
                strongSelf->_invitedUserXEvents = [[NSMutableArray alloc] initWithArray:[self removeOldEvents:sortedArray]];
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
            NSArray *descriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"event.date" ascending:YES]];
            NSArray *sortedArray = [events sortedArrayUsingDescriptors:descriptors];
            if(strongSelf) {
                [strongSelf->_acceptedRefreshControl endRefreshing];
                strongSelf->_acceptedUserXEvents = [[NSMutableArray alloc] initWithArray:[self removeOldEvents:sortedArray]];
                [strongSelf.invitedTableView reloadData];
                
            }
        } else {
            NSLog(@"Error getting events: %@", error.localizedDescription);
        }
    }];
}

- (void)fetchOwnedEvents {
    PFQuery *ownedUserXEventQuery = [UserXEvent query];
    [ownedUserXEventQuery whereKey:@"user" equalTo:[PFUser currentUser]];
    [ownedUserXEventQuery whereKey:@"type" equalTo:@"owned"];
    
    PFQuery *userXEventQuery = [PFQuery orQueryWithSubqueries:@[ownedUserXEventQuery]];
    [userXEventQuery includeKey:@"event"];
    [userXEventQuery selectKeys:[NSArray arrayWithObjects:@"event", @"type", nil]];
    
    __weak typeof(self) weakSelf = self;
    [userXEventQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable events, NSError * _Nullable error) {
        if (events) {
            __strong typeof(weakSelf) strongSelf = self;
            NSArray *descriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"event.date" ascending:YES]];
            NSArray *sortedArray = [events sortedArrayUsingDescriptors:descriptors];
            if(strongSelf) {
                strongSelf->_ownedUserXEvents = [[NSMutableArray alloc] initWithArray:[self removeOldEvents:sortedArray]];
                [strongSelf.invitedTableView reloadData];
            }
        } else {
            NSLog(@"Error getting events: %@", error.localizedDescription);
        }
    }];
}

- (NSMutableArray *)removeOldEvents:(NSArray *)eventArray {
    NSMutableArray *mutableEventArray = [NSMutableArray new];
    NSDate *today = [NSDate date];
    for (UserXEvent *event in eventArray) {
        if ([today compare:event[@"event"][@"date"]] == NSOrderedAscending) {
            [mutableEventArray addObject:event];
        }
    }
    return mutableEventArray;
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
    if(_segmentedControl.selectedSegmentIndex==1) {
        cellIdentifier = @"AcceptedEventCell";
        userXEvent = _acceptedUserXEvents[indexPath.row];
    } else if(_segmentedControl.selectedSegmentIndex==2) {
        cellIdentifier = @"OwnedEventCell";
        userXEvent = _ownedUserXEvents[indexPath.row];
    } else {
        cellIdentifier = @"InvitedEventCell";
        userXEvent = _invitedUserXEvents[indexPath.row];
    }
    Event *event = userXEvent.event;
    EventCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    [cell configureCell:event withType:userXEvent.type];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    cell.delegate = self;
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        cell.preservesSuperviewLayoutMargins = NO;
    }
    cell.separatorInset = UIEdgeInsetsMake(0.f, 0.f, 0.f, cell.bounds.size.width);
    if([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        cell.layoutMargins = UIEdgeInsetsZero;
    }    
    cell.cellView.layer.cornerRadius = 5;
    cell.cellView.layer.masksToBounds = true;
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(_segmentedControl.selectedSegmentIndex==1) {
        return _acceptedUserXEvents.count;
    } else if(_segmentedControl.selectedSegmentIndex==2) {
        return _ownedUserXEvents.count;
    } else {
        return _invitedUserXEvents.count;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger numOfSections = 1;
    if ([_invitedUserXEvents count] == 0 && _segmentedControl.selectedSegmentIndex==0)
    {
//        UILabel *noDataLabel         = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.invitedTableView.bounds.size.width, self.invitedTableView.bounds.size.height)];
//        noDataLabel.text             = @"No invites!";
//        noDataLabel.textColor        = [UIColor blackColor];
//        noDataLabel.textAlignment    = NSTextAlignmentCenter;
//        self.invitedTableView.backgroundView = noDataLabel;
        // _noDataImage.hidden = NO;
    } else if ([_acceptedUserXEvents count] == 0 && _segmentedControl.selectedSegmentIndex==1)
    {
//        UILabel *noDataLabel         = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.invitedTableView.bounds.size.width, self.invitedTableView.bounds.size.height)];
//        noDataLabel.text             = @"No hangouts!";
//        noDataLabel.textColor        = [UIColor blackColor];
//        noDataLabel.textAlignment    = NSTextAlignmentCenter;
//        self.invitedTableView.backgroundView = noDataLabel;
        // _noDataImage.hidden = NO;
    } else if ([_ownedUserXEvents count] == 0 && _segmentedControl.selectedSegmentIndex==2)
    {
//        UILabel *noDataLabel         = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.invitedTableView.bounds.size.width, self.invitedTableView.bounds.size.height)];
//        noDataLabel.text             = @"You have not created any hangouts yet!";
//        noDataLabel.textColor        = [UIColor blackColor];
//        noDataLabel.textAlignment    = NSTextAlignmentCenter;
//        self.invitedTableView.backgroundView = noDataLabel;
        // _noDataImage.hidden = NO;
    } else {
        self.invitedTableView.backgroundView = nil;
        _noDataImage.hidden = YES;
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
         indexPath = [_invitedTableView indexPathForCell:tappedCell];
         userxevent = _acceptedUserXEvents[indexPath.row];
     } else if ([segue.identifier isEqualToString:@"InvitedEventDetailsSegue"]) {
         indexPath = [_invitedTableView indexPathForCell:tappedCell];
         userxevent = _invitedUserXEvents[indexPath.row];
     } else if ([segue.identifier isEqualToString:@"OwnedEventDetailsSegue"]) {
         indexPath = [_invitedTableView indexPathForCell:tappedCell];
         userxevent = _ownedUserXEvents[indexPath.row];
     }
     Event *event = userxevent.event;
     EventTabBarController *tabBarViewControllers = [segue destinationViewController];
     UINavigationController *navController = tabBarViewControllers.viewControllers[0];
     EventDetailsViewController *destinationViewController = (EventDetailsViewController *)navController.topViewController;
     destinationViewController.event = event;
     destinationViewController.delegate = self;
 }

@end
