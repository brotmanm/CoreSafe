//
//  ImageInfoEditorVC.m
//  CoreSafe
//
//  Created by Main on 1/10/17.
//  Copyright © 2017 Matt Brotman. All rights reserved.
//

#import "ImageInfoEditorVC.h"
#import "UIColor+BFPaperColors.h"
#import "font-awesome-codes.h"
#import "FontAwesome.h"
#import "BFKit.h"
#import "ViewUtils.h"
#import "BouncyButton.h"
#import "SIAlertView.h"
#import "CameraVC.h"
#import "SRActionSheet.h"
#import "ImageViewer.h"

@interface ImageInfoEditorVC () <UIImagePickerControllerDelegate ,UIScrollViewDelegate, ImageViewerDelegate>

@property UIView* divider;
@property UIScrollView* scroller;
@property UIImageView* firstImageView;
@property UIImageView* secondImageView;
@property BouncyButton* cameraButton;
@property BouncyButton* photoLibraryButton;
@property SRActionSheet* sheet;

@end

@implementation ImageInfoEditorVC

int imageToReplace;

- (void)viewDidLoad {
    [super viewDidLoad];
    imageToReplace = -1;
    
    [self.view setBackgroundColor:[UIColor paperColorBlueGray900]];
    
    CGFloat topOfView = [UIApplication sharedApplication].statusBarFrame.size.height + self.navigationController.navigationBar.frame.size.height + 40;
    
    [self.view addSubview:({
        self.scroller = [UIScrollView initWithFrame:self.view.frame contentSize:CGSizeMake(self.view.width, topOfView + SCREEN_HEIGHT + 1 + 40) clipsToBounds:YES pagingEnabled:NO showScrollIndicators:NO delegate:self];
        self.scroller.backgroundColor = [UIColor clearColor];
        self.automaticallyAdjustsScrollViewInsets = NO;
        self.scroller;
    })];
    
    [self.scroller addSubview:({
        self.firstImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, SCREEN_HEIGHT/2)];
        self.firstImageView.backgroundColor = [UIColor blackColor];
        self.firstImageView.contentMode = UIViewContentModeScaleAspectFill;
        self.firstImageView.clipsToBounds = YES;
        
        UITapGestureRecognizer* firstTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageSingleTap:)];
        [self.firstImageView addGestureRecognizer:firstTap];
        UILongPressGestureRecognizer* firstLongPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(imageLongPress:)];
        [firstLongPress requireGestureRecognizerToFail:firstTap];
        [self.firstImageView addGestureRecognizer:firstLongPress];
        
        self.firstImageView;
    })];
    
    [self.scroller addSubview:({
        self.secondImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, self.firstImageView.bottom+1, self.view.width, SCREEN_HEIGHT/2)];
        self.secondImageView.backgroundColor = [UIColor blackColor];
        self.secondImageView.contentMode = UIViewContentModeScaleAspectFill;
        self.secondImageView.clipsToBounds = YES;
        
        UITapGestureRecognizer* secondtap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageSingleTap:)];
        [self.secondImageView addGestureRecognizer:secondtap];
        UILongPressGestureRecognizer* secondLongPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(imageLongPress:)];
        [secondLongPress requireGestureRecognizerToFail:secondtap];
        [self.secondImageView addGestureRecognizer:secondLongPress];
        
        self.secondImageView;
    })];
    
    [self.scroller addSubview:({
        self.divider = [[UIView alloc] initWithFrame:CGRectMake(0, self.firstImageView.bottom, self.view.width, 1)];
        self.divider.backgroundColor = [UIColor grayColor];
        self.divider;
    })];
    
    UIVisualEffectView* imageButtonBar;
    [self.view addSubview:({
        UIBlurEffect* blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
        imageButtonBar = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        imageButtonBar.frame = CGRectMake(0, self.view.height - topOfView - 40, self.view.width, 40);
        imageButtonBar.backgroundColor = [UIColor colorWithColor:[UIColor whiteColor] alpha:0.4];
        imageButtonBar;
    })];
         
    
    [imageButtonBar addSubview:({
        self.cameraButton = [[BouncyButton alloc] initWithFrame:CGRectMake(0, 0, imageButtonBar.width/2 - 1, imageButtonBar.height) raised:NO];
        self.cameraButton.backgroundColor = [UIColor clearColor];
        [self.cameraButton setFont:[FontAwesome fontWithSize:24]];
        [self.cameraButton setTitleColor:[UIColor paperColorBlue900] forState:UIControlStateNormal];
        [self.cameraButton setTitle:fa_camera forState:UIControlStateNormal];
        [self.cameraButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
        self.cameraButton.layer.cornerRadius = self.cameraButton.width/2;
        [self.cameraButton addTarget:self action:@selector(goToCamera:) forControlEvents:UIControlEventTouchUpInside];
        self.cameraButton;
    })];
    
    [imageButtonBar addSubview:({
        self.photoLibraryButton = [[BouncyButton alloc] initWithFrame:CGRectMake(imageButtonBar.width/2 + 1, 0, imageButtonBar.width/2 - 1, imageButtonBar.height) raised:NO];
        self.photoLibraryButton.backgroundColor = [UIColor clearColor];
        [self.photoLibraryButton setFont:[FontAwesome fontWithSize:37]];
        [self.photoLibraryButton setTitleColor:[UIColor paperColorBlue900] forState:UIControlStateNormal];
        [self.photoLibraryButton setTitle:fa_mobile forState:UIControlStateNormal];
        [self.photoLibraryButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
        [self.photoLibraryButton addTarget:self action:@selector(goToPhotoLibrary:) forControlEvents:UIControlEventTouchUpInside];
        self.photoLibraryButton;
    })];

    if (self.safeNote.hasFirstImage) {
        self.firstImageView.image = [UIImage imageWithData:self.safeNote.getFirstImageData];
        self.firstImageView.userInteractionEnabled = YES;
    }
    if (self.safeNote.hasSecondImage) {
        self.secondImageView.image = [UIImage imageWithData:self.safeNote.getSecondImageData];
        self.secondImageView.userInteractionEnabled = YES;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)imageSingleTap:(UIGestureRecognizer*)gesture {
    NSMutableArray* imageArray = [[NSMutableArray alloc] init];
    int selectedImage = 0;
    CGRect currRect;
    if ([gesture.view isEqual:self.firstImageView]){
        [imageArray addObject:[UIImage imageWithData:[self.safeNote getFirstImageData]]];
        if (_safeNote.hasSecondImage) {
            [imageArray addObject:[UIImage imageWithData:[self.safeNote getSecondImageData]]];
        }
        currRect = [_scroller convertRect:self.firstImageView.frame toView:nil];
    }
    else {
        [imageArray addObject:[UIImage imageWithData:[self.safeNote getSecondImageData]]];
        if (_safeNote.hasFirstImage) {
            [imageArray insertObject:[UIImage imageWithData:[self.safeNote getFirstImageData]] atIndex:0];
            selectedImage = 1;
        }
        currRect = [_scroller convertRect:self.secondImageView.frame toView:nil];
    }
    
    ImageViewer* imageViewer = [ImageViewer imageViewerWithImages:imageArray currentIndex:selectedImage originFrame:currRect];
    imageViewer.delegate = self;
    [imageViewer show:YES];
}

-(void)imageLongPress:(UIGestureRecognizer*)gesture {
    if (!_sheet.isShowing){
        __block int selectedImage;
        if ([gesture.view isEqual:self.firstImageView]){
            selectedImage = 0;
        }
        else {
            selectedImage = 1;
        }
        
        self.sheet = [SRActionSheet sr_actionSheetViewWithTitle:NSLocalizedString(@"Image Options", nil)
                                                              cancelTitle:NSLocalizedString(@"Cancel", nil)
                                                         destructiveTitle:nil
                                                              otherTitles:@[@"Save", @"Swap Images", @"Replace Image", @"Delete"]
                                                              otherImages:nil
                                                         selectSheetBlock:^(SRActionSheet *actionSheet, NSInteger index){
                                                             switch (index) {
                                                                 case 0:{
                                                                     [self askWhereToSave:selectedImage];
                                                                     break;
                                                                 }
                                                                 case 1:{
                                                                     [self swapImage:selectedImage];
                                                                     break;
                                                                 }
                                                                 case 2:{
                                                                     [self replaceImage:selectedImage];
                                                                     break;
                                                                 }
                                                                 case 3:{
                                                                     [self deleteImage:selectedImage];
                                                                     break;
                                                                 }
                                                             }
        }];
    
        [_sheet show];
    }
}

-(void)askWhereToSave:(int)imageNumber {
    UIImage* image;
    if (imageNumber == 0) {
        image = [UIImage imageWithData:[self.safeNote getFirstImageData]];
    }
    else {
        image = [UIImage imageWithData:[self.safeNote getSecondImageData]];
    }
    SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"Save Image" andMessage:@"Where would you like to save this image?"];
    [alertView setTitleColor: [UIColor paperColorBlue700]];
    [alertView addButtonWithTitle:@"CoreSafe"
                             type:SIAlertViewButtonTypeDefault
                          handler:^(SIAlertView *alert) {
                              [self saveImage:image toPrivateLibrary:YES];
                          }];
    [alertView addButtonWithTitle:@"Device"
                             type:SIAlertViewButtonTypeDefault
                          handler:^(SIAlertView *alert) {
                              [self saveImage:image toPrivateLibrary:NO];
                          }];
    [alertView addButtonWithTitle:@"Cancel"
                             type:SIAlertViewButtonTypeCancel
                          handler:^(SIAlertView *alert) {
                              
                          }];
    alertView.cornerRadius = 5;
    alertView.transitionStyle = SIAlertViewTransitionStyleBounce;
    [alertView show];
}
-(void)saveImage:(UIImage*)image toPrivateLibrary:(BOOL)isPrivate {
    UIView* darkIndicatorBackground = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    darkIndicatorBackground.backgroundColor = [UIColor colorWithColor:[UIColor blackColor] alpha:0.2];
    BFRadialWaveView* waveView = [[BFRadialWaveView alloc] initWithView:darkIndicatorBackground circles:5 color:[UIColor whiteColor] mode:BFRadialWaveViewMode_Default strokeWidth:5 withGradient:YES];
    [[UIApplication sharedApplication].keyWindow addSubview:darkIndicatorBackground];
    [waveView show];
    if (isPrivate){
        //save to private library
    }
    else {
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
    }
    [darkIndicatorBackground performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:0.5];
}
-(void)deleteImage:(int)imageNumber {
    if (imageNumber == 0) {
        [self.safeNote clearFirstImageData];
        self.firstImageView.image = nil;
        self.firstImageView.userInteractionEnabled = NO;
    }
    else if (imageNumber == 1) {
        [self.safeNote clearSecondImageData];
        self.secondImageView.image = nil;
        self.secondImageView.userInteractionEnabled = NO;
    }
    self.didModifyNote = YES;
}
-(void)replaceImage:(int)imageNumber {
    imageToReplace = imageNumber;
    SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"Replace Image" andMessage:@"How would you like to this image?"];
    [alertView setTitleColor: [UIColor paperColorBlue700]];
    [alertView addButtonWithTitle:@"Camera"
                             type:SIAlertViewButtonTypeDefault
                          handler:^(SIAlertView *alert) {
                              [self goToCamera:alert];
                              self.didModifyNote = YES;
                          }];
    [alertView addButtonWithTitle:@"Photo Library"
                             type:SIAlertViewButtonTypeDefault
                          handler:^(SIAlertView *alert) {
                              [self goToPhotoLibrary:alert];
                              self.didModifyNote = YES;
                          }];
    [alertView addButtonWithTitle:@"Cancel"
                             type:SIAlertViewButtonTypeCancel
                          handler:^(SIAlertView *alert) {
                              imageToReplace = -1;
                          }];
    alertView.cornerRadius = 5;
    alertView.transitionStyle = SIAlertViewTransitionStyleBounce;
    [alertView show];
}
-(void)swapImage:(int)imageNumber {
    if (imageNumber == 0){
        BOOL tempHasSecondImage = self.safeNote.hasSecondImage;
        NSData* tempSecondImageData = [[self.safeNote getSecondImageData] copy];
        
        [self.safeNote setSecondImageData:[self.safeNote getFirstImageData]];
        self.secondImageView.image = self.firstImageView.image;
        self.secondImageView.userInteractionEnabled = YES;
        if (tempHasSecondImage){
            [self.safeNote setFirstImageData:tempSecondImageData];
            self.firstImageView.image = [UIImage imageWithData:tempSecondImageData];
            self.firstImageView.userInteractionEnabled = YES;
        }
        else {
            [self deleteImage:0];
            self.firstImageView.userInteractionEnabled = NO;
        }
        self.didModifyNote = YES;
    }
    else {
        BOOL tempHasFirstImage = self.safeNote.hasFirstImage;
        NSData* tempFirstImageData = [[self.safeNote getFirstImageData] copy];
        
        [self.safeNote setFirstImageData:[self.safeNote getSecondImageData]];
        self.firstImageView.image = self.secondImageView.image;
        self.firstImageView.userInteractionEnabled = YES;
        if (tempHasFirstImage){
            [self.safeNote setSecondImageData:tempFirstImageData];
            self.secondImageView.image = [UIImage imageWithData:tempFirstImageData];
            self.secondImageView.userInteractionEnabled = YES;
        }
        else {
            [self deleteImage:1];
            self.secondImageView.userInteractionEnabled = NO;
        }
        self.didModifyNote = YES;
    }
}

