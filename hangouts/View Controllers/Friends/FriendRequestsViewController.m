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
#import "PersonProfileViewController.h"

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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger numOfSections = 0;
    if ([_requests count] > 0)
    {
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        numOfSections                 = 1;
        self.tableView.backgroundView = nil;
    }
    else
    {
        UILabel *noDataLabel         = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, self.tableView.bounds.size.height)];
        noDataLabel.text             = @"No friend requests!";
        noDataLabel.textColor        = [UIColor blackColor];
        noDataLabel.textAlignment    = NSTextAlignmentCenter;
        self.tableView.backgroundView = noDataLabel;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return numOfSections;
}

#pragma mark - Navigation
- (void)tapProfile:(nonnull FriendRequestCell *)friendCell didTap:(nonnull PFUser *)user {
    [self performSegueWithIdentifier:@"requestsListToProfileSegue" sender:user];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier  isEqual:@"requestsListToProfileSegue"]) {
        PersonProfileViewController *friendProfileController = segue.destinationViewController;
        friendProfileController.user = sender;
    }
}


@end
