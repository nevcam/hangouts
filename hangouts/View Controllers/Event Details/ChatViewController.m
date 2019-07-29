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

@interface ChatViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *messages;
@end

@implementation ChatViewController

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
            strongSelf.messages = (NSMutableArray *)messages;
            [strongSelf.tableView reloadData];
            if (strongSelf.messages.count > 0)
            {
                [strongSelf.tableView
                 scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:strongSelf.messages.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
            }
        }
        else {
            // handle error
            NSLog(@"😫😫😫 Error getting home timeline: %@", error.localizedDescription);
        }
    }];
}

- (IBAction)didTapSend:(id)sender {
    PFObject *chatMessage = [PFObject objectWithClassName:@"Chat_Message"];

    chatMessage[@"text"] = self.chatMessageField.text;
    chatMessage[@"user"] = [PFUser currentUser];
    chatMessage[@"event"] = self.event;
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.messages.count inSection:0];
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

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    ChatCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ChatCell"];
    NSArray* reversedArray = [[self.messages reverseObjectEnumerator] allObjects];
    Chat_Message *message = reversedArray[indexPath.row];
    cell.chatMessageLabel.text = message[@"text"];
    PFUser *user = message[@"user"];
    cell.usernameLabel.text = user.username;
    if ([user[@"username"] isEqual:[PFUser currentUser][@"username"]]){
        CGRect frame = cell.messageBubbleView.frame;
        frame.origin.x = self.view.frame.origin.x + 140;
        [cell.messageBubbleView setBackgroundColor:[UIColor colorWithRed:0.6 green:0.8 blue:1.0 alpha:1.0]];
        [cell.messageBubbleView setFrame:frame];
        cell.chatMessageLabel.textColor = [UIColor whiteColor];
        cell.usernameLabel.textColor = [UIColor whiteColor];
        
    }
    cell.messageBubbleView.layer.cornerRadius = 16;
    cell.messageBubbleView.clipsToBounds = true;
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.messages.count;
}


@end
