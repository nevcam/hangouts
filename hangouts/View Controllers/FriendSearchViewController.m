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

@interface FriendSearchViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *users;
@end

@implementation FriendSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    [self fetchUsers];
    
//    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.rowHeight = 80;
}

- (void)fetchUsers {
    PFQuery *query = [PFUser query];
    [query orderByDescending:@"createdAt"];
    query.limit = 100;
    [query findObjectsInBackgroundWithBlock:^(NSArray<PFUser *> * _Nullable users, NSError * _Nullable error) {
        if (users) {
            NSLog(@"SUCCESS: %@", users);
            self.users = users;
            [self.tableView reloadData];
        } else {
            NSLog(@"Error: %@", error.localizedDescription);
        }
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.users.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//    NSLog(@"USERS: %@", self.users);
    FriendCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FriendCell"];
    PFUser *user = self.users[indexPath.row];
    cell.user = user;
    cell.profilePhotoView.image = user[@"ProfilePhoto"];
    cell.usernameLabel.text = user[@"username"];
    cell.fullnameLabel.text = user[@"fullname"];
    NSMutableArray *friends = [PFUser currentUser][@"friends"];
//    NSMutableArray *friendRequests = [PFUser currentUser][@"friendRequests"];
    // all the friends requests
//    NSMutableArray *friendRequests = user[@"friendRequests"];
    
    // checks whether current user is friends with the user that belongs to current cell
    if ([friends containsObject:cell.usernameLabel.text]) {
        cell.addFriendButton.hidden = YES;
    }
    // else if ([friendRequests containsObject:cell.usernameLabel.text])
    
    // checks whether current user sent a request to this user before
    else if ([user[@"friendRequests"] containsObject:[PFUser currentUser][@"username"]]) {
        [cell.addFriendButton setTitle:@"Requested" forState:UIControlStateNormal];
        cell.addFriendButton.enabled = NO;
    } else {
        [cell.addFriendButton setTitle:@"Add Friend" forState:UIControlStateNormal];
    }
    return cell;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
