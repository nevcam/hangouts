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
@property (weak, nonatomic) IBOutlet UIImageView *noDataImage;
@property (weak, nonatomic) IBOutlet UILabel *noDataLabel;
@property (weak, nonatomic) IBOutlet UIButton *addFriendButton;
@property (weak, nonatomic) IBOutlet UIButton *declineFriendButton;
@property (weak, nonatomic) IBOutlet UILabel *friendsLabel;
@property (weak, nonatomic) IBOutlet UILabel *availabilityLabel;
@property (weak, nonatomic) IBOutlet UITextView *availabilityLineView;


@end

@implementation PersonProfileViewController
{
    NSMutableArray *_friendUsers;
    NSMutableArray *_currentUserFriends;
    NSMutableArray *_filteredUsers;
    NSMutableArray *_userSchedule;
    NSPointerArray *_currentUserIncomingRequests;
    NSPointerArray *_currentUserOutgoingRequests;
    Friendship *_userFriendship;
    bool friendsListChanged;
}

#pragma mark - Set Profile Basic Features
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self executeMainFunctions];
}

- (void)executeMainFunctions
{
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    _tableView.dataSource = self;
    _tableView.delegate = self;
    
    [self getCurrentUserFriends];
    _filteredUsers = [NSMutableArray new];
    [self getCurrentUserFriendship];
    
    [self setProfileFeatures];
    
    [self eventsUserInfo];
    
    [self fetchFriends];
    [self setButtonColors:YES];
    
}

