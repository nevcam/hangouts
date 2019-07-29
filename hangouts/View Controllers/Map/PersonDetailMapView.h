//
//  PersonDetailMapView.h
//  hangouts
//
//  Created by nev on 7/29/19.
//  Copyright © 2019 nev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Parse/Parse.h"

NS_ASSUME_NONNULL_BEGIN

@interface PersonDetailMapView : UIView
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (nonatomic, weak) PFUser *user;

@end

NS_ASSUME_NONNULL_END
