//
//  CustomAnnotationButton.h
//  hangouts
//
//  Created by nev on 8/5/19.
//  Copyright © 2019 nev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Event.h"

@class PFUser;

NS_ASSUME_NONNULL_BEGIN

@interface CustomAnnotationButton : UIButton

@property (strong, nonatomic) PFUser *friendUser;
@property (strong, nonatomic) Event *event;

@end

NS_ASSUME_NONNULL_END
