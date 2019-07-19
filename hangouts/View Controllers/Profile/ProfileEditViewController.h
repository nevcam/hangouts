//
//  ProfileEditViewController.h
//  hangouts
//
//  Created by nev on 7/19/19.
//  Copyright © 2019 nev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Parse/Parse.h"

NS_ASSUME_NONNULL_BEGIN

@protocol ProfileEditViewControllerDelegate
- (void)didSave;
@end

@interface ProfileEditViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIImageView *profilePhotoView;
@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UITextField *bioField;
@property (nonatomic, weak) id<ProfileEditViewControllerDelegate> delegate;
@property (strong, nonatomic) PFUser *user;
@end

NS_ASSUME_NONNULL_END
