//
//  SignUpViewController.m
//  hangouts
//
//  Created by sroman98 on 7/17/19.
//  Copyright © 2019 nev. All rights reserved.
//

#import "SignUpViewController.h"
#import "Friendship.h"
@import Parse;

@interface SignUpViewController () <UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UILabel *errorLabel;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;

@end

@implementation SignUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.nameField.delegate = self;
    self.usernameField.delegate = self;
    self.emailField.delegate = self;
    self.passwordField.delegate = self;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

// MARK: class methods

- (IBAction)didTapRegister:(id)sender {
    // initialize a user object
    PFUser *newUser = [PFUser user];
    
    // set user properties
    newUser.username = self.usernameField.text;
    newUser.email = self.emailField.text;
    newUser.password = self.passwordField.text;
    
    [newUser setObject:self.nameField.text forKey:@"fullname"];
    
    [self assignImageToUser:newUser];
    
    NSArray *fieldsStrings = [NSArray arrayWithObjects:self.usernameField.text, self.nameField.text, self.emailField.text, self.passwordField.text, nil];
    
    if([self validateStrings:fieldsStrings]) {
        [self.errorLabel setHidden:YES];
        [self registerUser:newUser];
    } else {
        self.errorLabel.text = @"Please fill in all fields";
        [self.errorLabel setHidden:NO];
        NSLog(@"Didn't fill out all fields.");
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
    // call sign up function on the object
    [newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError * error) {
        if (error != nil) {
            self.errorLabel.text = [NSString stringWithFormat:@"%@",error.localizedDescription];
            [self.errorLabel setHidden:NO];
            NSLog(@"Error: %@", error.localizedDescription);
        } else {
            // Will try to create a row in friendship for the newUser
            [Friendship createFriendshipForUser:newUser.username withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
                if(succeeded) {
                    NSLog(@"Created friendship successfully");
                } else {
                    NSLog(@"Couldn't create friendship: %@", error);
                }
                // User was created successfully, independent from friendship creation
                [self.errorLabel setHidden:YES];
                NSLog(@"User registered successfully");
                [self.delegate registerUserWithStatus:YES];
                // manually dismiss view controller for user to log in
                [self dismissViewControllerAnimated:true completion:nil];
            }];
        }
    }];
}

- (IBAction)didTapCancel:(id)sender {
    [self dismissViewControllerAnimated:true completion:nil];
}


// MARK: image methods

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
    // Get the image captured by the UIImagePickerController
    UIImage *editedImage = info[UIImagePickerControllerEditedImage];
    UIImage *resizedImage = [self resizeImage:editedImage withSize:CGSizeMake(350, 350)];
    self.profileImageView.image = resizedImage;
    
    // Dismiss UIImagePickerController to go back to your original view controller
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
    if(self.profileImageView.image != nil) {
        imageData = UIImageJPEGRepresentation(self.profileImageView.image, 1.0);
    } else {
        UIImage *pic = [UIImage imageNamed:@"profile"];
        imageData = UIImageJPEGRepresentation(pic, 1.0);
    }
    PFFileObject *img = [PFFileObject fileObjectWithName:@"profilePic.png" data:imageData];
    [img saveInBackground];
    
    [user setObject:img forKey:@"profilePhoto"];
    [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            NSLog(@"Uploaded profile pic!");
        } else {
            NSLog(@"Error uploading profile pic: %@", error);
        }
    }];
}

// MARK: keyboard methods

// This method dismisses the keyboard when you hit return
- (IBAction)didTapReturn:(id)sender {
    [self.nameField resignFirstResponder];
    [self.usernameField resignFirstResponder];
    [self.emailField resignFirstResponder];
    [self.passwordField resignFirstResponder];
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
    [UIView animateWithDuration:0.2 animations:^{
        CGRect frame = self.view.frame;
        frame.origin.y = -keyboardSize.height + 100;
        self.view.frame = frame;
    }];
}

-(void)keyboardWillHide:(NSNotification *)notification {
    [UIView animateWithDuration:0.2 animations:^{
        CGRect frame = self.view.frame;
        frame.origin.y = 0;
        self.view.frame = frame;
    }];
}

@end
