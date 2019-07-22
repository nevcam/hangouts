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
@import Parse;

@interface ProfileViewController () <ProfileEditViewControllerDelegate, UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation ProfileViewController {
    NSMutableArray* _friendUsers;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.rowHeight = 80;
    
    self.user = [PFUser currentUser];
    self.usernameLabel.text = self.user[@"username"];
    self.fullnameLabel.text = self.user[@"fullname"];
    self.emailLabel.text = self.user[@"email"];
    self.bioLabel.text = self.user[@"bio"];
    PFFileObject *imageFile = self.user[@"profilePhoto"];
    NSURL *profilePhotoURL = [NSURL URLWithString:imageFile.url];
    self.profilePhotoView.image = nil;
    [self.profilePhotoView setImageWithURL:profilePhotoURL];
    // make profile photo a circle
    self.profilePhotoView.layer.cornerRadius = self.profilePhotoView.frame.size.height /2;
    self.profilePhotoView.layer.masksToBounds = YES;
    self.profilePhotoView.layer.borderWidth = 0;
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(beginRefresh:) forControlEvents:UIControlEventValueChanged];
    [self.tableView insertSubview:refreshControl atIndex:0];
    
    [self fetchFriends];
}

- (void)beginRefresh:(UIRefreshControl *)refreshControl {
    [self fetchFriends];
    [refreshControl endRefreshing];
}

- (void)fetchFriends {
    self->_friendUsers = [[NSMutableArray alloc] init];
    PFQuery *query = [Friendship query];
    [query orderByDescending:@"createdAt"];
    [query whereKey:@"username" equalTo:[PFUser currentUser][@"username"]];
    query.limit = 1;
    [query findObjectsInBackgroundWithBlock:^(NSArray<Friendship *> * _Nullable friendships, NSError * _Nullable error) {
        if (friendships) {
            Friendship *friendship = friendships[0];
            NSArray *friends = friendship[@"friends"];
            for(NSString *friendUsername in friends) {
                PFQuery *query = [PFUser query];
                [query orderByDescending:@"createdAt"];
                query.limit = 1;
                [query whereKey:@"username" equalTo:friendUsername];
                [query findObjectsInBackgroundWithBlock:^(NSArray<PFUser *> * _Nullable users, NSError * _Nullable error) {
                    if (users) {
                        [self->_friendUsers addObjectsFromArray:users];
                        if (self->_friendUsers.count==friends.count) {
                            [self.tableView reloadData];
                        }
                        [self.tableView reloadData];
                    } else {
                        NSLog(@"Error: %@", error.localizedDescription);
                    }
                }];
            }
        } else {
            NSLog(@"Error: %@", error.localizedDescription);
        }
    }];
    
}

- (IBAction)didTapEditProfile:(id)sender {
    [self performSegueWithIdentifier:@"profileEditSegue" sender:nil];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self->_friendUsers.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FriendViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FriendViewCell"];
    PFUser *user = self->_friendUsers[indexPath.row];
    
    cell.user = user;
    PFFileObject *imageFile = user[@"profilePhoto"];
    NSURL *profilePhotoURL = [NSURL URLWithString:imageFile.url];
    cell.profilePhotoView.image = nil;
    [cell.profilePhotoView setImageWithURL:profilePhotoURL];
    cell.profilePhotoView.layer.cornerRadius = cell.profilePhotoView.frame.size.height /2;
    cell.profilePhotoView.layer.masksToBounds = YES;
    cell.profilePhotoView.layer.borderWidth = 0;
    cell.usernameLabel.text = user[@"username"];
    cell.fullnameLabel.text = user[@"fullname"];

    return cell;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier  isEqual: @"profileEditSegue"]){
        PFUser *user = self.user;
        ProfileEditViewController *profileEditViewController = [segue destinationViewController];
        profileEditViewController.user = user;
        profileEditViewController.delegate = self;
    }
}


// MARK: logout functions
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
    [query whereKey:@"username" equalTo:self.user[@"username"]];
    [query findObjectsInBackgroundWithBlock:^(NSArray<PFUser *> * _Nullable users, NSError * _Nullable error) {
        if (users) {
            PFUser *user = users[0];
            self.fullnameLabel.text = user[@"fullname"];
            self.bioLabel.text = user[@"bio"];
            PFFileObject *imageFile = user[@"profilePhoto"];
            NSURL *photoURL = [NSURL URLWithString:imageFile.url];
            self.profilePhotoView.image = nil;
            [self.profilePhotoView setImageWithURL:photoURL];
            self.profilePhotoView.layer.cornerRadius = self.profilePhotoView.frame.size.width / 2;
            self.profilePhotoView.layer.masksToBounds = YES;
            [self.view addSubview: self.profilePhotoView];
        } else {
            NSLog(@"Error: %@", error.localizedDescription);
        }
    }];
}

@end
