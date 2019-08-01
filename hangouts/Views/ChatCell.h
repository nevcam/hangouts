//
//  ChatCell.h
//  hangouts
//
//  Created by nev on 7/22/19.
//  Copyright © 2019 nev. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ChatCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *chatMessageLabel;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UIView *messageBubbleView;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIImageView *profilePhotoView;
@property (weak, nonatomic) NSLayoutConstraint *leftBubbleConstraint;
@property (weak, nonatomic) NSLayoutConstraint *rightBubbleConstraint;
@property (weak, nonatomic) NSLayoutConstraint *topBubbleConstraint;
@end

NS_ASSUME_NONNULL_END
