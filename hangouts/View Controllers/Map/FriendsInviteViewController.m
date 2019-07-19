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


@interface FriendsInviteViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *friendships;

@end

@implementation FriendsInviteViewController {
    NSMutableArray* _userFriends;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
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
                [query findObjectsInBackgroundWithBlock:^(NSArray<PFUser *> * _Nullable users, NSError * _Nullable error) {
                    if (users) {
                        if(!self->_userFriends){
                            self->_userFriends = [[NSMutableArray alloc] init];
                        }
                        [self->_userFriends addObjectsFromArray:users];

                    } else {
                        NSLog(@"Error: %@", error.localizedDescription);
                    }
                }];
            }
        } else {
            NSLog(@"Error: %@", error.localizedDescription);
        }
        [self.tableView reloadData];
    }];
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.friendships.count;
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    
    FriendsToEventCell *cell =  [tableView dequeueReusableCellWithIdentifier:@"FriendsToEventCell"];
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
    
    return cell;
}


@end
