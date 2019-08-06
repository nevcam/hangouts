//
//  ProfileViewController.m
//  hangouts
//
//  Created by sroman98 on 7/17/19.
//  Copyright © 2019 nev. All rights reserved.
//

#import "ProfileViewController.h"
#import "LoginViewController.h"
#import "AppDelegate.h"
#import "UIImageView+AFNetworking.h"
#import "ProfileEditViewController.h"
#import "Friendship.h"
#import "FriendViewCell.h"
#import "PersonProfileViewController.h"
#import "ProfileFriendsCollectionViewCell.h"
#import "DateFormatterManager.h"
#import "UserXEvent.h"
#import "myDayTableViewCell.h"
#import "EventDetailsViewController.h"
#import "EventTabBarController.h"
@import Parse;

@interface ProfileViewController () <ProfileEditViewControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegate, ProfileFriendViewCellDelegate, UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *profilePhotoView;
@property (weak, nonatomic) IBOutlet UILabel *fullnameLabel;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *bioLabel;
@property (weak, nonatomic) IBOutlet UIButton *editProfileButton;
@property (weak, nonatomic) IBOutlet UILabel *friendsCount;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *pastEventsCount;
@property (weak, nonatomic) IBOutlet UILabel *nextEventsCount;
@property (weak, nonatomic) IBOutlet UILabel *ownedEventsCount;
@property (weak, nonatomic) IBOutlet UILabel *noEventsLabel;
@property (weak, nonatomic) IBOutlet UIImageView *noDataImage;
@property (nonatomic, strong) UIRefreshControl *refreshControl;

@end

@implementation ProfileViewController {
    NSMutableArray *_friendUsers;
    NSMutableArray *_friendships;
    NSMutableArray *_userXEventOrderedArray;
    NSMutableArray *_todayEvents;
}

#pragma mark - Load View Controller

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.estimatedRowHeight = 60.0;
    
    [self setUserInfo];
    
    [self fetchFriends];
    [self setCollectionLayout];
    
    [self eventsUserInfo];
    
    [self addRefreshCntrl];
}

- (void)addRefreshCntrl
{
    _refreshControl = [[UIRefreshControl alloc] init];
    [_refreshControl addTarget:self action:@selector(eventsUserInfo) forControlEvents: UIControlEventValueChanged];
    [_tableView insertSubview:_refreshControl atIndex:0];
}

- (void)setUserInfo
{
    _user = [PFUser currentUser];
    _usernameLabel.text = [NSString stringWithFormat:@"@%@", _user[@"username"]];
    _fullnameLabel.text = _user[@"fullname"];
    _bioLabel.text = _user[@"bio"];
    
    PFFileObject *imageFile = _user[@"profilePhoto"];
    NSURL *profilePhotoURL = [NSURL URLWithString:imageFile.url];
    _profilePhotoView.image = nil;
    [_profilePhotoView setImageWithURL:profilePhotoURL];
    _profilePhotoView.layer.cornerRadius = _profilePhotoView.frame.size.height /2;
    _profilePhotoView.layer.masksToBounds = YES;
    _profilePhotoView.layer.borderWidth = 0;
}

- (void)fetchFriends {
    PFQuery *query = [Friendship query];
    [query orderByDescending:@"createdAt"];
    [query whereKey:@"user" equalTo:[PFUser currentUser]];
    [query includeKey:@"user"];
    query.limit = 1;
    
    __weak typeof(self) weakSelf = self;
    [query findObjectsInBackgroundWithBlock:^(NSArray<Friendship *> * _Nullable friendships, NSError * _Nullable error) {
        if (friendships) {
            NSMutableArray *friendPointers = (NSMutableArray *)friendships[0][@"friends"];
            NSMutableArray *friendIds = [NSMutableArray new];
            
            for (PFUser *friendPointer in friendPointers) {
                [friendIds addObject:friendPointer.objectId];
            }
            
            PFQuery *query = [PFUser query];
            [query orderByDescending:@"createdAt"];
            [query whereKey:@"objectId" containedIn:friendIds];
            
            [query findObjectsInBackgroundWithBlock:^(NSArray<PFUser *> * _Nullable friends, NSError * _Nullable error) {
                if (friends) {
                    __strong typeof(weakSelf) strongSelf = weakSelf;
                    if(strongSelf) {
                        if (!strongSelf->_friendships) {
                            strongSelf->_friendships = [NSMutableArray new];
                            strongSelf->_friendUsers = [NSMutableArray new];
                            [strongSelf->_friendships addObjectsFromArray:friends];
                            if (strongSelf->_friendships.count == friendPointers.count) {
                                strongSelf->_friendUsers = strongSelf->_friendships;
                                [strongSelf.collectionView reloadData];
                                strongSelf->_friendsCount.text = [NSString stringWithFormat:@"%lu", (unsigned long)self->_friendships.count];
                            }
                        } else {
                            NSLog(@"Error");
                        }
                    }
                } else {
                    NSLog(@"Error: %@", error.localizedDescription);
                }
            }];
        } else {
            NSLog(@"Error: %@", error.localizedDescription);
        }
    }];
    
}

