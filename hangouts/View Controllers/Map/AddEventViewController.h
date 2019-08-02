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

@interface AddEventViewController : UIViewController

@property (strong, nonatomic) NSString *const userLocation;
@property (strong, nonatomic) Event *event;

@end

NS_ASSUME_NONNULL_END
