//
//  ChatViewController.m
//  hangouts
//
//  Created by nev on 7/22/19.
//  Copyright © 2019 nev. All rights reserved.
//

#import "ChatViewController.h"
#import "ChatCell.h"
#import "Chat_Message.h"
#import "UIImageView+AFNetworking.h"

@interface ChatViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
//@property (nonatomic, strong) NSMutableArray *messages;
@end

@implementation ChatViewController
{
    NSMutableArray *_messages;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    UINavigationController *navController = (UINavigationController *) self.parentViewController;
    EventTabBarController *tabBar = (EventTabBarController *)navController.parentViewController;
    self.event = tabBar.event;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self fetchMessages];
}

#pragma mark - Load Messages

- (void)fetchMessages {
    PFQuery *postQuery = [Chat_Message query];
    [postQuery orderByDescending:@"createdAt"];
    [postQuery includeKey:@"user"];
    postQuery.limit = 100;
    [postQuery whereKey:@"event" equalTo:self.event];
    __weak typeof(self) weakSelf = self;
    [postQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable messages, NSError * _Nullable error) {
        if (messages) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            self->_messages = (NSMutableArray *)messages;
            [strongSelf.tableView reloadData];
            if (self->_messages.count > 0)
            {
                [strongSelf.tableView
                 scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self->_messages.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
            }
        }
        else {
            NSLog(@"Error getting messages: %@", error.localizedDescription);
        }
    }];
}

#pragma mark - Send Message

- (IBAction)didTapSend:(id)sender {
    PFObject *chatMessage = [PFObject objectWithClassName:@"Chat_Message"];
    chatMessage[@"text"] = self.chatMessageField.text;
    chatMessage[@"user"] = [PFUser currentUser];
    chatMessage[@"event"] = self.event;
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:_messages.count inSection:0];
    NSMutableArray *paths = [NSMutableArray new];
    [paths addObject:indexPath];
    __weak typeof(self) weakSelf = self;
    [chatMessage saveInBackgroundWithBlock:^(BOOL succeeded, NSError * error) {
        if (succeeded) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            strongSelf.chatMessageField.text = @"";
            [strongSelf fetchMessages];
        } else {
            NSLog(@"Problem saving message: %@", error.localizedDescription);
        }
    }];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - TableView

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    ChatCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ChatCell"];
    
    [cell.contentView removeConstraint: cell.leftBubbleConstraint];
    [cell.contentView removeConstraint: cell.rightBubbleConstraint];
    [cell.contentView removeConstraint: cell.topBubbleConstraint];
    
    NSArray* reversedArray = [[_messages reverseObjectEnumerator] allObjects];
    Chat_Message *message = reversedArray[indexPath.row];
    cell.chatMessageLabel.text = message[@"text"];
    PFUser *user = message[@"user"];
    cell.usernameLabel.text = user.username;
    cell.chatMessageLabel.textColor = [UIColor blackColor];
    cell.usernameLabel.textColor = [UIColor blackColor];
    [cell.messageBubbleView setBackgroundColor:[UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0]];
    [cell.messageBubbleView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [cell.chatMessageLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    if ([user[@"username"] isEqual:[PFUser currentUser][@"username"]]){
        cell.usernameLabel.text = @"";
        [cell.messageBubbleView setBackgroundColor:[UIColor colorWithRed:0.6 green:0.8 blue:1.0 alpha:1.0]];
        cell.chatMessageLabel.textColor = [UIColor whiteColor];
        cell.usernameLabel.textColor = [UIColor whiteColor];
        cell.rightBubbleConstraint = [NSLayoutConstraint constraintWithItem:cell.messageBubbleView attribute:NSLayoutAttributeRight  relatedBy:NSLayoutRelationEqual toItem:cell.contentView attribute:NSLayoutAttributeRight multiplier:1 constant:-10];
        [cell.contentView addConstraint:cell.rightBubbleConstraint];
        cell.topBubbleConstraint = [NSLayoutConstraint constraintWithItem:cell.messageBubbleView attribute:NSLayoutAttributeTop  relatedBy:NSLayoutRelationEqual toItem:cell.contentView attribute:NSLayoutAttributeTop multiplier:1 constant:4.5];
        [cell.contentView addConstraint:cell.topBubbleConstraint];
        cell.profilePhotoView.image = nil;
    } else {
        cell.leftBubbleConstraint = [NSLayoutConstraint constraintWithItem:cell.messageBubbleView attribute:NSLayoutAttributeLeft  relatedBy:NSLayoutRelationEqual toItem:cell.contentView attribute:NSLayoutAttributeLeft multiplier:1 constant:40];
        [cell.contentView addConstraint:cell.leftBubbleConstraint];
        cell.topBubbleConstraint = [NSLayoutConstraint constraintWithItem:cell.messageBubbleView attribute:NSLayoutAttributeTop  relatedBy:NSLayoutRelationEqual toItem:cell.contentView attribute:NSLayoutAttributeTop multiplier:1 constant:16];
        [cell.contentView addConstraint:cell.topBubbleConstraint];
        PFFileObject *const imageFile = user[@"profilePhoto"];
        NSURL *const profilePhotoURL = [NSURL URLWithString:imageFile.url];
        [cell.profilePhotoView setImageWithURL:profilePhotoURL];
        cell.profilePhotoView.layer.cornerRadius = cell.profilePhotoView.frame.size.height /2;
        cell.profilePhotoView.layer.masksToBounds = YES;
        cell.profilePhotoView.layer.borderWidth = 0;
    }
    
    [cell.contentView addConstraint:[NSLayoutConstraint constraintWithItem:cell.messageBubbleView attribute:NSLayoutAttributeBottom  relatedBy:NSLayoutRelationEqual toItem:cell.contentView attribute:NSLayoutAttributeBottom multiplier:1 constant:-3]];
    cell.chatMessageLabel.preferredMaxLayoutWidth = 218;
    [cell.contentView addConstraint:[NSLayoutConstraint constraintWithItem:cell.chatMessageLabel attribute:NSLayoutAttributeLeft  relatedBy:NSLayoutRelationEqual toItem:cell.messageBubbleView attribute:NSLayoutAttributeLeft multiplier:1 constant:8]];
    [cell.contentView addConstraint:[NSLayoutConstraint constraintWithItem:cell.chatMessageLabel attribute:NSLayoutAttributeTop  relatedBy:NSLayoutRelationEqual toItem:cell.messageBubbleView attribute:NSLayoutAttributeTop multiplier:1 constant:8]];
    [cell.contentView addConstraint:[NSLayoutConstraint constraintWithItem:cell.chatMessageLabel attribute:NSLayoutAttributeRight  relatedBy:NSLayoutRelationEqual toItem:cell.messageBubbleView attribute:NSLayoutAttributeRight multiplier:1 constant:-8]];
    [cell.contentView addConstraint:[NSLayoutConstraint constraintWithItem:cell.chatMessageLabel attribute:NSLayoutAttributeBottom  relatedBy:NSLayoutRelationEqual toItem:cell.messageBubbleView attribute:NSLayoutAttributeBottom multiplier:1 constant:-8]];
    [cell.messageBubbleView addConstraint:[NSLayoutConstraint constraintWithItem:cell.messageBubbleView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationLessThanOrEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:218]];
    cell.messageBubbleView.layer.cornerRadius = 16;
    cell.messageBubbleView.clipsToBounds = true;
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _messages.count;
}


@end
