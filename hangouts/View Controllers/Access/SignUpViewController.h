//
//  SignUpViewController.h
//  hangouts
//
//  Created by sroman98 on 7/17/19.
//  Copyright © 2019 nev. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol SignUpViewControllerDelegate
- (void)registerUserWithStatus:(BOOL)successful;
@end

@interface SignUpViewController : UIViewController
@property (nonatomic, weak) id<SignUpViewControllerDelegate> delegate;
@end

NS_ASSUME_NONNULL_END
