//
//  EventPointAnnotation.h
//  hangouts
//
//  Created by nev on 7/29/19.
//  Copyright © 2019 nev. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "Event.h"
NS_ASSUME_NONNULL_BEGIN

@interface EventPointAnnotation : MKPointAnnotation
@property (strong, nonatomic) Event *event;
@end

NS_ASSUME_NONNULL_END
