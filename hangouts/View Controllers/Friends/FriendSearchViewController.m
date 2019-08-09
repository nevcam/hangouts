//
//  FriendSearchViewController.m
//  hangouts
//
//  Created by nev on 7/17/19.
//  Copyright © 2019 nev. All rights reserved.
//

#import "FriendSearchViewController.h"
#import "FriendCell.h"
#import "Parse/Parse.h"
#import "Friendship.h"
#import "FriendRequestsViewController.h"
#import "UIImageView+AFNetworking.h"
#import "FriendRequestCell.h"
#import "PersonProfileViewController.h"

@interface FriendSearchViewController () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, FriendCellDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *requestView;
@property (weak, nonatomic) IBOutlet UILabel *requestCount;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (nonatomic, strong) NSMutableArray *users;
@property (nonatomic, strong) NSMutableArray *filteredUsers;
@property (nonatomic, strong) NSMutableArray *friendships;
@property (nonatomic, strong) NSPointerArray *currentUserIncomingRequests;
@property (nonatomic, strong) NSPointerArray *currentUserOutgoingRequests;
@property (nonatomic, strong) NSMutableArray *currentUserFriends;
@property (nonatomic, strong) Friendship *currentUserFriendship;
@property (nonatomic, strong) NSMutableDictionary *friendshipMap;
@property (weak, nonatomic) IBOutlet UIImageView *friendsImageView;


@end

@implementation FriendSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.searchBar.delegate = self;
    
    UITapGestureRecognizer *singleFingerTap =
    [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleRequestTap:)];
    [self.requestView addGestureRecognizer:singleFingerTap];
    [self getCurrentUserFriendship];
    self.tableView.rowHeight = 80;
    self.tableView.allowsMultipleSelectionDuringEditing = NO;
}

- (void)fetchUsers {
    PFQuery *query = [PFUser query];
    [query orderByDescending:@"createdAt"];
    query.limit = 100;
    [query findObjectsInBackgroundWithBlock:^(NSArray<PFUser *> * _Nullable users, NSError * _Nullable error) {
        if (users) {
            self.users = (NSMutableArray *)users;
            self.filteredUsers = self.users;
            [self getCurrentUserFriendship];
        } else {
            NSLog(@"Error: %@", error.localizedDescription);
        }
    }];
}


- (void)getCurrentUserFriendship {
    // Get current user's friend information to pass it later and show friend request count
    PFQuery *query = [Friendship query];
    [query orderByDescending:@"createdAt"];
    [query whereKey:@"user" equalTo:[PFUser currentUser]];
    query.limit = 1;
    [query findObjectsInBackgroundWithBlock:^(NSArray<Friendship *> * _Nullable friendships, NSError * _Nullable error) {
        if (friendships) {
            Friendship *friendship = friendships[0];
            self.currentUserFriendship = friendship;
            self.currentUserFriends = (NSMutableArray *)friendship.friends;
            self.currentUserIncomingRequests = (NSPointerArray *)friendship.incomingRequests;
            self.currentUserOutgoingRequests = (NSPointerArray *)friendship.outgoingRequests;
            self.requestCount.text = [@(self.currentUserIncomingRequests.count) stringValue];
        } else {
            NSLog(@"Error: %@", error.localizedDescription);
        }
    }];
}

