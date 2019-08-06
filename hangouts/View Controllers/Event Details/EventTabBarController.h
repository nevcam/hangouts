//
//  EventTabBarController.h
//  hangouts
//
//  Created by nev on 7/22/19.
//  Copyright © 2019 nev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Event.h"
NS_ASSUME_NONNULL_BEGIN

@interface EventTabBarController : UITabBarController
@property (strong, nonatomic) Event *event;
@end

NS_ASSUME_NONNULL_END
