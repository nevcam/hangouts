//
//  CustomPointAnnotation.h
//  hangouts
//
//  Created by nev on 7/26/19.
//  Copyright © 2019 nev. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "Event.h"
@import Parse;
NS_ASSUME_NONNULL_BEGIN

@interface CustomPointAnnotation : MKPointAnnotation
//{
//    BOOL *checkBoxSelected;
//}
@property (strong, nonatomic) PFUser *friend;
@property (assign, nonatomic) BOOL *checkBoxSelected;
@end

NS_ASSUME_NONNULL_END
