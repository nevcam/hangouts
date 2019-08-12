//
//  SignUpViewController.m
//  hangouts
//
//  Created by sroman98 on 7/17/19.
//  Copyright © 2019 nev. All rights reserved.
//

#import "SignUpViewController.h"
#import "Friendship.h"
#import <SVProgressHUD/SVProgressHUD.h>
@import Parse;

@interface SignUpViewController () <UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UILabel *errorLabel;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end

@implementation SignUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _nameField.delegate = self;
    _usernameField.delegate = self;
    _emailField.delegate = self;
    _passwordField.delegate = self;
    // make profile photo a circle
    _profileImageView.layer.cornerRadius = _profileImageView.frame.size.height /2;
    _profileImageView.layer.masksToBounds = YES;
    _profileImageView.layer.borderWidth = 0;
}

#pragma mark -  class methods

- (IBAction)didTapRegister:(id)sender {
    [SVProgressHUD show];
    PFUser *newUser = [PFUser user];
    newUser.username = _usernameField.text;
    newUser.email = _emailField.text;
    newUser.password = _passwordField.text;
    [newUser setObject:_nameField.text forKey:@"fullname"];
    [self assignImageToUser:newUser];
    
    NSArray *fieldsStrings = [NSArray arrayWithObjects:_usernameField.text, _nameField.text, _emailField.text, _passwordField.text, nil];
    if([self validateStrings:fieldsStrings]) {
        [_errorLabel setHidden:YES];
        [self registerUser:newUser];
    } else {
        _errorLabel.text = @"Please fill in all fields";
        [_errorLabel setHidden:NO];
    }
}

- (BOOL)validateStrings:(NSArray *)strings {
    for (NSString *string in strings) {
        NSString *stringNoSpaces = [string stringByReplacingOccurrencesOfString:@" " withString:@""];
        if([stringNoSpaces isEqualToString:@""]) {
            return NO;
        }
    }
    return YES;
}

- (void)registerUser:(PFUser *)newUser {
    __weak typeof(self) weakSelf = self;
    [newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError * error) {
        if (error != nil) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if(strongSelf) {
                [SVProgressHUD dismiss];
                if(error.code == 100) {
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Cannot Connect" message:@"The Internet connection appears to be offline." preferredStyle:(UIAlertControllerStyleAlert)];
                    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleCancel handler:nil];
                    [alert addAction:okAction];
                    [strongSelf presentViewController:alert animated:YES completion:nil];
                } else {
                    strongSelf.errorLabel.text = [NSString stringWithFormat:@"%@",error.localizedDescription];
                    [strongSelf.errorLabel setHidden:NO];
                    NSLog(@"Error: %@", error.localizedDescription);
                }
            }
        } else {
            [Friendship createFriendshipForUser:newUser withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
                __strong typeof(weakSelf) strongSelf = weakSelf;
                if(strongSelf) {
                    [SVProgressHUD dismiss];
                    if(!succeeded) {
                        NSLog(@"Couldn't create friendship: %@", error.localizedDescription);
                    }
                    // User was created successfully, independent from friendship creation
                    [strongSelf.errorLabel setHidden:YES];
                    [strongSelf.delegate registerUserWithStatus:YES];
                    [strongSelf dismissViewControllerAnimated:true completion:nil];
                }
            }];
        }
    }];
}

- (IBAction)didTapCancel:(id)sender {
    [self dismissViewControllerAnimated:true completion:nil];
}

#pragma mark -  image methods

- (IBAction)didTapImage:(id)sender {
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
    UIImage *resizedImage = [self resizeImage:editedImage withSize:CGSizeMake(200, 200)];
    _profileImageView.image = resizedImage;
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

- (void)assignImageToUser: (PFUser *)user {
    NSData *imageData;
    if(_profileImageView.image != nil) {
        imageData = UIImageJPEGRepresentation(_profileImageView.image, 1.0);
    } else {
        UIImage *pic = [UIImage imageNamed:@"profile"];
        imageData = UIImageJPEGRepresentation(pic, 1.0);
    }
    PFFileObject *img = [PFFileObject fileObjectWithName:@"profilePic.png" data:imageData];
    [user setObject:img forKey:@"profilePhoto"];
}

#pragma mark -  keyboard methods

// This method dismisses the keyboard when you hit return
- (IBAction)didTapReturn:(id)sender {
    [_nameField resignFirstResponder];
    [_usernameField resignFirstResponder];
    [_emailField resignFirstResponder];
    [_passwordField resignFirstResponder];
}

// The following methods let the view move up/down when keybord is shown/dismissed
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardDidShowNotification object:nil];
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardDidHideNotification object:nil];
    [self.view endEditing:YES];
    return YES;
}

- (void)keyboardWillShow:(NSNotification *)notification {
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.2 animations:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if(strongSelf) {
            CGRect frame = strongSelf.view.frame;
            frame.origin.y = -keyboardSize.height + 100;
            strongSelf.view.frame = frame;
        }
    }];
}

-(void)keyboardWillHide:(NSNotification *)notification {
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.2 animations:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if(strongSelf) {
            CGRect frame = strongSelf.view.frame;
            frame.origin.y = 0;
            strongSelf.view.frame = frame;
        }
    }];
}

@end
