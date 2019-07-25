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
    NSMutableArray* _requests;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self fetchRequests];
    self.tableView.rowHeight = 80;
}

- (void)fetchRequests {
    NSMutableArray *incomingFriendRequests = (NSMutableArray *)self.currentUserFriendship.incomingRequests;
    for (PFUser *request in incomingFriendRequests) {
        PFQuery *query = [PFUser query];
        [query getObjectInBackgroundWithId:request.objectId block:^(PFObject * _Nullable object, NSError * _Nullable error) {
            if (object) {
                PFUser *user = (PFUser *)object;
                NSLog(@"user: %@", user);
                if(!self->_requests){
                    self->_requests = [[NSMutableArray alloc] init];
                }
                [self->_requests addObject:user];
                if (self->_requests.count==incomingFriendRequests.count) {
                    [self.tableView reloadData];
                }
            } else {
                NSLog(@"Error: %@", error.localizedDescription);
            }
        }];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.currentUserFriendship.incomingRequests.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FriendRequestCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FriendRequestCell"];
    PFUser *user = self->_requests[indexPath.row];
    NSLog(@"user cell: %@", user);
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
    NSLog(@"user: %@", user);
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