- (void)setProfileFeatures
{
   [self areFriendsWithStatus:YES];
    
    _usernameLabel.text = [NSString stringWithFormat:@"@%@", _user[@"username"]];
    _fullnameLabel.text = _user[@"fullname"];
    _bioLabel.text = _user[@"bio"];
    _noDataLabel.text = [NSString stringWithFormat:@"%@ has no plans today! Organize a hangout now!", _user[@"fullname"]];
    
    _declineFriendButton.hidden = YES;
    _addFriendButton.hidden = YES;
    
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
                        strongSelf->_friendUsers = [NSMutableArray new];
                        [strongSelf->_friendUsers addObjectsFromArray:friends];
                        strongSelf->_filteredUsers = [NSMutableArray new];

                        [strongSelf->_filteredUsers addObjectsFromArray:friends];
                        [strongSelf.collectionView reloadData];
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
    if (![user.objectId isEqualToString:[PFUser currentUser].objectId]) {
        _user = user;
        _friendUsers = nil;
        _filteredUsers = nil;
        _userSchedule = nil;
        _userFriendship = nil;
        [self executeMainFunctions];
    }
    else {
        [self.navigationController popViewControllerAnimated:YES];
    }
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

- (void)getCurrentUserFriends
{
    if ([_delegate saveFriendsList] && !friendsListChanged) {
        _currentUserFriends = [[NSMutableArray alloc] initWithArray:[_delegate saveFriendsList]];
    }
    // If currentUserFriends has not been provided by a delegate method, query is carried out to get them.
    else {
        [self fetchFriendsQuery];
    }
}

// Method only called when friends have not been provided through delegate method
- (void)fetchFriendsQuery
{
    PFQuery *query = [Friendship query];
    [query whereKey:@"user" equalTo:[PFUser currentUser]];
    query.limit = 1;
    
    __weak typeof(self) weakSelf = self;
    [query findObjectsInBackgroundWithBlock:^(NSArray<Friendship *> * _Nullable friendships, NSError * _Nullable error) {
        if (friendships) {
            NSArray *friendPointers = friendships[0][@"friends"];
            NSMutableArray *friendIds = [NSMutableArray new];
            
            for (PFUser *friendPointer in friendPointers) {
                [friendIds addObject:friendPointer.objectId];
            }
            
            PFQuery *query = [PFUser query];
            [query orderByAscending:@"fullname"];
            [query whereKey:@"objectId" containedIn:friendIds];
            
            [query findObjectsInBackgroundWithBlock:^(NSArray<PFUser *> * _Nullable friends, NSError * _Nullable error) {
                if (friends) {
                    
                    __strong typeof(self) strongSelf = weakSelf;
                    if (strongSelf) {
                        
                        strongSelf->_currentUserFriends = [[NSMutableArray alloc] init];
                        [strongSelf->_currentUserFriends addObjectsFromArray:friends];
                        
                        // Updates features of view controller
                        [strongSelf.collectionView reloadData];
                        [strongSelf changeFriendButtonLayout];
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
    }
    if ([self checkIfFriend]) {
         [self getTodayEvents];
    }
}

-(void)getTodayEvents
{
    if (_userSchedule) {
        [_tableView reloadData];
        _noDataLabel.hidden = YES;
        _noDataImage.hidden = YES;
        _tableView.hidden = NO;
    } else {
        _tableView.hidden = YES;
        _noDataLabel.hidden = NO;
        _noDataImage.hidden = NO;
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

#pragma mark - Check If Friends

- (void)getCurrentUserFriendship {
    
    PFQuery *query = [Friendship query];
    [query orderByDescending:@"createdAt"];
    [query whereKey:@"user" equalTo:[PFUser currentUser]];
    query.limit = 1;
    
    __weak typeof(self) weakSelf = self;
    [query findObjectsInBackgroundWithBlock:^(NSArray<Friendship *> * _Nullable friendships, NSError * _Nullable error) {
        if (friendships) {
            __strong typeof(self) strongSelf = weakSelf;
            
            if (strongSelf) {
                Friendship *friendship = friendships[0];
                
                strongSelf->_userFriendship = [[Friendship alloc] init];
                strongSelf->_userFriendship = friendship;
                
                strongSelf->_currentUserIncomingRequests = [[NSPointerArray alloc] init];
                strongSelf->_currentUserOutgoingRequests = [[NSPointerArray alloc] init];
                strongSelf->_currentUserIncomingRequests = (NSPointerArray *)friendship.incomingRequests;
                strongSelf->_currentUserOutgoingRequests = (NSPointerArray *)friendship.outgoingRequests;
                
                // Sets friendship status accordingly
                [strongSelf changeFriendButtonLayout];
            }
            else {
                NSLog(@"Error: View Controller has been exited");
            }
        } else {
            NSLog(@"Error: %@", error.localizedDescription);
        }
    }];
}

- (bool)checkIfFriend
{
    for (PFUser *friendUser in _currentUserFriends) {
        if ([friendUser.objectId isEqualToString:_user.objectId]) {
            return YES;
        }
    }
    return NO;
}

- (bool)checkIfRequestedFriend
{
    for (PFUser *requestedFriend in _currentUserOutgoingRequests) {
        if ([requestedFriend.objectId isEqualToString:_user.objectId]) {
            return YES;
        }
    }
    return NO;
}

- (bool)checkIfAskedFriend
{
    for (PFUser *requestedFriend in _currentUserIncomingRequests) {
        if ([requestedFriend.objectId isEqualToString:_user.objectId]) {
            _declineFriendButton.hidden = NO;
            return YES;
        }
    }
    return NO;
}

- (void)changeFriendButtonLayout {
    
    _addFriendButton.hidden = NO;
    
    UIColor *alreadyFriends = [UIColor colorWithRed:0.96 green:0.61 blue:0.58 alpha:1.0];
    UIColor *notFriends = [UIColor colorWithRed:0.81 green:0.95 blue:0.78 alpha:1.0];
     UIColor *requestedFriends = [UIColor colorWithRed:0.89 green:0.87 blue:0.87 alpha:1.0];
    UIColor *acceptFriends = [UIColor colorWithRed:0.65 green:0.88 blue:0.97 alpha:1.0];
    
    if ([self checkIfFriend]) {
        [self changeFriendButtonHelperWithTitle:@"Unfriend" buttonColor:alreadyFriends];
        [self areFriendsWithStatus:NO];
    }
    else if ([self checkIfRequestedFriend]) {
         [self changeFriendButtonHelperWithTitle:@"Requested" buttonColor:requestedFriends];
    }
    else if ([self checkIfAskedFriend]){
        [self changeFriendButtonHelperWithTitle:@"Accept" buttonColor:acceptFriends];
    }
    else {
        [self changeFriendButtonHelperWithTitle:@"Add" buttonColor:notFriends];
    }
}

- (void)changeFriendButtonHelperWithTitle:(NSString *)title buttonColor:(UIColor *)color {
    _addFriendButton.backgroundColor = color;
    [_addFriendButton setTitle:title forState:UIControlStateNormal];
}

// Functionality for friendship status button
- (IBAction)didTapFriendStatus:(id)sender {
    // We hide the button, while dealing with latency
    _addFriendButton.hidden = YES;
    _declineFriendButton.hidden = YES;
    
    if ([[sender titleForState:UIControlStateNormal] isEqualToString:@"Add"]) {
        
        [_userFriendship addObject:_user forKey:@"outgoingRequests"];
        [_userFriendship saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            if (!error) {
            } else {
                NSLog(@"Error: %@", error.localizedDescription);
            }
        }];
        
        [self updateFriendFriendshipObject:@"Add"];
    }
    else if ([[sender titleForState:UIControlStateNormal] isEqualToString:@"Requested"]) {
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Friend Request" message:@"Friend request is on its way!" preferredStyle:(UIAlertControllerStyleAlert)];
        UIAlertAction *tryAgainAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action){
        }];
        [alert addAction:tryAgainAction];
        
        [self presentViewController:alert animated:YES completion:nil];
    }
    else if ([[sender titleForState:UIControlStateNormal] isEqualToString:@"Accept"]) {
        
        [self areFriendsWithStatus:NO];
        
        // Deletes request from user incoming requests
        NSMutableArray *friendRequests = (NSMutableArray *)_userFriendship.incomingRequests;
        for (PFUser *requestFriend in friendRequests) {
            if ([requestFriend.objectId isEqualToString:_user.objectId]) {
                [friendRequests removeObject:requestFriend];
                break;
            }
        }
        _userFriendship.incomingRequests = (NSPointerArray *)friendRequests;
        
        // Adds friend to user friends list
        NSMutableArray *currentUserFriends = (NSMutableArray *)_userFriendship.friends;
        [currentUserFriends addObject:_user];
        _userFriendship.friends = currentUserFriends;
        
        // Saves data for user
        [_userFriendship saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            if (!error) {
            } else {
                NSLog(@"Error: %@", error.localizedDescription);
            }
        }];
        
        // Deletes request from friend outgoing requests
        [self updateFriendFriendshipObject:@"Accept"];
    }
    else if ([[sender titleForState:UIControlStateNormal] isEqualToString:@"Unfriend"])
    {
        NSMutableArray *friends = (NSMutableArray *)_userFriendship.friends;
        for (PFUser *friend in friends) {
            if ([friend.objectId isEqualToString:_user.objectId]) {
                [friends removeObject:friend];
                break;
            }
        }
        _userFriendship.friends = friends;
        
        // Saves data for user
        [_userFriendship saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            if (!error) {
            } else {
                NSLog(@"Error: %@", error.localizedDescription);
            }
        }];
        
        // Deletes request from friend outgoing requests
        [self updateFriendFriendshipObject:@"Unfriend"];
    }
}

- (IBAction)didDeclineFriend:(id)sender
{
    // We hide the button, while dealing with latency
    _declineFriendButton.hidden = YES;
    
    // Deletes request from user incoming requests
    NSMutableArray *friendRequests = (NSMutableArray *)_userFriendship.incomingRequests;
    for (PFUser *requestFriend in friendRequests) {
        if ([requestFriend.objectId isEqualToString:_user.objectId]) {
            [friendRequests removeObject:requestFriend];
            break;
        }
    }
    _userFriendship.incomingRequests = (NSPointerArray *)friendRequests;
    
    // Saves data for user
    [_userFriendship saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (!error) {
        } else {
            NSLog(@"Error: %@", error.localizedDescription);
        }
    }];
    
    // Deletes request from friend outgoing requests
    [self updateFriendFriendshipObject:@"Decline"];
}


- (void)updateFriendFriendshipObject:(NSString *)change
{
    PFQuery *query = [Friendship query];
    [query orderByDescending:@"createdAt"];
    [query whereKey:@"user" equalTo:_user];
    query.limit = 1;
    
    __weak typeof(self) weakSelf = self;
    [query findObjectsInBackgroundWithBlock:^(NSArray<Friendship *> * _Nullable friendships, NSError * _Nullable error) {
        if (friendships) {
            __strong typeof(self) strongSelf = weakSelf;
            
            if (strongSelf) {
                Friendship *friendship = friendships[0];
                
                if ([change isEqualToString:@"Add"]) {
                    NSMutableArray *userRequests = (NSMutableArray *)friendship.incomingRequests;
                    [userRequests addObject:[PFUser currentUser]];
                    friendship.incomingRequests = (NSPointerArray *)userRequests;
                    strongSelf->friendsListChanged = YES;
                }
                else if ([change isEqualToString:@"Accept"] || [change isEqualToString:@"Decline"])
                {
                    NSMutableArray *friendRequests = (NSMutableArray *)friendship.outgoingRequests;
                    for (PFUser *requestFriend in friendRequests) {
                        if ([requestFriend.objectId isEqualToString:[PFUser currentUser].objectId]) {
                            [friendRequests removeObject:requestFriend];
                            break;
                        }
                    }
                    friendship.outgoingRequests = (NSPointerArray *)friendRequests;
                    
                    if ([change isEqualToString:@"Accept"]) {
                        NSMutableArray *currentUserFriends = (NSMutableArray *)friendship.friends;
                        [currentUserFriends addObject:[PFUser currentUser]];
                        friendship.friends = currentUserFriends;
                    }
                }
                else if ([change isEqualToString:@"Unfriend"]) {
                    NSMutableArray *friends = (NSMutableArray *)friendship.friends;
                    for (PFUser *friend in friends) {
                        if ([friend.objectId isEqualToString:[PFUser currentUser].objectId]) {
                            [friends removeObject:friend];
                            strongSelf->friendsListChanged = YES;
                            break;
                        }
                    }
                    
                    friendship.friends = friends;
                }
                
                // Saves changes in database
                [friendship saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                    if (!error) {
                        
                        // Set friends nil in case user only had one friend
                        strongSelf->_friendUsers = nil;
                        strongSelf->_filteredUsers = nil;
                        strongSelf->_userFriendship = nil;
                        strongSelf->_currentUserFriends = nil;
                        strongSelf->_currentUserIncomingRequests = nil;
                        strongSelf->_currentUserOutgoingRequests = nil;
                        
                        // Updates layout of friendship status
                        [strongSelf executeMainFunctions];
                    }
                    else {
                        NSLog(@"Error: View Controller has been exited");
                    }
                }];
            }
            else {
                NSLog(@"Error: View Controller has been exited");
            }
        } else {
            NSLog(@"Error: %@", error.localizedDescription);
        }
    }];
}

#pragma mark - Hide Information

- (void)areFriendsWithStatus:(bool)status {
    
    if (status) {
        // Only shows friends in common
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
        
        _friendsLabel.text = @"Friends in common";
    }
    else {
        _friendsLabel.text = @"Friends";
        
        _filteredUsers = _friendUsers;
        [_collectionView reloadData];
        [self setButtonColors:YES];
    }
    
    // Does not show today's availability
    _tableView.hidden = status;
    _commonFriendsButton.hidden = status;
    _friendsButton.hidden = status;
    _noDataImage.hidden = status;
    _noDataLabel.hidden = status;
    _availabilityLabel.hidden = status;
    _availabilityLineView.hidden = status;
    
    if (!status) {
        if (_userSchedule) {
            _noDataLabel.hidden = YES;
            _noDataImage.hidden = YES;
            _tableView.hidden = NO;
        } else {
            _tableView.hidden = YES;
            _noDataLabel.hidden = NO;
            _noDataImage.hidden = NO;
        }
    }
    
    [_friendsLabel sizeToFit];
}

@end
