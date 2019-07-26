//
//  PhotosViewController.m
//  hangouts
//
//  Created by josemurillo on 7/26/19.
//  Copyright © 2019 nev. All rights reserved.
//

#import "PhotosViewController.h"
#import "Photo.h"
#import "Event.h"

@interface PhotosViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation PhotosViewController

#pragma mark - Global Variables
{
    NSMutableArray *_photosCollection;
    Event *_currentEvent;
}

#pragma mark - Load View Controller

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

#pragma mark - FetchPhotos

- (void)fetchPhotos {
    
}

#pragma mark - Load Image Selector View Controller

// Pushes Add Photo View Controller when triggered
- (IBAction)clickedAddPhoto:(id)sender {
    UIImagePickerController *imagePickerVC = [UIImagePickerController new];
    imagePickerVC.delegate = self;
    imagePickerVC.allowsEditing = YES;
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        imagePickerVC.sourceType = UIImagePickerControllerSourceTypeCamera;
    }
    else {
        NSLog(@"Camera 🚫 available so we will use photo library instead");
        imagePickerVC.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    
    [self presentViewController:imagePickerVC animated:YES completion:nil];
}

// Saves photo when image has been chosen
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    
    if (!self->_photosCollection) {
        self->_photosCollection = [NSMutableArray new];
    }
    [self->_photosCollection addObject:info[UIImagePickerControllerOriginalImage]];
    
//    PFObject *photo = [PFObject objectWithClassName:@"Photo"];
//    photo.photo = info[UIImagePickerControllerOriginalImage];
//    photo[@"user"] = [PFUser currentUser];
//    photo[@"event"] = _currentEvent;
//    
////    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:_photosCollection.count inSection:0];
////    NSMutableArray *paths = [NSMutableArray new];
////    [paths addObject:indexPath];
//    
//    [photo saveInBackgroundWithBlock:^(BOOL succeeded, NSError * error) {
//        if (succeeded) {
//            [self fetchPhotos];
//        } else {
//            NSLog(@"Problem saving photo: %@", error.localizedDescription);
//        }
//    }];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
