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
#import "PhotoCell.h"

@interface PhotosViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

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
    
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    
    UINavigationController *navController = (UINavigationController *) self.parentViewController;
    EventTabBarController *tabBar = (EventTabBarController *)navController.parentViewController;
    _currentEvent = tabBar.event;
    
    [self fetchPhotos];
    [self setCollectionLayout];
}

#pragma mark - FetchPhotos

- (void)fetchPhotos {
    PFQuery *photoQuery = [Photo query];
    [photoQuery orderByDescending:@"createdAt"];
    [photoQuery includeKey:@"user"];
    photoQuery.limit = 100;
    [photoQuery whereKey:@"event" equalTo:_currentEvent];
    
    __weak typeof(self) weakSelf = self;
    [photoQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable photos, NSError * _Nullable error) {
        if (photos) {
            
            __strong typeof(self) strongSelf = weakSelf;
            
            if (!strongSelf->_photosCollection) {
                 strongSelf->_photosCollection = [NSMutableArray new];
            }
            strongSelf->_photosCollection = (NSMutableArray *)photos;
            [self.collectionView reloadData];
            
        } else {
            NSLog(@"Error getting photod: %@", error.localizedDescription);
        }
    }];
}

#pragma mark - Image Selector View Controller

// Pushes Add Photo View Controller when triggered
- (IBAction)clickedAddPhoto:(id)sender {
    UIImagePickerController *imagePickerVC = [UIImagePickerController new];
    imagePickerVC.delegate = self;
    imagePickerVC.allowsEditing = YES;
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        imagePickerVC.sourceType = UIImagePickerControllerSourceTypeCamera;
    }
    else {
        imagePickerVC.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    
    [self presentViewController:imagePickerVC animated:YES completion:nil];
}

// Saves photo when image has been chosen
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    
    UIImage *originalImage = info[UIImagePickerControllerOriginalImage];
    
    if (!self->_photosCollection) {
        self->_photosCollection = [NSMutableArray new];
    }
    [self->_photosCollection addObject:info[UIImagePickerControllerOriginalImage]];
    
    UIImage *imageToPost = [self resizeImage:originalImage withSize:CGSizeMake(400, 400)];
    
    [Photo addPhoto:imageToPost event:_currentEvent withCompletion:^(BOOL succeeded, NSError *error) {
        if (error) {
            NSLog(@"Failed to upload photo");
        } else {
            [self fetchPhotos];
        }
    }];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

// Resize image for it to fit server conditions
- (UIImage *)resizeImage:(UIImage *)image withSize:(CGSize)size {
    UIImageView *resizeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    
    resizeImageView.contentMode = UIViewContentModeScaleAspectFill;
    resizeImageView.image = image;
    
    UIGraphicsBeginImageContext(size);
    [resizeImageView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

#pragma mark - Load Photos to Collection View

- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    
    PhotoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PhotCollectionCell" forIndexPath:indexPath];
    Photo *newPhoto = self->_photosCollection[indexPath.row];
    
    [newPhoto.photo getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        if (!data) {
            return NSLog(@"%@", error);
        }
        cell.image.image = [UIImage imageWithData:data];
    }];
    return cell;
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self->_photosCollection.count;
}

#pragma mark - View Controller Layout

// Sets spacing and margins between the cells in the collection view
- (void)setCollectionLayout {
    
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    
    // Sets margins between posts, view, and other posts
    layout.minimumInteritemSpacing = 7;
    layout.minimumLineSpacing = 7;
    CGFloat margins = 14;
    
    // Sets amount of posters per line
    CGFloat postersPerLine = 3;
    
    // Sets post width and height, based on previous values
    CGFloat itemWidth = (self.collectionView.frame.size.width - margins - layout.minimumInteritemSpacing * (postersPerLine - 1)) / postersPerLine;
    CGFloat itemHeight = itemWidth * 1.5;
    layout.itemSize = CGSizeMake (itemWidth, itemHeight);
}

@end
