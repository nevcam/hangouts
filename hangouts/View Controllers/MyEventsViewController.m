//
//  MyEventsViewController.m
//  hangouts
//
//  Created by sroman98 on 7/18/19.
//  Copyright © 2019 nev. All rights reserved.
//

#import "MyEventsViewController.h"
#import "UserEvents.h"
@import Parse;

@interface MyEventsViewController ()
//<UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *invitedTableView;
@property (weak, nonatomic) IBOutlet UITableView *willGoTableView;

@property (nonatomic, strong) NSMutableArray *invitedEvents;
@property (nonatomic, strong) NSMutableArray *willGoEvents;

@end

@implementation MyEventsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //self.invitedTableView.dataSource = self;
    //self.invitedTableView.delegate = self;
    
    [self fetchEvents];
}

- (void)fetchEvents {
    [self fetchInvited];
    [self fetchWillGo];
}

- (void)fetchInvited {
    // construct query
    PFQuery *eventQuery = [UserEvents query];
    [eventQuery whereKey:@"username" equalTo:[PFUser currentUser].username];
    
    // fetch data asynchronously
    [eventQuery findObjectsInBackgroundWithBlock:^(NSArray<UserEvents *> * _Nullable userEvents, NSError * _Nullable error) {
        if (userEvents) {
            NSLog(@"Mis eventos: %@",userEvents[0]);
            //self.posts = [[NSMutableArray alloc] initWithArray:posts];
            //[self.tableView reloadData];
        } else {
            NSLog(@"Error getting posts: %@", error.localizedDescription);
        }
        //[self.refreshControl endRefreshing];
    }];
}

- (void)fetchWillGo {
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
