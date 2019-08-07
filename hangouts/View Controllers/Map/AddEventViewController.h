//
//  AddEventViewController.h
//  hangouts
//
//  Created by josemurillo on 7/17/19.
//  Copyright © 2019 nev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Event.h"

NS_ASSUME_NONNULL_BEGIN

@protocol EditEventControllerDelegate

- (void)didEditEvent:(Event * _Nullable)event;

@end

@protocol CreateEventControllerDelegate

- (void)didCreateEvent:(Event * _Nullable)event;

@end

@interface AddEventViewController : UIViewController

@property (nonatomic, weak) id<EditEventControllerDelegate> delegate;
@property (nonatomic, weak) id<CreateEventControllerDelegate> eventDelegate;
@property (strong, nonatomic) NSString *const userLocation;
@property (strong, nonatomic) Event *event;
@property (strong, nonatomic) NSMutableArray *friendsToInvite;

@end

NS_ASSUME_NONNULL_END
