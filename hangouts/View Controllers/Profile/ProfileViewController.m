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
    NSMutableArray *_friendships;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.rowHeight = 80;
    _user = [PFUser currentUser];
    _usernameLabel.text = _user[@"username"];
    _fullnameLabel.text = _user[@"fullname"];
    _emailLabel.text = _user[@"email"];
    _bioLabel.text = _user[@"bio"];
    PFFileObject *imageFile = _user[@"profilePhoto"];
    NSURL *profilePhotoURL = [NSURL URLWithString:imageFile.url];
    _profilePhotoView.image = nil;
    [_profilePhotoView setImageWithURL:profilePhotoURL];
    _profilePhotoView.layer.cornerRadius = _profilePhotoView.frame.size.height /2;
    _profilePhotoView.layer.masksToBounds = YES;
    _profilePhotoView.layer.borderWidth = 0;
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(beginRefresh:) forControlEvents:UIControlEventValueChanged];
    [_tableView insertSubview:refreshControl atIndex:0];
    
    [self fetchFriends];
}

- (void)beginRefresh:(UIRefreshControl *)refreshControl {
    [self fetchFriends];
    [refreshControl endRefreshing];
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
                                [strongSelf.tableView reloadData];
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _friendUsers.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FriendViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FriendViewCell"];
    PFUser *user = _friendUsers[indexPath.row];
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
        PFUser *user = _user;
        ProfileEditViewController *profileEditViewController = [segue destinationViewController];
        profileEditViewController.user = user;
        profileEditViewController.delegate = self;
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

@end
