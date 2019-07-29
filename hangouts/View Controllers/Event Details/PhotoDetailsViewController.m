//
//  PhotoDetailsViewController.m
//  hangouts
//
//  Created by josemurillo on 7/29/19.
//  Copyright © 2019 nev. All rights reserved.
//

#import "PhotoDetailsViewController.h"

@interface PhotoDetailsViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *photoView;
@property (weak, nonatomic) IBOutlet UIButton *downloadButton;

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
}

#pragma mark - Download Image

- (IBAction)clickedDownload:(id)sender {
    UIImageWriteToSavedPhotosAlbum(self.photoView.image, nil, nil, nil);
}

@end
