//
//  FriendRequestsViewController.m
//  hangouts
//
//  Created by nev on 7/17/19.
//  Copyright © 2019 nev. All rights reserved.
//

#import "FriendRequestsViewController.h"
#import "FriendRequestCell.h"
#import "Parse/Parse.h"
#import "Friendship.h"
#import "UIImageView+AFNetworking.h"
#import "FriendRequestCell.h"

@interface FriendRequestsViewController () <UITableViewDataSource, UITableViewDelegate, FriendRequestCellDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation FriendRequestsViewController {
    NSMutableArray* _objects;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self fetchRequests];
    self.tableView.rowHeight = 80;
}

- (void)fetchRequests {
    for (NSString *username in self.friendRequests) {
        PFQuery *query = [PFUser query];
        [query orderByDescending:@"createdAt"];
        query.limit = 1;
        [query whereKey:@"username" equalTo:username];
        [query findObjectsInBackgroundWithBlock:^(NSArray<PFUser *> * _Nullable users, NSError * _Nullable error) {
            if (users) {

                if(!self->_objects){
                    self->_objects = [[NSMutableArray alloc] init];
                }
                [self->_objects addObjectsFromArray:users];
                if (self->_objects.count==self.friendRequests.count) {
                    [self.tableView reloadData];
                }
            } else {
                NSLog(@"Error: %@", error.localizedDescription);
            }
        }];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.friendRequests.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FriendRequestCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FriendRequestCell"];
    PFUser *user = self->_objects[indexPath.row];
    cell.user = user;
    cell.delegate = self;
    cell.indexPath = indexPath;
    
    PFFileObject *imageFile = user[@"profilePhoto"];
    NSURL *profilePhotoURL = [NSURL URLWithString:imageFile.url];
    cell.profilePhotoView.image = nil;
    [cell.profilePhotoView setImageWithURL:profilePhotoURL];
    
    // make profile photo a circle
    cell.profilePhotoView.layer.cornerRadius = cell.profilePhotoView.frame.size.height /2;
    cell.profilePhotoView.layer.masksToBounds = YES;
    cell.profilePhotoView.layer.borderWidth = 0;
    cell.usernameLabel.text = user[@"username"];
    cell.fullnameLabel.text = user[@"fullname"];
    cell.currentUserFriendship = self.currentUserFriendship;
    return cell;
}

//CellDelegate Method
-(void) deleteCellForIndexPath:(NSIndexPath*)indexPath; {
    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    
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