-(void)goToCamera:(id)sender {
    if ([UIImagePickerController isSourceTypeAvailable:
         UIImagePickerControllerSourceTypeCamera])
    {
        CameraVC* camera = [[CameraVC alloc] init];
        camera.didDismiss = ^(BOOL usingPhoto, UIImage* image) {
            if (usingPhoto) {
                [self addImageToSelf:image];
            }
            imageToReplace = -1;
        };
        [self presentViewController:camera animated:YES completion:^ {
            
        }];
    }
}

-(void)goToPhotoLibrary:(id)sender {
    if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeSavedPhotosAlbum])
    {
        __block UIView* darkIndicatorBackground = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        darkIndicatorBackground.backgroundColor = [UIColor colorWithColor:[UIColor blackColor] alpha:0.2];
        BFRadialWaveView* waveView = [[BFRadialWaveView alloc] initWithView:darkIndicatorBackground circles:5 color:[UIColor paperColorGray100] mode:BFRadialWaveViewMode_Default strokeWidth:5 withGradient:YES];
        [[UIApplication sharedApplication].keyWindow addSubview:darkIndicatorBackground];
        [waveView show];
        
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
            UIImagePickerController* imagePicker = [[UIImagePickerController alloc] init];
            imagePicker.delegate = self;
            imagePicker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
            imagePicker.allowsEditing = YES;
            
            dispatch_async(dispatch_get_main_queue(), ^(void){
                [darkIndicatorBackground removeFromSuperview];
                [self presentViewController:imagePicker animated:YES completion:nil];
            });
        });
    }
}

