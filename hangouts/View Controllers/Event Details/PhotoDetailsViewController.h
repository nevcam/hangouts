//
//  PhotoDetailsViewController.h
//  hangouts
//
//  Created by josemurillo on 7/29/19.
//  Copyright © 2019 nev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Photo.h"

NS_ASSUME_NONNULL_BEGIN

@protocol RemovePhotoDelegate <NSObject>
- (void)removeAPhoto;
@end

@interface PhotoDetailsViewController : UIViewController

@property (nonatomic, strong) Photo *photoObject;
@property (nonatomic, weak) id <RemovePhotoDelegate> delegate;


@end

NS_ASSUME_NONNULL_END




