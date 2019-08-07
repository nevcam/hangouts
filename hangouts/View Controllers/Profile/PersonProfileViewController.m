//
//  PersonProfileViewController.m
//  hangouts
//
//  Created by josemurillo on 7/29/19.
//  Copyright © 2019 nev. All rights reserved.
//

#import "PersonProfileViewController.h"
#import "UIImageView+AFNetworking.h"
#import "Friendship.h"
#import "AppDelegate.h"
#import "ProfileFriendsCollectionViewCell.h"

@interface PersonProfileViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *profilePhotoView;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *fullnameLabel;
@property (weak, nonatomic) IBOutlet UITextField *bioLabel;
@property (weak, nonatomic) IBOutlet UILabel *pastEventsCount;
@property (weak, nonatomic) IBOutlet UILabel *nextEventsCount;
@property (weak, nonatomic) IBOutlet UILabel *friendsCount;


@end

@implementation PersonProfileViewController {
    NSMutableArray *_friendships;
}

#pragma mark - Set Profile Basic Features
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setProfileFeatures];
}

- (void)setProfileFeatures
{
    _usernameLabel.text = [NSString stringWithFormat:@"@%@", _user[@"username"]];
    _fullnameLabel.text = _user[@"fullname"];
    _bioLabel.text = _user[@"bio"];
    [self setProfileImageLayout];
}

- (void)setProfileImageLayout
{
    PFFileObject *const imageFile = _user[@"profilePhoto"];
    NSURL *const profilePhotoURL = [NSURL URLWithString:imageFile.url];
    _profilePhotoView.image = nil;
    [_profilePhotoView setImageWithURL:profilePhotoURL];
    _profilePhotoView.layer.cornerRadius = self.profilePhotoView.frame.size.height /2;
    _profilePhotoView.layer.masksToBounds = YES;
    _profilePhotoView.layer.borderWidth = 0;
}

//#pragma mark - Friends
//
//- (void)fetchFriends {
//    PFQuery *query = [Friendship query];
//    [query orderByDescending:@"createdAt"];
//    [query whereKey:@"user" equalTo:[PFUser currentUser]];
//    [query includeKey:@"user"];
//    query.limit = 1;
//    
//    __weak typeof(self) weakSelf = self;
//    [query findObjectsInBackgroundWithBlock:^(NSArray<Friendship *> * _Nullable friendships, NSError * _Nullable error) {
//        if (friendships) {
//            NSMutableArray *friendPointers = (NSMutableArray *)friendships[0][@"friends"];
//            NSMutableArray *friendIds = [NSMutableArray new];
//            
//            for (PFUser *friendPointer in friendPointers) {
//                [friendIds addObject:friendPointer.objectId];
//            }
//            
//            PFQuery *query = [PFUser query];
//            [query orderByDescending:@"createdAt"];
//            [query whereKey:@"objectId" containedIn:friendIds];
//            
//            [query findObjectsInBackgroundWithBlock:^(NSArray<PFUser *> * _Nullable friends, NSError * _Nullable error) {
//                if (friends) {
//                    __strong typeof(weakSelf) strongSelf = weakSelf;
//                    if(strongSelf) {
//                        if (!strongSelf->_friendships) {
//                            strongSelf->_friendships = [NSMutableArray new];
//                            strongSelf->_friendUsers = [NSMutableArray new];
//                            [strongSelf->_friendships addObjectsFromArray:friends];
//                            if (strongSelf->_friendships.count == friendPointers.count) {
//                                strongSelf->_friendUsers = strongSelf->_friendships;
//                                [strongSelf.collectionView reloadData];
//                                strongSelf->_friendsCount.text = [NSString stringWithFormat:@"%lu", (unsigned long)self->_friendships.count];
//                            }
//                        } else {
//                            NSLog(@"Error");
//                        }
//                    }
//                } else {
//                    NSLog(@"Error: %@", error.localizedDescription);
//                }
//            }];
//        } else {
//            NSLog(@"Error: %@", error.localizedDescription);
//        }
//    }];
//    
//}
//
@end
