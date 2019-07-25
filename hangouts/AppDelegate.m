//
//  AppDelegate.m
//  hangouts
//
//  Created by nev on 7/16/19.
//  Copyright © 2019 nev. All rights reserved.
//

#import "AppDelegate.h"
#import "Parse/Parse.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    ParseClientConfiguration *config = [ParseClientConfiguration   configurationWithBlock:^(id<ParseMutableClientConfiguration> configuration) {
        configuration.applicationId = @"friendsInTown";
        configuration.server = @"http://friends-in-town.herokuapp.com/parse";
    }];
    [Parse initializeWithConfiguration:config];
    
    if (PFUser.currentUser) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        self.window.rootViewController = [storyboard instantiateViewControllerWithIdentifier:@"HomeTabController"];
    }
    self.window.backgroundColor = [UIColor whiteColor];
    return YES;
}

@end
