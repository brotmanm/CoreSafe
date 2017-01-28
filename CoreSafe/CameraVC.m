//
//  CameraVC.m
//  iLock
//
//  Created by Main on 8/13/16.
//  Copyright © 2016 Matt Brotman. All rights reserved.
//

#import "CameraVC.h"
#import "UIColor+BFPaperColors.h"
#import "font-awesome-codes.h"
#import "FontAwesome.h"
#import "SIAlertView.h"
#import "BFKit.h"
#import "LLSimpleCamera.h"
#import "ViewUtils.h"

@interface CameraVC ()

@property LLSimpleCamera* camera;
@property UIButton* switchCameraButton;
@property UIButton* switchFlashButton;
@property UIButton* takePictureButton;
@property UIImageView* imageView;
@property UIButton* usePhotoButton;
@property UIButton* retakePhotoButton;
@property UIButton* backButton;
@property UITapGestureRecognizer* doubleTap;
@property UISwipeGestureRecognizer* swipeDown;

@property UIImage* imageToUse;

@end

BOOL viewingPhoto = NO;

@implementation CameraVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    
    self.camera = [[LLSimpleCamera alloc] initWithQuality:AVCaptureSessionPresetHigh position:LLCameraPositionRear videoEnabled:NO];
    [self.camera attachToViewController:self withFrame:self.view.bounds];
    self.camera.fixOrientationAfterCapture = YES;
    
    __weak typeof(self) weakSelf = self;
    [self.camera setOnDeviceChange:^(LLSimpleCamera *camera, AVCaptureDevice * device) {
        // device changed, check if flash is available
        if([camera isFlashAvailable]) {
            weakSelf.switchFlashButton.hidden = NO;
            
            if(camera.flash == LLCameraFlashOff) {
                weakSelf.switchFlashButton.selected = NO;
            }
            else {
                weakSelf.switchFlashButton.selected = YES;
            }
        }
        else {
            weakSelf.switchFlashButton.hidden = YES;
        }
    }];
    
    self.takePictureButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.takePictureButton.frame = CGRectMake(0, 0, 140, 50);
    self.takePictureButton.clipsToBounds = YES;
    self.takePictureButton.layer.cornerRadius =self.takePictureButton.frame.size.height/ 2.0;
    self.takePictureButton.layer.borderColor = [UIColor whiteColor].CGColor;
    self.takePictureButton.layer.borderWidth = 2.0f;
    self.takePictureButton.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.2];
    self.takePictureButton.layer.rasterizationScale = [UIScreen mainScreen].scale;
    self.takePictureButton.layer.shouldRasterize = YES;
    [self.takePictureButton addTarget:self action:@selector(takePicture:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.takePictureButton];
    
    self.switchFlashButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.switchFlashButton.frame = CGRectMake(0, 0, 40, 40);
    self.switchFlashButton.tintColor = [UIColor whiteColor];
    UIImage* flashImage = [FontAwesome imageWithIcon:fa_bolt iconColor:[UIColor whiteColor] iconSize:30];
    [self.switchFlashButton setImage:flashImage forState:UIControlStateNormal];
    self.switchFlashButton.layer.cornerRadius = 5;
    [self.switchFlashButton addTarget:self action:@selector(changeFlash:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.switchFlashButton];
    
    if([LLSimpleCamera isFrontCameraAvailable] && [LLSimpleCamera isRearCameraAvailable]) {
        // button to toggle camera positions
        self.switchCameraButton = [UIButton buttonWithType:UIButtonTypeSystem];
        self.switchCameraButton.frame = CGRectMake(0, 0, 40, 40);
        self.switchCameraButton.tintColor = [UIColor whiteColor];
        UIImage* cameraSwitchImage = [FontAwesome imageWithIcon:fa_exchange iconColor:[UIColor whiteColor] iconSize:35];
        [self.switchCameraButton setImage:cameraSwitchImage forState:UIControlStateNormal];
        self.switchCameraButton.imageEdgeInsets = UIEdgeInsetsMake(10.0f, 10.0f, 10.0f, 10.0f);
        [self.switchCameraButton addTarget:self action:@selector(switchCamera:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:self.switchCameraButton];
    }
    
    self.backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    self.backButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    self.backButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [self.backButton setTitle:@"X" forState:UIControlStateNormal];
    [self.backButton setTitleColor:[UIColor whiteColor]];
    [self.backButton setFont:[UIFont boldSystemFontOfSize:30]];
    [self.backButton addTarget:self action:@selector(backToMain:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.backButton];
    
    self.imageView = [[UIImageView alloc] initWithFrame:weakSelf.view.bounds];
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    
    self.usePhotoButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 130, 40)];
    [self.usePhotoButton setTitle:@"Use Photo" forState:UIControlStateNormal];
    self.usePhotoButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    [self.usePhotoButton setTitleColor:[UIColor whiteColor]];
    self.usePhotoButton.layer.cornerRadius = 10;
    self.usePhotoButton.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.2];
    [self.usePhotoButton.titleLabel setFont:[UIFont boldSystemFontOfSize:16]];
    [self.usePhotoButton addTarget:self action:@selector(usePhoto:) forControlEvents:UIControlEventTouchUpInside];
    
    self.retakePhotoButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 130, 40)];
    [self.retakePhotoButton setTitle:@"Retake Photo" forState:UIControlStateNormal];
    self.retakePhotoButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    [self.retakePhotoButton setTitleColor:[UIColor whiteColor]];
    self.retakePhotoButton.layer.cornerRadius = 10;
    self.retakePhotoButton.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.2];
    [self.retakePhotoButton.titleLabel setFont:[UIFont boldSystemFontOfSize:16]];
    [self.retakePhotoButton addTarget:self action:@selector(retakePhoto:) forControlEvents:UIControlEventTouchUpInside];
    
    self.doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    self.doubleTap.numberOfTapsRequired = 2;
    [self.view addGestureRecognizer:self.doubleTap];
    
    self.swipeDown = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeDown:)];
    [self.swipeDown setDirection:UISwipeGestureRecognizerDirectionDown];
    [self.view addGestureRecognizer:self.swipeDown];
}

