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
#import "PhotoDetailsViewController.h"

@interface PhotosViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegate, RemovePhotoDelegate>

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
    
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    
    UINavigationController *const navController = (UINavigationController *) self.parentViewController;
    EventTabBarController *const tabBar = (EventTabBarController *)navController.parentViewController;
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
            if (strongSelf) {
                strongSelf->_photosCollection = [NSMutableArray arrayWithArray:photos];
                [strongSelf.collectionView reloadData];
            } else {
                NSLog(@"Error: view controller has been closed");
            }
        } else {
            NSLog(@"Error getting photod: %@", error.localizedDescription);
        }
    }];
}

#pragma mark - Image Selector View Controller

- (void) selectPhoto {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self presentViewController:picker animated:YES completion:NULL];
}

- (void)takePhoto {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    [self presentViewController:picker animated:YES completion:NULL];
}

// Pushes Add Photo View Controller when triggered
- (IBAction)clickedAddPhoto:(id)sender {
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        [actionSheet dismissViewControllerAnimated:YES completion:nil];
    }]];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Select Photo" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self selectPhoto];
    }]];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Take Photo" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self takePhoto];
    }]];
    
    [self presentViewController:actionSheet animated:YES completion:nil];
}

// Saves photo when image has been chosen
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    
    UIImage *const originalImage = info[UIImagePickerControllerOriginalImage];
    
    if (!_photosCollection) {
        _photosCollection = [NSMutableArray new];
    }
    [_photosCollection addObject:info[UIImagePickerControllerOriginalImage]];
    
    UIImage *const imageToPost = [self resizeImage:originalImage withSize:CGSizeMake(200, 200)];
    
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
    Photo *newPhoto = _photosCollection[indexPath.row];
    
    [newPhoto.photo getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        if (!data) {
            return NSLog(@"%@", error);
        }
        cell.image.image = [UIImage imageWithData:data];
    }];
    return cell;
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _photosCollection.count;
}

#pragma mark - Photo Details Segue

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    [self performSegueWithIdentifier:@"photoDetailsSegue" sender:[collectionView cellForItemAtIndexPath:indexPath]];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"photoDetailsSegue"]) {
        PhotoCell *tappedCell = sender;
        NSIndexPath *indexPath = [_collectionView indexPathForCell:tappedCell];
        
        Photo *checkPhoto = _photosCollection[indexPath.row];
        
        PhotoDetailsViewController *detailsView = [segue destinationViewController];
        detailsView.photoObject = checkPhoto;
        detailsView.delegate = self;
    }
}

#pragma mark - Delegate Method when deleting photos

- (void)removeAPhoto {
    [self fetchPhotos];
}

#pragma mark - View Controller Layout

// Sets spacing and margins between the cells in the collection view
- (void)setCollectionLayout {
    
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)_collectionView.collectionViewLayout;
    
    // Sets margins between posts, view, and other posts
    layout.minimumInteritemSpacing = 7;
    layout.minimumLineSpacing = 7;
    const CGFloat margins = 14;
    
    // Sets amount of posters per line
    const CGFloat postersPerLine = 3;
    
    // Sets post width and height, based on previous values
    const CGFloat itemWidth = (_collectionView.frame.size.width - margins - layout.minimumInteritemSpacing * (postersPerLine - 1)) / postersPerLine;
    const CGFloat itemHeight = itemWidth * 1.5;
    layout.itemSize = CGSizeMake (itemWidth, itemHeight);
}

- (IBAction)didTapClose:(id)sender {
    [self dismissViewControllerAnimated:true completion:nil];
}

@end
