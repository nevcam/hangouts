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

@interface FriendsInviteViewController () <UITableViewDataSource, UITableViewDelegate, FriendEventCellDelegate, UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@end

@implementation FriendsInviteViewController
{
    NSMutableArray *_friendships;
    NSMutableArray *_results;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.searchBar.delegate = self;
    
    if (!self.invitedFriends) {
        self.invitedFriends = [NSMutableArray new];
    }
    [self fetchFriendships];
    
    self.tableView.rowHeight = 80;
}

- (void)fetchFriendships {
    PFQuery *query = [Friendship query];
    [query orderByDescending:@"createdAt"];
    [query whereKey:@"user" equalTo:[PFUser currentUser]];
    [query includeKey:@"user"];
    query.limit = 1;
    
    __weak typeof(self) weakSelf = self;
    [query findObjectsInBackgroundWithBlock:^(NSArray<Friendship *> * _Nullable friendships, NSError * _Nullable error) {
        if (friendships) {
            // Saves usernames of current user friends
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
                    __strong typeof(self) strongSelf = weakSelf;
                    
                    if (!strongSelf->_friendships) {
                        strongSelf->_friendships = [NSMutableArray new];
                        strongSelf->_results = [NSMutableArray new];
                        
                        for (PFUser *friend in friends) {
                            [strongSelf->_friendships addObject:friend];
                        }
                        if (strongSelf->_friendships.count == friendPointers.count) {
                            strongSelf->_results = strongSelf->_friendships;
                            [self.tableView reloadData];
                        }
                    } else {
                        NSLog(@"Error: in loading self");
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

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self->_results.count;
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    
    FriendsToEventCell *cell =  [tableView dequeueReusableCellWithIdentifier:@"friendsToEventCell"];
    PFUser *user = self->_results[indexPath.row];
    cell.user = user;
    
    cell.usernameLabel.text = user[@"username"];
    cell.fullnameLabel.text = user[@"fullname"];
    
    if ([self.invitedFriends containsObject:user[@"username"]]) {
        cell.invited = YES;
    } else {
        cell.invited = NO;
    }
    
    PFFileObject *imageFile = user[@"profilePhoto"];
    NSURL *profilePhotoURL = [NSURL URLWithString:imageFile.url];
    cell.profilePhotoView.image = nil;
    [cell.profilePhotoView setImageWithURL:profilePhotoURL];
    // make profile photo a circle
    cell.profilePhotoView.layer.cornerRadius = cell.profilePhotoView.frame.size.height /2;
    cell.profilePhotoView.layer.masksToBounds = YES;
    cell.profilePhotoView.layer.borderWidth = 0;
    
    cell.delegate = self;
    
    return cell;
}

// Follows cell'ss protocol to add/remove friends from local array
- (void)addFriendToEvent:(NSString *)friend remove:(BOOL)remove {
    if (!remove) {
        [self.invitedFriends addObject:friend];
    } else {
        [self.invitedFriends removeObject:friend];
    }
}

// Sends list of invtied friends to AddEvent view controller
- (IBAction)saveList:(id)sender {
    [self.delegate saveFriendsList:self.invitedFriends];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    
    if (searchText.length != 0) {
        NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(PFUser *evaluatedObject, NSDictionary *bindings) {
            return [evaluatedObject[@"fullname"] containsString:searchText];
        }];
        self->_results = (NSMutableArray *)[self->_friendships filteredArrayUsingPredicate:predicate];
    }
    else {
        self->_results = self->_friendships;
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
    self->_results = self->_friendships;
    [self.tableView reloadData];
}


@end
