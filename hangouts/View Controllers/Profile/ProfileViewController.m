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
@import Parse;

@interface ProfileViewController () <ProfileEditViewControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegate, ProfileFriendViewCellDelegate>

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

@end

@implementation ProfileViewController {
    NSMutableArray *_friendUsers;
    NSMutableArray *_friendships;
}

#pragma mark - Load View Controller

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    
    [self setUserInfo];
    [self setRefreshControl];
    
    [self fetchFriends];
    [self setCollectionLayout];
}

- (void)setUserInfo
{
    _user = [PFUser currentUser];
    _usernameLabel.text = _user[@"username"];
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

- (void)setRefreshControl
{
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(beginRefresh:) forControlEvents:UIControlEventValueChanged];
    [_collectionView insertSubview:refreshControl atIndex:0];
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




@end
