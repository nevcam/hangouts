
//
//  PhotoDetailsViewController.m
//  hangouts
//
//  Created by josemurillo on 7/29/19.
//  Copyright © 2019 nev. All rights reserved.
//

#import "PhotoDetailsViewController.h"
#import "PhotosViewController.h"

@interface PhotoDetailsViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *photoView;
@property (weak, nonatomic) IBOutlet UIButton *downloadButton;
@property (weak, nonatomic) IBOutlet UILabel *dateView;

@end

@implementation PhotoDetailsViewController

#pragma mark - Load View Controller

- (void)viewDidLoad {
    [super viewDidLoad];
    [self refreshData];
}

#pragma mark - Fetch Post

- (void)refreshData {
    [self.photoObject.photo getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        if (!data) {
            return NSLog(@"%@", error);
        }
        self.photoView.image = [UIImage imageWithData:data];
    }];
    self.dateView.text = [self getDate];
}

#pragma mark - Download Image

- (IBAction)clickedDownload:(id)sender {
    UIImageWriteToSavedPhotosAlbum(self.photoView.image, nil, nil, nil);
}

#pragma mark - Delete Image

- (IBAction)clickedDelete:(id)sender {
    PFQuery *query = [PFQuery queryWithClassName:@"Photo"];
    [query whereKey:@"objectId" equalTo:self.photoObject.objectId];
    
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (object) {
            [object deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (succeeded) {
                     [self.delegate removeAPhoto];
                     [self.navigationController popViewControllerAnimated:YES];
                } else {
                     NSLog(@"Error while deleting photo %@.", error);
                }
            }];
        } else {
            NSLog(@"Error while accessing parse %@.", error);
        }
    }];
}

#pragma mark - Customize Date
- (NSString *)getDate {
    
    NSDate *createdAt = [self.photoObject createdAt];
    NSDate *todayDate = [NSDate date];
    double ti = [createdAt timeIntervalSinceDate:todayDate];
    ti = ti * -1;
    
    if(ti < 1) {
        return @"never";
    } else  if (ti < 60) {
        return @"less than a minute ago";
    } else if (ti < 120) {
        int diff = round(ti / 60);
        return [NSString stringWithFormat:@"%d minute ago", diff];
    } else if (ti < 3600) {
        int diff = round(ti / 60);
        return [NSString stringWithFormat:@"%d minutes ago", diff];
    } else if (ti < 7200) {
        int diff = round(ti / 60 / 60);
        return [NSString stringWithFormat:@"%d hour ago", diff];
    } else if (ti < 86400) {
        int diff = round(ti / 60 / 60);
        return [NSString stringWithFormat:@"%d hours ago", diff];
    } else if (ti < 172800) {
        int diff = round(ti / 60 / 60 / 24);
        return [NSString stringWithFormat:@"%d days ago", diff];
    } else if (ti < 2629743) {
        int diff = round(ti / 60 / 60 / 24);
        return [NSString stringWithFormat:@"%d days ago", diff];
    } else {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"E MMM d HH:mm:ss Z y";
        formatter.dateStyle = NSDateFormatterShortStyle;
        formatter.timeStyle = NSDateFormatterNoStyle;
        // Convert Date to String
        return [formatter stringFromDate:createdAt];
    }
}

@end
