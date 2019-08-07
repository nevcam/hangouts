//
//  PersonProfileViewController.m
//  hangouts
//
//  Created by josemurillo on 7/29/19.
//  Copyright © 2019 nev. All rights reserved.
//

#import "PersonProfileViewController.h"
#import "UIImageView+AFNetworking.h"
#import "Friendship.h"
#import "AppDelegate.h"
#import "ProfileFriendsCollectionViewCell.h"
#import "ProfileViewController.h"
#import "FriendAvailabilityViewCell.h"
#import "UserXEvent.h"

@interface PersonProfileViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UITableViewDataSource, UITableViewDelegate, ProfileFriendViewCellDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *profilePhotoView;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *fullnameLabel;
@property (weak, nonatomic) IBOutlet UITextField *bioLabel;
@property (weak, nonatomic) IBOutlet UILabel *pastEventsCount;
@property (weak, nonatomic) IBOutlet UILabel *nextEventsCount;
@property (weak, nonatomic) IBOutlet UILabel *friendsCount;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIButton *friendsButton;
@property (weak, nonatomic) IBOutlet UIButton *commonFriendsButton;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation PersonProfileViewController
{
    NSMutableArray *_friendUsers;
    NSMutableArray *_currentUserFriends;
    NSMutableArray *_filteredUsers;
    NSMutableArray *_userSchedule;
}

#pragma mark - Set Profile Basic Features
- (void)viewDidLoad {
    [super viewDidLoad];
    
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    _tableView.dataSource = self;
    _tableView.delegate = self;
    
    _currentUserFriends = [[NSMutableArray alloc] initWithArray:[self getCurrentUserFriends]];
    _filteredUsers = [[NSMutableArray alloc] init];
    
    [self setProfileFeatures];
    
    [self eventsUserInfo];
    
    [self fetchFriends];
    [self setButtonColors:YES];
}

- (void)setProfileFeatures
{
    _usernameLabel.text = [NSString stringWithFormat:@"@%@", _user[@"username"]];
    _fullnameLabel.text = _user[@"fullname"];
    _bioLabel.text = _user[@"bio"];
    [self setProfileImageLayout];
}

- (void)setProfileImageLayout
{
    PFFileObject *const imageFile = _user[@"profilePhoto"];
    NSURL *const profilePhotoURL = [NSURL URLWithString:imageFile.url];
    _profilePhotoView.image = nil;
    [_profilePhotoView setImageWithURL:profilePhotoURL];
    _profilePhotoView.layer.cornerRadius = self.profilePhotoView.frame.size.height /2;
    _profilePhotoView.layer.masksToBounds = YES;
    _profilePhotoView.layer.borderWidth = 0;
}

#pragma mark - Friends

- (void)fetchFriends
{
    PFQuery *query = [Friendship query];
    [query orderByDescending:@"createdAt"];
    [query whereKey:@"user" equalTo:_user];
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
                        if (!strongSelf->_friendUsers) {
                            strongSelf->_friendUsers = [NSMutableArray new];
                            [strongSelf->_friendUsers addObjectsFromArray:friends];
                            [strongSelf->_filteredUsers addObjectsFromArray:friends];
                            [strongSelf.collectionView reloadData];
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

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    _friendsCount.text = [NSString stringWithFormat:@"%lu", (unsigned long)_filteredUsers.count];
    return _filteredUsers.count;
}

- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    ProfileFriendsCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"FriendProfileViewCell" forIndexPath:indexPath];
    PFUser *user = _filteredUsers[indexPath.row];
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


- (void)tapProfile:(ProfileFriendsCollectionViewCell *)friendCell didTap:(PFUser *)user
{
//    PersonProfileViewController *newProfile = [[ PersonProfileViewController alloc] init];
//    newProfile = self;
//    newProfile.user = user;
//    [self presentViewController:newProfile animated:YES completion:nil];
    
    _user = user;
    _friendUsers = nil;
    _filteredUsers = nil;
    _userSchedule = nil;
    [self viewDidLoad];
}

#pragma mark - Filtering Friends

- (IBAction)clickedFriends:(id)sender
{
    _filteredUsers = _friendUsers;
    [_collectionView reloadData];
    [self setButtonColors:YES];
}

- (IBAction)clickedCommonFriends:(id)sender
{
    _filteredUsers = [NSMutableArray new];
    for (PFUser *friendUser in _friendUsers) {
        for (PFUser *currentUserFriend in _currentUserFriends) {
            if ([friendUser.objectId isEqualToString:currentUserFriend.objectId]) {
                [_filteredUsers addObject:friendUser];
                break;
            }
        }
    }
    
    [_collectionView reloadData];
    [self setButtonColors:NO];
}

- (NSMutableArray *)getCurrentUserFriends
{
    return [_delegate saveFriendsList];
}

- (void)setButtonColors:(bool)defaultColors
{
    UIColor *selected = [UIColor colorWithRed:0.70 green:0.64 blue:0.91 alpha:1.0];
    UIColor *notSelected = [UIColor colorWithRed:0.82 green:0.82 blue:0.85 alpha:1.0];
    
    if (defaultColors) {
        _friendsButton.backgroundColor = selected;
        _commonFriendsButton.backgroundColor = notSelected;
    }
    else {
        _friendsButton.backgroundColor = notSelected;
        _commonFriendsButton.backgroundColor = selected;
    }
}

#pragma mark - Availability TableView

- (void)eventsUserInfo
{
    PFQuery *userXEventQuery = [UserXEvent query];
    [userXEventQuery whereKey:@"user" equalTo:_user];
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
    NSDate *today = [NSDate date];
    
    NSMutableArray *userTodayEventsArray;
    for (UserXEvent *myEvent in myEvents) {
        
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
            if (!userTodayEventsArray) {
                userTodayEventsArray = [NSMutableArray array];
            }
            [userTodayEventsArray addObject:event];
        }
        
    }
    
    _pastEventsCount.text = [NSString stringWithFormat:@"%d",pastEvents];
    _nextEventsCount.text = [NSString stringWithFormat:@"%d",nextEvents];
    
    // Sort array by dates and show them
    if (userTodayEventsArray){
        NSArray *descriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES]];
        NSArray *sortedArray = [userTodayEventsArray sortedArrayUsingDescriptors:descriptors];
        _userSchedule = [[NSMutableArray alloc] initWithArray:sortedArray];
        
        [self getTodayEvents];
    }
}

-(void)getTodayEvents
{
    if (_userSchedule) {
        [_tableView reloadData];
    } else {
    }
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    
    FriendAvailabilityViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:@"availabilityCell"];
    Event *event = _userSchedule[indexPath.row];
    cell.timeLabel.text = [self getEventTime:event.date];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _userSchedule.count;
}

// Helper function that gets time for an event
-(NSString *)getEventTime:(NSDate *)date
{
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:date];
    
    NSString *hour = [self addZeroToTime:[NSString stringWithFormat:@"%ld", (long)components.hour]];
    NSString *minute = [self addZeroToTime:[NSString stringWithFormat:@"%ld", (long)components.minute]];
    NSString *eventTime = [NSString stringWithFormat:@"%@:%@", hour, minute];
    return eventTime;
    
}

-(NSString *)addZeroToTime:(NSString *)time
{
    if (time.length == 1) {
        return [NSString stringWithFormat:@"0%@", time];
    }
    return time;
}

@end
