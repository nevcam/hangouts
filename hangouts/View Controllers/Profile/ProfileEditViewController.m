//
//  ProfileEditViewController.m
//  hangouts
//
//  Created by nev on 7/19/19.
//  Copyright © 2019 nev. All rights reserved.
//

#import "ProfileEditViewController.h"
#import "UIImageView+AFNetworking.h"

@interface ProfileEditViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@end

@implementation ProfileEditViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.nameField.text = self.user[@"fullname"];
    self.bioField.text = self.user[@"bio"];
    PFFileObject *imageFile = self.user[@"profilePhoto"];
    NSURL *photoURL = [NSURL URLWithString:imageFile.url];
    self.profilePhotoView.image = nil;
    [self.profilePhotoView setImageWithURL:photoURL];
    
}

- (IBAction)didTapCancel:(id)sender {
    [self dismissViewControllerAnimated:true completion:nil];
}

- (IBAction)didTapSave:(id)sender {
    self.user[@"bio"] = self.bioField.text;
    NSData *imageData = UIImageJPEGRepresentation(self.profilePhotoView.image, 0.5f);
    PFFileObject *imageFile = [PFFileObject fileObjectWithName:@"Profileimage.png" data:imageData];
    self.user[@"profilePhoto"] = imageFile;
    __weak typeof(self) weakSelf = self;
    [self.user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            [strongSelf.delegate didSave];
            [strongSelf dismissViewControllerAnimated:true completion:nil];
        } else {
        }
    }];
}

- (IBAction)didTapChangeProfilePhoto:(id)sender {
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

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    UIImage *editedImage = info[UIImagePickerControllerEditedImage];
    UIImage *resizedEdited = [self resizeImage:editedImage withSize:CGSizeMake(500, 500)];
    self.profilePhotoView.image = resizedEdited;
    [self dismissViewControllerAnimated:YES completion:nil];
}

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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
