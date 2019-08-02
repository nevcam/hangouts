//
//  UserCell.h
//  hangouts
//
//  Created by sroman98 on 8/1/19.
//  Copyright © 2019 nev. All rights reserved.
//

#import <UIKit/UIKit.h>
@import Parse;

NS_ASSUME_NONNULL_BEGIN

@interface UserCell : UICollectionViewCell

@property (strong, nonatomic) PFUser *user;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

- (void)configureCell:(PFUser *)user;

@end

NS_ASSUME_NONNULL_END
