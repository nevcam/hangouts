//
//  CustomTapGestureRecognizer.h
//  hangouts
//
//  Created by nev on 8/6/19.
//  Copyright © 2019 nev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
@class PFUser;
NS_ASSUME_NONNULL_BEGIN

@interface CustomTapGestureRecognizer : UITapGestureRecognizer
@property (strong, nonatomic) PFUser *friendUser;
@property (strong, nonatomic) MKAnnotationView *annotationView;
@end

NS_ASSUME_NONNULL_END
