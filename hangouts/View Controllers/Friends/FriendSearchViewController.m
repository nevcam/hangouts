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

@interface FriendSearchViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *requestView;
@property (weak, nonatomic) IBOutlet UILabel *requestCount;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (nonatomic, strong) NSMutableArray *users;
@property (nonatomic, strong) NSMutableArray *filteredUsers;
@property (nonatomic, strong) NSMutableArray *friendships;
@property (nonatomic, strong) NSMutableArray *currentUserFriendRequests;

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
//    self.tableView.rowHeight = UITableViewAutomaticDimension;
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
            [self.tableView reloadData];
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
//    NSLog(@"USERS: %@", self.users);
    FriendCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FriendCell"];
    PFUser *user = self.filteredUsers[indexPath.row];
    cell.user = user;

    cell.usernameLabel.text = user[@"username"];
    cell.fullnameLabel.text = user[@"fullname"];
    
    PFFileObject *imageFile = user[@"profilePhoto"];
    NSURL *profilePhotoURL = [NSURL URLWithString:imageFile.url];
    cell.profilePhotoView.image = nil;
    [cell.profilePhotoView setImageWithURL:profilePhotoURL];
    // make profile photo a circle
    cell.profilePhotoView.layer.cornerRadius = cell.profilePhotoView.frame.size.height /2;
    cell.profilePhotoView.layer.masksToBounds = YES;
    cell.profilePhotoView.layer.borderWidth = 0;
    
    Friendship *friendship = self.friendships[indexPath.row];
    cell.userFriendship = friendship;
    NSMutableArray *friends = (NSMutableArray *)friendship.friends;
    NSMutableArray *friendRequests = (NSMutableArray *) friendship.friendRequests;
    NSString *currentUsername = [PFUser currentUser][@"username"];
    
    // checks whether current user is friends with the user that belongs to current cell
    if ([friends containsObject:currentUsername]) {
        cell.addFriendButton.hidden = YES;
    }
    // checks whether current user sent a request to this user before
    else if ([friendRequests containsObject:currentUsername]) {
        [cell.addFriendButton setTitle:@"Requested" forState:UIControlStateNormal];
        cell.addFriendButton.enabled = NO;
    } else {
        [cell.addFriendButton setTitle:@"Add Friend" forState:UIControlStateNormal];
    }
    
    // IF IT IS THE CURRENT USER FETCH FRIEND REQUESTS
    if ([[PFUser currentUser][@"username"] isEqualToString:user[@"username"]]) {
        self.currentUserFriendRequests = friendRequests;
        self.requestCount.text = [@(self.currentUserFriendRequests.count) stringValue];
        cell.addFriendButton.hidden = YES;
    }
    return cell;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    
    if (searchText.length != 0) {
        
        NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(PFUser *evaluatedObject, NSDictionary *bindings) {
            return [evaluatedObject[@"fullname"] containsString:searchText];
        }];
        self.filteredUsers = (NSMutableArray *)[self.users filteredArrayUsingPredicate:predicate];
        
        NSLog(@"%@", self.filteredUsers);
        
    }
    else {
        self.filteredUsers = self.users;
    }
    
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
    }
}


@end
