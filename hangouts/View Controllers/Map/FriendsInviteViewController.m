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


@interface FriendsInviteViewController () <UITableViewDataSource, UITableViewDelegate, FriendEventCellDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *friendships;
@property (nonatomic, strong) NSMutableArray *invitedFriends;

@end

@implementation FriendsInviteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    self.friendships = [NSMutableArray new];
    self.invitedFriends = [NSMutableArray new];
    
    [self fetchFriendships];
    
    self.tableView.rowHeight = 80;
}

- (void)fetchFriendships {
    PFQuery *query = [Friendship query];
    [query orderByDescending:@"createdAt"];
    [query whereKey:@"username" equalTo:[PFUser currentUser].username];
    query.limit = 1;
    [query findObjectsInBackgroundWithBlock:^(NSArray<Friendship *> * _Nullable friendships, NSError * _Nullable error) {
        if (friendships) {
            // Saves usernames of current user friends
            NSMutableArray *friendUsernames = (NSMutableArray *)friendships[0].friends;
            
            // Uses the usernames to add user objects of current user's friends to the friendships array
            for (NSString *friendUsername in friendUsernames) {
                PFQuery *query = [PFUser query];
                [query orderByDescending:@"createdAt"];
                [query whereKey:@"username" equalTo:friendUsername];
                query.limit = 1;
                [query findObjectsInBackgroundWithBlock:^(NSArray<PFUser *> * _Nullable friends, NSError * _Nullable error) {
                    if (friends) {
                        [self.friendships addObject:friends[0]];
                        if (self.friendships.count == friendUsernames.count) {
                            [self.tableView reloadData];
                        }
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

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.friendships.count;
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    
    FriendsToEventCell *cell =  [tableView dequeueReusableCellWithIdentifier:@"friendsToEventCell"];
    PFUser *user = self.friendships[indexPath.row];
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
    
    cell.delegate = self;
    
    return cell;
}

// Follows cell'ss protocol to add/remove friends from local array
- (void)addFriendToEvent:(nonnull PFUser *)friend remove:(BOOL)remove {
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

@end
