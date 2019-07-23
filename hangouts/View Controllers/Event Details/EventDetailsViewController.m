//
//  EventDetailsViewController.m
//  hangouts
//
//  Created by nev on 7/22/19.
//  Copyright © 2019 nev. All rights reserved.
//

#import "EventDetailsViewController.h"

@interface EventDetailsViewController ()

@end

@implementation EventDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UINavigationController *navController = (UINavigationController *) self.parentViewController;
    EventTabBarController *tabBar = (EventTabBarController *)navController.parentViewController;
    tabBar.event = self.event;
}
- (IBAction)didTapClose:(id)sender {
    [self dismissViewControllerAnimated:true completion:nil];
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
