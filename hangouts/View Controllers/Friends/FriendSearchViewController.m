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

@interface FriendSearchViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *requestView;
@property (weak, nonatomic) IBOutlet UILabel *requestCount;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (nonatomic, strong) NSMutableArray *users;
@property (nonatomic, strong) NSMutableArray *filteredUsers;
@property (nonatomic, strong) NSMutableArray *friendships;
@property (nonatomic, strong) NSMutableArray *currentUserFriendRequests;
@property (nonatomic, strong) Friendship *currentUserFriendship;
@property (nonatomic, strong) NSMutableDictionary *friendshipMap;


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
    
    [self fetchFriendships];
    [self fetchUsers];
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
            [self getCurrentUserInfo];
            [self.tableView reloadData];
        } else {
            NSLog(@"Error: %@", error.localizedDescription);
        }
    }];
}

- (void)fetchFriendships {
    PFQuery *query = [Friendship query];
    [query orderByDescending:@"createdAt"];
    query.limit = 100;
    [query findObjectsInBackgroundWithBlock:^(NSArray<Friendship *> * _Nullable friendships, NSError * _Nullable error) {
        if (friendships) {
            self.friendships = (NSMutableArray *)friendships;
            NSMutableDictionary *map = [[NSMutableDictionary alloc] init];
            NSMutableArray *array;
            for (Friendship *friendship in friendships) {
                array = [map objectForKey:friendship[@"username"]];
                if (!array) {
                    array = [[NSMutableArray alloc] init];
                    [map setObject:array forKey:friendship[@"username"]];
                }
                [array addObject:friendship];
            }
            self.friendshipMap = map;
            [self.tableView reloadData];
        } else {
            NSLog(@"Error: %@", error.localizedDescription);
        }
    }];
}

- (void)getCurrentUserInfo {
    // Get current user's friend information to pass it later and show friend request count
    NSString *username = [PFUser currentUser][@"username"];
    Friendship *userFriendship = self.friendshipMap[username][0];
    self.currentUserFriendRequests = (NSMutableArray *)userFriendship.friendRequests;
    self.currentUserFriendship = userFriendship;
    self.requestCount.text = [@(self.currentUserFriendRequests.count) stringValue];
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
    NSURL *profilePhotoURL = [NSURL URLWithString:imageFile.url];
    cell.profilePhotoView.image = nil;
    [cell.profilePhotoView setImageWithURL:profilePhotoURL];
    cell.profilePhotoView.layer.cornerRadius = cell.profilePhotoView.frame.size.height /2;
    cell.profilePhotoView.layer.masksToBounds = YES;
    cell.profilePhotoView.layer.borderWidth = 0;

    NSString *username = user[@"username"];
    Friendship *userFriendship = self.friendshipMap[username][0];
    cell.userFriendship = userFriendship;
    cell.friends = (NSMutableArray *)userFriendship.friends;
    cell.friendRequests = (NSMutableArray *)userFriendship.friendRequests;

    NSString *currentUsername = [PFUser currentUser][@"username"];
    if ([cell.friends containsObject:currentUsername]) {
        [cell.addFriendButton setTitle:@"" forState:UIControlStateNormal];
        cell.addFriendButton.enabled = NO;
    }
    // checks whether current user sent a request to this user before
    else if ([cell.friendRequests containsObject:currentUsername]) {
        [cell.addFriendButton setTitle:@"Requested" forState:UIControlStateNormal];
        cell.addFriendButton.enabled = NO;
    } else {
        [cell.addFriendButton setTitle:@"Add Friend" forState:UIControlStateNormal];
    }
 
    return cell;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (searchText.length != 0) {
        NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(PFUser *evaluatedObject, NSDictionary *bindings) {
            return [evaluatedObject[@"fullname"] containsString:searchText];
        }];
        self.filteredUsers = (NSMutableArray *)[self.users filteredArrayUsingPredicate:predicate];
    }
    else {
        self.filteredUsers = self.users;
    }
    [self.tableView reloadData];
    
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    self.searchBar.showsCancelButton = YES;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    self.searchBar.showsCancelButton = NO;
    self.searchBar.text = @"";
    [self.searchBar resignFirstResponder];
    self.filteredUsers = self.users;
    [self.tableView reloadData];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier  isEqual: @"requestSegue"]) {
        FriendRequestsViewController *friendRequestsViewController = segue.destinationViewController;
        friendRequestsViewController.friendRequests = self.currentUserFriendRequests;
        friendRequestsViewController.users = self.users;
        friendRequestsViewController.currentUserFriendship = self.currentUserFriendship;
    }
}


@end