-(void)viewWillAppear:(BOOL)animated{
    self.camera.view.frame = self.view.bounds;
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    
    self.takePictureButton.center = self.view.center;
    self.takePictureButton.bottom = SCREEN_HEIGHT - 25.0f;
    
    self.switchFlashButton.center = self.view.center;
    self.switchFlashButton.top = 10.0f;
    
    self.switchCameraButton.top = 10.0f;
    self.switchCameraButton.right = self.view.width - 5.0f;
    
    self.backButton.center = self.switchCameraButton.center;
    self.backButton.left = 5.0f;
    
    self.usePhotoButton.bottom = SCREEN_HEIGHT - 15.0f;
    self.usePhotoButton.right = SCREEN_WIDTH - 10.0f;
    
    self.retakePhotoButton.bottom = SCREEN_HEIGHT - 15.0f;
    self.retakePhotoButton.left = 10.0f;
    
    __weak typeof(self) weakSelf = self;
    [self.camera setOnError:^(LLSimpleCamera *camera, NSError *error) {
        NSLog(@"Camera error: %@", error);
        
        if([error.domain isEqualToString:LLSimpleCameraErrorDomain]) {
            if(error.code == LLSimpleCameraErrorCodeCameraPermission) {
                SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"Error!" andMessage:@"We need permission for the camera.\nPlease go to your settings and allow camera access."];
                alertView.titleColor = [UIColor paperColorRed500];
                [alertView addButtonWithTitle:@"Ok"
                                         type:SIAlertViewButtonTypeCancel
                                      handler:^(SIAlertView *alert) {
                                          [weakSelf backToMain:error];
                                      }];
                alertView.cornerRadius = 5;
                alertView.transitionStyle = SIAlertViewTransitionStyleBounce;
                [alertView show];
                
            }
        }
    }];

    [self.camera start];
    
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    BOOL hasUsedCamera = [defaults boolForKey:@"hasUsedCamera"];
    if (!hasUsedCamera){
        
        SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"Hidden Features" andMessage:@"Swiping down will cause the camera to exit, and double tapping will switch cameras."];
        [alertView addButtonWithTitle:@"Got it"
                                 type:SIAlertViewButtonTypeDefault
                              handler:^(SIAlertView *alert) {
                                  [defaults setBool:YES forKey:@"hasUsedCamera"];
                                  [defaults synchronize];
                              }];
        alertView.cornerRadius = 5;
        alertView.transitionStyle = SIAlertViewTransitionStyleSlideFromBottom;
        [alertView show];
    }
}

-(void)viewWillDisappear:(BOOL)animated {
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)handleDoubleTap:(UITapGestureRecognizer*)tap{
    if (viewingPhoto){
        [self retakePhoto:tap];
    }
    else{
        [self switchCamera:tap];
    }
}

-(void)handleSwipeDown:(UISwipeGestureRecognizer*)swipe{
    if (!viewingPhoto){
        [self backToMain:swipe];
    }
}

#pragma mark- Button Methods
-(void)switchCamera:(id)sender{
    [self.camera togglePosition];
}

-(void)changeFlash:(id)sender{
    if(self.camera.flash == LLCameraFlashOff) {
        BOOL done = [self.camera updateFlashMode:LLCameraFlashOn];
        if(done) {
            self.switchFlashButton.selected = YES;
            self.switchFlashButton.tintColor = [UIColor yellowColor];
        }
    }
    else {
        BOOL done = [self.camera updateFlashMode:LLCameraFlashOff];
        if(done) {
            self.switchFlashButton.selected = NO;
            self.switchFlashButton.tintColor = [UIColor whiteColor];
        }
    }
}

-(void)takePicture:(id)sender{
    __weak typeof(self) weakSelf = self;
    [self.camera capture:^(LLSimpleCamera *camera, UIImage *image, NSDictionary *metadata, NSError *error) {
        if(!error) {
            viewingPhoto = YES;
            weakSelf.imageView.image = image;
            [weakSelf.view addSubview:weakSelf.imageView];
            [weakSelf.view addSubview:weakSelf.usePhotoButton];
            [weakSelf.view addSubview:weakSelf.retakePhotoButton];
        }
        else {
            NSLog(@"Error taking picture: %@", error);
        }
    } exactSeenImage:YES];
}

#pragma mark- Working With Image
-(void)usePhoto:(id)sender{
    self.imageToUse = self.imageView.image;
    [self dismissViewControllerAnimated:YES completion:nil];
    
    if (self.didDismiss) {
        self.didDismiss(YES, self.imageToUse);
    }
}

-(void)retakePhoto:(id)sender{
    viewingPhoto = NO;
    self.imageToUse = nil;
    [self.imageView removeFromSuperview];
    [self.usePhotoButton removeFromSuperview];
    [self.retakePhotoButton removeFromSuperview];
}

/*
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

}
*/

-(void)backToMain:(id)sender{
    viewingPhoto = NO;
    self.imageToUse = nil;
    [self dismissViewControllerAnimated:YES completion:nil];
    
    if (self.didDismiss) {
        self.didDismiss(NO, nil);
    }
}

@end
