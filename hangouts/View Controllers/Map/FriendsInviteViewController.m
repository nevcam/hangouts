//
//  FriendsInviteViewController.m
//  hangouts
//
//  Created by josemurillo on 7/19/19.
//  Copyright © 2019 nev. All rights reserved.
//

#import "FriendsInviteViewController.h"
#import "Parse/Parse.h"
#import "FriendsToEventCell.h"
#import "UIImageView+AFNetworking.h"
#import "Friendship.h"
#import "Event.h"
#import "PersonProfileViewController.h"

@interface FriendsInviteViewController () <UITableViewDataSource, UITableViewDelegate, FriendEventCellDelegate, UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@end

#pragma mark - Global Variables

@implementation FriendsInviteViewController
{
    NSMutableArray *_friendships;
    NSMutableArray *_results;
}

#pragma mark - Load View Controller

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _searchBar.delegate = self;
    
    if (!_invitedFriends) {
        _invitedFriends = [NSMutableArray array];
    }
    _friendships = [NSMutableArray array];
    [self fetchFriendships];
    
    self.tableView.rowHeight = 80;
}

#pragma mark - Load Friends

- (void)fetchFriendships
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
                        [strongSelf->_friendships addObjectsFromArray:friends];

                        if (strongSelf->_friendships.count == friendPointers.count) {
                            strongSelf->_results = strongSelf->_friendships;
                            [strongSelf.tableView reloadData];
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

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _results.count;
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    FriendsToEventCell *cell =  [tableView dequeueReusableCellWithIdentifier:@"friendsToEventCell"];
    PFUser *const user = _results[indexPath.row];
    cell.user = user;
    
    cell.usernameLabel.text = user[@"username"];
    cell.fullnameLabel.text = user[@"fullname"];
    
    // Could not use containsObject built-in function because locally, the dequed user and the one saved in the array have different IDs, meaning that when calling containsObject, they are identified as different users.
    cell.invited = NO;
    for (PFUser *invitedFriend in _invitedFriends) {
        if ([user.objectId isEqualToString:invitedFriend.objectId]) {
            cell.invited = YES;
        }
    }
 
    PFFileObject *const imageFile = user[@"profilePhoto"];
    NSURL *const profilePhotoURL = [NSURL URLWithString:imageFile.url];
    cell.profilePhotoView.image = nil;
    [cell.profilePhotoView setImageWithURL:profilePhotoURL];
    // make profile photo a circle
    cell.profilePhotoView.layer.cornerRadius = cell.profilePhotoView.frame.size.height /2;
    cell.profilePhotoView.layer.masksToBounds = YES;
    cell.profilePhotoView.layer.borderWidth = 0;
    
    cell.delegate = self;
    
    return cell;
}

#pragma mark - Invite/Uninvite Friends To Event

// Follows cell'ss protocol to add/remove friends from local array
- (void)addFriendToEvent:(PFUser *)friend remove:(BOOL)remove
{
    if (!remove) {
        [_invitedFriends addObject:friend];
    } else {
        for (PFUser *invitedFriend in _invitedFriends) {
            if ([friend.objectId isEqualToString:invitedFriend.objectId]) {
                [_invitedFriends removeObject:invitedFriend];
                break;
            }
        }
    }
}

// Sends list of invtied friends to AddEvent view controller
- (IBAction)saveList:(id)sender {
    [_delegate saveFriendsList:_invitedFriends];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Search Bar

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    
    if (searchText.length != 0) {
        NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(PFUser *evaluatedObject, NSDictionary *bindings) {
            return [evaluatedObject[@"fullname"] containsString:searchText];
        }];
        // Casting is necessary because filteredArrayUsingPredicate returns an array
        _results = (NSMutableArray *)[_friendships filteredArrayUsingPredicate:predicate];
    }
    else {
        _results = _friendships;
    }
    [_tableView reloadData];
}


- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    _searchBar.showsCancelButton = YES;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    _searchBar.showsCancelButton = NO;
    _searchBar.text = @"";
    [_searchBar resignFirstResponder];
    _results = _friendships;
    [_tableView reloadData];
}

#pragma mark - Check a Profile

- (void)tapProfile:(nonnull FriendsToEventCell *)friendCell didTap:(nonnull PFUser *)user {
    NSLog(@"%@", user);
    [self performSegueWithIdentifier:@"eventFriendsListToProfileSegue" sender:user];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier  isEqual:@"eventFriendsListToProfileSegue"]) {
        PersonProfileViewController *friendProfileController = segue.destinationViewController;
        friendProfileController.user = sender;
    }
}


@end