-(void)addImageToSelf:(UIImage*)image {
    if (imageToReplace == 0) {
        [self.safeNote setFirstImageData:UIImagePNGRepresentation(image)];
        self.firstImageView.image = image;
    }
    else if (imageToReplace == 1) {
        [self.safeNote setSecondImageData:UIImagePNGRepresentation(image)];
        self.secondImageView.image = image;
    }
    else {
        if (!self.safeNote.hasFirstImage) {
            self.firstImageView.image = image;
            self.firstImageView.userInteractionEnabled = YES;
            [self.safeNote setFirstImageData:UIImagePNGRepresentation(image)];
            self.didModifyNote = YES;
        }
        else if (!self.safeNote.hasSecondImage) {
            self.secondImageView.image = image;
            self.secondImageView.userInteractionEnabled = YES;
            [self.safeNote setSecondImageData:UIImagePNGRepresentation(image)];
            self.didModifyNote = YES;
        }
        else {
            SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"Replace Image" andMessage:@"Which image would you like to replace?"];
            [alertView setTitleColor: [UIColor paperColorBlue700]];
            [alertView addButtonWithTitle:@"Replace First Image"
                                     type:SIAlertViewButtonTypeDefault
                                  handler:^(SIAlertView *alert) {
                                      self.firstImageView.image = image;
                                      self.firstImageView.userInteractionEnabled = YES;
                                      [self.safeNote setFirstImageData:UIImagePNGRepresentation(image)];
                                      self.didModifyNote = YES;
                                  }];
            [alertView addButtonWithTitle:@"Replace Second Image"
                                     type:SIAlertViewButtonTypeDefault
                                  handler:^(SIAlertView *alert) {
                                      self.secondImageView.image = image;
                                      self.secondImageView.userInteractionEnabled = YES;
                                      [self.safeNote setSecondImageData:UIImagePNGRepresentation(image)];
                                      self.didModifyNote = YES;
                                  }];
            [alertView addButtonWithTitle:@"Cancel"
                                     type:SIAlertViewButtonTypeCancel
                                  handler:^(SIAlertView *alert) {
                                      
                                  }];
            alertView.cornerRadius = 5;
            alertView.transitionStyle = SIAlertViewTransitionStyleBounce;
            [alertView show];
        }
    }
}

