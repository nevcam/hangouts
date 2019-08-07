//
//  myDayTableViewCell.h
//  hangouts
//
//  Created by josemurillo on 8/5/19.
//  Copyright © 2019 nev. All rights reserved.
//

#import <UIKit/UIKit.h>
@class myDayTableViewCell;

@interface myDayTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *eventNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *eventTImeLabel;
@property (weak, nonatomic) IBOutlet UILabel *eventLocationLabel;

@end

