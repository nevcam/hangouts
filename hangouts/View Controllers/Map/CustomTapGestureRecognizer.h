//
//  CustomTapGestureRecognizer.h
//  hangouts
//
//  Created by nev on 8/6/19.
//  Copyright © 2019 nev. All rights reserved.
//

#import <UIKit/UIKit.h>
@class PFUser;
NS_ASSUME_NONNULL_BEGIN

@interface CustomTapGestureRecognizer : UITapGestureRecognizer
@property (strong, nonatomic) PFUser *friendUser;
@end

NS_ASSUME_NONNULL_END