- (void)handleRequestTap:(UITapGestureRecognizer *)recognizer
{
    [self performSegueWithIdentifier:@"requestSegue" sender:nil];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.filteredUsers.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FriendCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FriendCell"];
    PFUser *user = self.filteredUsers[indexPath.row];
    cell.user = user;
    cell.usernameLabel.text = user[@"username"];
    cell.fullnameLabel.text = user[@"fullname"];
    PFFileObject *const imageFile = user[@"profilePhoto"];
    NSURL *const profilePhotoURL = [NSURL URLWithString:imageFile.url];
    cell.profilePhotoView.image = nil;
    [cell.profilePhotoView setImageWithURL:profilePhotoURL];
    cell.profilePhotoView.layer.cornerRadius = cell.profilePhotoView.frame.size.height /2;
    cell.profilePhotoView.layer.masksToBounds = YES;
    cell.profilePhotoView.layer.borderWidth = 0;
    cell.currentUserFriendship = self.currentUserFriendship;

    // For FriendCellDelegate
    cell.delegate = self;
    
    cell.addFriendButton.backgroundColor = [UIColor colorWithRed:0.81 green:0.95 blue:0.78 alpha:1.0];
    
    // checks whether current user is friends with this user
    for (PFUser *friend in self.currentUserFriends){
        if ([friend.objectId isEqualToString:user.objectId]) {
            [cell.addFriendButton setTitle:@"" forState:UIControlStateNormal];
            cell.addFriendButton.enabled = NO;
            cell.addFriendButton.hidden = YES;
            return cell;
        }
    }

    for (PFUser *requestedFriend in self.currentUserOutgoingRequests) {
        if ([requestedFriend.objectId isEqual:user.objectId]) {
            [cell.addFriendButton setTitle:@"Requested" forState:UIControlStateNormal];
            cell.addFriendButton.backgroundColor = [UIColor colorWithRed:0.89 green:0.87 blue:0.87 alpha:1.0];
            cell.addFriendButton.enabled = NO;
            return cell;
        }
    }
    // not friends or not requested
    [cell.addFriendButton setTitle:@"Add Friend" forState:UIControlStateNormal];
    return cell;

}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger numOfSections = 0;
    if ([self.filteredUsers count] > 0)
    {
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        numOfSections                 = 1;
        self.tableView.backgroundView = nil;
    }
    else
    {
        [self showSearchFriendsLabel];
    }
    return numOfSections;
}

- (void)showSearchFriendsLabel {
    UILabel *noDataLabel         = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, self.tableView.bounds.size.height)];
    noDataLabel.text             = @"Search for new friends!";
    noDataLabel.textColor        = [UIColor blackColor];
    noDataLabel.textAlignment    = NSTextAlignmentCenter;
    self.tableView.backgroundView = noDataLabel;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _friendsImageView.hidden = NO;
}

- (void)fetchFilteredUsers:(NSString *)prefix {
    PFQuery *query = [PFUser query];
    [query orderByDescending:@"createdAt"];
    query.limit = 100;
    [query whereKey:@"fullname" hasPrefix:prefix];
    [query whereKey:@"username" notEqualTo:[PFUser currentUser][@"username"]];
    [query findObjectsInBackgroundWithBlock:^(NSArray<PFUser *> * _Nullable users, NSError * _Nullable error) {
        if (users) {
            self.users = (NSMutableArray *)users;
            self.filteredUsers = self.users;
            [self.tableView reloadData];
        } else {
            NSLog(@"Error: %@", error.localizedDescription);
        }
    }];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (searchText.length != 0) {
        [self fetchFilteredUsers:searchText];
        _friendsImageView.hidden = YES;
    }
    else {
        self.filteredUsers = [NSMutableArray new];
        [self.tableView reloadData];
        _friendsImageView.hidden = NO;
        [self showSearchFriendsLabel];
    }
}


- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    self.searchBar.showsCancelButton = YES;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    self.searchBar.showsCancelButton = NO;
    self.searchBar.text = @"";
    [self.searchBar resignFirstResponder];
    self.filteredUsers = [NSMutableArray new];
    [self.tableView reloadData];
}


#pragma mark - Navigation

- (void)tapProfile:(nonnull FriendCell *)friendCell didTap:(nonnull PFUser *)user {
    [self performSegueWithIdentifier:@"friendListToProfileSegue" sender:user];
}


// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier  isEqual: @"requestSegue"]) {
        FriendRequestsViewController *friendRequestsViewController = segue.destinationViewController;
        friendRequestsViewController.currentUserFriendship = self.currentUserFriendship;
    } else if ([segue.identifier  isEqual:@"friendListToProfileSegue"]) {
        PersonProfileViewController *friendProfileController = segue.destinationViewController;
        friendProfileController.user = sender;
    }
}


@end