#pragma mark - ImageViewerDelegate
- (void)imageViewer:(ImageViewer*)viewer didDeleteImageAtIndex:(NSInteger)index {
    NSLog(@"delete");
    if (index == 1) {
        [self deleteImage:1];
    }
    else if (index == 0) {
        if (self.safeNote.hasSecondImage && !self.safeNote.hasFirstImage) {
            [self deleteImage:1];
        }
        else {
            [self deleteImage:0];
        }
    }
    [viewer dismiss:NO];
}
- (void)imageViewer:(ImageViewer*)viewer didSaveImageAtIndex:(NSInteger)index {
    if (index == 1) {
        [self askWhereToSave:1];
    }
    else if (index == 0) {
        if (self.safeNote.hasSecondImage && !self.safeNote.hasFirstImage) {
            [self askWhereToSave:1];
        }
        else {
            [self askWhereToSave:0];
        }
    }

}
- (void)imageViewer:(ImageViewer*)viewer dismissAnimationsBeganAtIndex:(NSInteger)index {
    if (index == 1) {
        [self.scroller setContentOffset:CGPointMake(0, _scroller.contentSize.height - _scroller.bounds.size.height)];
        viewer.destinationRect = [_scroller convertRect:self.secondImageView.frame toView:nil];
        self.secondImageView.image = nil;
    }
    else if (index == 0) {
        if (self.safeNote.hasSecondImage && !self.safeNote.hasFirstImage) {
            [self.scroller setContentOffset:CGPointMake(0, _scroller.contentSize.height - _scroller.bounds.size.height)];
            viewer.destinationRect = [_scroller convertRect:self.secondImageView.frame toView:nil];
            self.secondImageView.image = nil;
        }
        else {
            [self.scroller setContentOffset:CGPointMake(0, 0)];
            viewer.destinationRect = [_scroller convertRect:self.firstImageView.frame toView:nil];
            self.firstImageView.image = nil;
        }
    }
}
-(void)imageViewer:(ImageViewer *)viewer dismissAnimationsCancelledAtIndex:(NSInteger)index {
    if (index == 1) {
        self.secondImageView.image = [viewer.imageArray objectAtIndex:index];
    }
    else if (index == 0) {
        if (self.safeNote.hasSecondImage && !self.safeNote.hasFirstImage) {
            self.secondImageView.image = [viewer.imageArray objectAtIndex:index];
        }
        else {
            self.firstImageView.image = [viewer.imageArray objectAtIndex:index];
        }
    }
}
-(void)imageViewer:(ImageViewer *)viewer didDismissFromIndex:(NSInteger)index animated:(BOOL)animated {
    if (animated) {
        if (index == 1) {
            self.secondImageView.image = [viewer.imageArray objectAtIndex:index];
        }
        else if (index == 0) {
            if (self.safeNote.hasSecondImage && !self.safeNote.hasFirstImage) {
                self.secondImageView.image = [viewer.imageArray objectAtIndex:index];
            }
            else {
                self.firstImageView.image = [viewer.imageArray objectAtIndex:index];
            }
        }
    }
}

#pragma mark - UIImagePickerControllerDelegate
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    //NSString* mediaType = info[UIImagePickerControllerMediaType];
    UIImage* image = info[UIImagePickerControllerOriginalImage];
    
    [self addImageToSelf:image];
    imageToReplace = -1;
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    imageToReplace = -1;
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