- (IBAction)didTapEditProfile:(id)sender {
    [self performSegueWithIdentifier:@"profileEditSegue" sender:nil];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier  isEqual: @"profileEditSegue"]){
        PFUser *user = _user;
        ProfileEditViewController *profileEditViewController = [segue destinationViewController];
        profileEditViewController.user = user;
        profileEditViewController.delegate = self;
    }
    else if ([segue.identifier isEqual:@"myProfileToFriendProfileSegue"]) {
        PersonProfileViewController *friendProfileController = segue.destinationViewController;
        friendProfileController.user = sender;
    }
    else if ([segue.identifier isEqualToString:@"eventFromProfileSegue"]) {
        UITableViewCell *tappedCell = sender;
        NSIndexPath *indexPath = [_tableView indexPathForCell:tappedCell];
        Event *event = _todayEvents[indexPath.row];
        
        EventTabBarController *tabBarViewControllers = [segue destinationViewController];
        UINavigationController *navController = tabBarViewControllers.viewControllers[0];
        EventDetailsViewController *destinationViewController = (EventDetailsViewController *)navController.topViewController;
        destinationViewController.event = event;
    }
}


#pragma mark -  logout functions
- (IBAction)didTapLogout:(id)sender {
    [PFUser logOutInBackgroundWithBlock:^(NSError * _Nullable error) {
        // PFUser.current() will now be nil
        if(PFUser.currentUser == nil) {
            AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            LoginViewController *loginViewController = [storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
            appDelegate.window.rootViewController = loginViewController;
        } else {
            NSLog(@"Error logging out: %@", error);
        }
    }];
}

- (void)didSave {
    PFQuery *query = [PFUser query];
    [query orderByDescending:@"createdAt"];
    query.limit = 1;
    [query whereKey:@"username" equalTo:_user[@"username"]];
    
    __weak typeof(self) weakSelf = self;
    [query findObjectsInBackgroundWithBlock:^(NSArray<PFUser *> * _Nullable users, NSError * _Nullable error) {
        if (users) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if(strongSelf) {
                PFUser *user = users[0];
                strongSelf.fullnameLabel.text = user[@"fullname"];
                strongSelf.bioLabel.text = user[@"bio"];
                PFFileObject *imageFile = user[@"profilePhoto"];
                NSURL *photoURL = [NSURL URLWithString:imageFile.url];
                strongSelf.profilePhotoView.image = nil;
                [strongSelf.profilePhotoView setImageWithURL:photoURL];
                strongSelf.profilePhotoView.layer.cornerRadius = strongSelf.profilePhotoView.frame.size.width / 2;
                strongSelf.profilePhotoView.layer.masksToBounds = YES;
                [strongSelf.view addSubview: strongSelf.profilePhotoView];
            }
        } else {
            NSLog(@"Error: %@", error.localizedDescription);
        }
    }];
}

#pragma mark - See Friend's Profile

- (void)tapProfile:(nonnull ProfileFriendsCollectionViewCell *)friendCell didTap:(nonnull PFUser *)user {
    [self performSegueWithIdentifier:@"myProfileToFriendProfileSegue" sender:user];
}

#pragma mark - see friend's profile

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _friendUsers.count;
}

- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    ProfileFriendsCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"FriendProfileViewCell" forIndexPath:indexPath];
    PFUser *user = _friendUsers[indexPath.row];
    cell.user = user;
    
    PFFileObject *imageFile = user[@"profilePhoto"];
    NSURL *profilePhotoURL = [NSURL URLWithString:imageFile.url];
    
    cell.profileImageView.image = nil;
    [cell.profileImageView setImageWithURL:profilePhotoURL];
    cell.profileImageView.layer.cornerRadius = cell.profileImageView.frame.size.height /2;
    cell.profileImageView.layer.masksToBounds = YES;
    cell.profileImageView.layer.borderWidth = 0;
    
    cell.delegate = self;
    
    return cell;
}

- (void)setCollectionLayout
{
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)_collectionView.collectionViewLayout;
    
    // Sets margins between posts, view, and other posts
    layout.minimumInteritemSpacing = 7;
    layout.minimumLineSpacing = 7;
    
    // Sets amount of posters per line
    CGFloat friendsPerColumn = 2;
    
    // Sets post width and height, based on previous values
    CGFloat itemWidth = (_collectionView.frame.size.height - layout.minimumInteritemSpacing * (friendsPerColumn - 1)) / friendsPerColumn;
    CGFloat itemHeight = itemWidth;
    layout.itemSize = CGSizeMake (itemWidth, itemHeight);
}


# pragma mark - My Events Section

- (void)eventsUserInfo
{
    PFQuery *userXEventQuery = [UserXEvent query];
    [userXEventQuery whereKey:@"user" equalTo:[PFUser currentUser]];
    [userXEventQuery whereKey:@"type" containedIn:[NSArray arrayWithObjects: @"accepted", @"owned", nil]];
    [userXEventQuery includeKey:@"event"];
    [userXEventQuery selectKeys:[NSArray arrayWithObjects:@"event",@"type",nil]];

    [userXEventQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable userXEvents, NSError * _Nullable error) {
        if (userXEvents) {
            [self getEventStats:userXEvents];
        } else {
            NSLog(@"Error getting events: %@", error.localizedDescription);
        }
    }];
}

// Method populates events statistics on user profile page
-(void)getEventStats:(NSArray *)myEvents
{
    int pastEvents = 0;
    int nextEvents = 0;
    int ownedEvents = 0;
    NSDate *today = [NSDate date];
    
    for (UserXEvent *myEvent in myEvents) {
        if ([myEvent.type isEqualToString:@"owned"]) {
            ownedEvents++;
        }
        Event *event = myEvent.event;
        NSDate *date = event.date;
        
        NSComparisonResult result = [date compare:today];
        if(result == NSOrderedDescending) {
            pastEvents++;
        } else {
            nextEvents++;
        }
        
        // Get today's events for My Day
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd"];
        NSString *dateWithoutTime = [formatter stringFromDate:date];
        NSString *todayWithoutTime = [formatter stringFromDate:today];
        if ([dateWithoutTime isEqualToString:todayWithoutTime]) {
            if (!_todayEvents) {
                _todayEvents = [NSMutableArray array];
            }
            [_todayEvents addObject:event];
        }
    }
    
    _pastEventsCount.text = [NSString stringWithFormat:@"%d",pastEvents];
    _nextEventsCount.text = [NSString stringWithFormat:@"%d",nextEvents];
    _ownedEventsCount.text = [NSString stringWithFormat:@"%d",ownedEvents];
    
    [self getTodayEvents];
}

-(void)getTodayEvents
{
    if (_todayEvents) {
        [_tableView reloadData];
        [_refreshControl endRefreshing];
        _noEventsLabel.hidden = YES;
        _noDataImage.hidden = YES;
    } else {
        _tableView.hidden = YES;
    }
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    
    myDayTableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:@"myDayTableViewCell"];
    Event *event = _todayEvents[indexPath.row];
    cell.eventNameLabel.text = event.name;
    cell.eventTImeLabel.text = [self getEventTime:event.date];
    cell.eventLocationLabel.text = event.location_name;
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _todayEvents.count;
}

// Helper function that gets time for an event
-(NSString *)getEventTime:(NSDate *)date
{
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:date];
    
    NSString *hour = [NSString stringWithFormat:@"%ld", (long)components.hour];
    NSString *minute = [NSString stringWithFormat:@"%ld", (long)components.minute];
    NSString *eventTime = [NSString stringWithFormat:@"%@:%@", hour, minute];
    return eventTime;
    
}
- (IBAction)clickedCalendar:(id)sender {
    [self performSegueWithIdentifier:@"calendarSegue" sender:nil];
}

@end
