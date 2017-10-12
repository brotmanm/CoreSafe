//
//  LockScreenVC.m
//  CoreSafe
//
//  Created by Main on 12/27/16.
//  Copyright © 2016 Matt Brotman. All rights reserved.
//

#import "LockScreenVC.h"
#import "BouncyButton.h"
#import "BFKit.h"
#import "UIColor+BFPaperColors.h"
#import "FontAwesome.h"
#import "UITextField+ABTextFieldAnimations.h"
#import "BFRadialWaveView.h"
#import "ViewUtils.h"
#import "SIAlertView.h"


@interface LockScreenVC () <UITextFieldDelegate>

@property UIView* turnView;
@property BFRadialWaveView* waveView;
@property UIView* darkView;
@property UITextField* passField;

@property NSString* firstPassword;
@property NSString* secondPassword;

@end

@implementation LockScreenVC

BOOL unlocked = NO;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    /***** Background *****/
    
    UIImageView* backImageView = [[UIImageView alloc] initWithFrame:self.view.frame];
    backImageView.image = [UIImage imageNamed:@"stars.jpg"];
    backImageView.alpha = 0.8;
    [self.view addSubview:backImageView];
    
    self.view.backgroundColor = [UIColor blackColor];
    
    //blur the background
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    blurEffectView.frame = self.view.bounds;
    blurEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:blurEffectView];
    
    [self addClouds];
    
    _turnView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width + self.view.height, 8)];
    _turnView.backgroundColor = [UIColor colorWithColor:[UIColor paperColorBlue100] alpha:0.8];
    _turnView.center = self.view.center;
    [self.view addSubview:_turnView];
    
    self.waveView = [[BFRadialWaveView alloc] initWithView:self.view circles:20 color:[UIColor colorWithColor:[UIColor paperColorBlue100] alpha:0.8] mode:BFRadialWaveViewMode_North strokeWidth:4 withGradient:NO];
    
    /***** Button *****/
    BouncyButton* unlockButton = [[BouncyButton alloc] initWithFrame:CGRectMake(0, 0, self.view.width*.5, self.view.width*.5) raised:NO];
    unlockButton.center = self.view.center;
    [unlockButton setTitle:fa_lock forState:UIControlStateNormal];
    [unlockButton setFont:[FontAwesome fontWithSize:85]];
    [unlockButton setTitleColor:[UIColor colorWithColor:[UIColor paperColorBlue100] alpha:0.8] forState:UIControlStateNormal];
    [unlockButton setBackgroundColor: [UIColor paperColorBlueGray900]];
    unlockButton.layer.borderColor= [UIColor colorWithColor:[UIColor paperColorBlue100] alpha:0.8].CGColor;
    unlockButton.layer.borderWidth=4.0f;
    [unlockButton addTarget:self action:@selector(showPasswordScreen:) forControlEvents:UIControlEventTouchUpInside];
    unlockButton.cornerRadius = unlockButton.frame.size.width / 2;
    [self.view addSubview: unlockButton];
    
    //Check if they have touchID enabled, and enable the touchID button if necessary
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    BOOL touchIDEnabled = [defaults boolForKey:@"touchIDEnabled"];
    if (touchIDEnabled){
        BouncyButton* touchIDButton = [[BouncyButton alloc] initWithFrame:CGRectMake(0, 0, self.view.width*0.2, self.view.width*0.2) raised:NO];
        touchIDButton.x = self.view.width/2;
        touchIDButton.y = unlockButton.bottom + (self.view.height - unlockButton.bottom)/2;
        [touchIDButton setImage:[UIImage imageNamed:@"touchID.png"] forState:UIControlStateNormal];
        touchIDButton.imageView.layer.cornerRadius = touchIDButton.layer.cornerRadius;
        touchIDButton.backgroundColor = [UIColor paperColorBlueGray900];
        touchIDButton.layer.cornerRadius = touchIDButton.width/2;
        touchIDButton.layer.borderWidth = 2;
        touchIDButton.layer.borderColor = [UIColor paperColorBlue100].CGColor;
        [touchIDButton addTarget:self action:@selector(enterTouchID:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:touchIDButton];
    }
    
    NSData* encryptedFirstPasswordData = [defaults objectForKey:@"firstPassword"];
    NSData* decryptedFirstPasswordData = [BFCryptor AES128DecryptData:encryptedFirstPasswordData withKey:@"c2WQM88"];
    _firstPassword = [decryptedFirstPasswordData convertToUTF8String];
    
    NSData* encryptedSecondPasswordData = [defaults objectForKey:@"secondPassword"];
    NSData* decryptedSecondPasswordData = [BFCryptor AES128DecryptData:encryptedSecondPasswordData withKey:@"c2WQM88"];
    _secondPassword = [decryptedSecondPasswordData convertToUTF8String];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    unlocked = NO;
    [_waveView show];
}

//Add little blue lines in background
-(void)addClouds {
    UIColor* cloudColor = [UIColor colorWithColor:[UIColor paperColorBlue100] alpha:0.15];
    int numCLouds = 30;
    CGFloat cloudHeight = 2.0f;
    CGFloat widthMultiplier = 0.45f;
    CGFloat spaceBetween = (self.view.height - cloudHeight*numCLouds)/(numCLouds+1);
    CGFloat yPos = 1;
    
    for (int i = 0; i < numCLouds; i++){
        yPos += spaceBetween;
        
        UIView* leftCloud = [[UIView alloc] initWithFrame:CGRectMake(0, yPos, self.view.width*widthMultiplier, cloudHeight)];
        leftCloud.backgroundColor = cloudColor;
        leftCloud.tag = 2;
        
        UIView* rightCloud = [[UIView alloc] initWithFrame:CGRectMake(self.view.width * (1-widthMultiplier), yPos, self.view.width*widthMultiplier, cloudHeight)];
        rightCloud.backgroundColor = cloudColor;
        rightCloud.tag = 3;
        
        [self.view addSubview:leftCloud];
        [self.view addSubview:rightCloud];
        yPos += cloudHeight;
    }
}

//When the user hits the unlock button, show them a screen where they can enter a password
-(void)showPasswordScreen:(id)sender {
    if (unlocked) {
        return;
    }
    _darkView = [[UIView alloc] initWithFrame:self.view.frame];
    _darkView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_darkView];
    
    UILabel* enterLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width*0.9, 70)];
    enterLabel.center = CGPointMake(_darkView.width/2, _darkView.height*0.25);
    enterLabel.backgroundColor = [UIColor clearColor];
    enterLabel.textColor = [UIColor colorWithColor:[UIColor paperColorBlueGray50] alpha:0.8];
    [enterLabel setFont:[UIFont fontWithName:@"ArialRoundedMTBold" size:20]];
    [enterLabel setTextAlignment:NSTextAlignmentCenter];
    enterLabel.text = @"Enter Password:";
    [self.darkView addSubview:enterLabel];
    
    _passField = [UITextField initWithFrame:enterLabel.frame
                                placeholder:@""
                                      color:[UIColor whiteColor]
                                       font:FontNameArialRoundedMTBold
                                       size:30
                                 returnType:UIReturnKeyDone
                               keyboardType:UIKeyboardTypeDefault
                                     secure:YES
                                borderStyle:UITextBorderStyleNone
                         autoCapitalization:UITextAutocapitalizationTypeNone
                         keyboardAppearance:UIKeyboardAppearanceDark
              enablesReturnKeyAutomatically:YES
                            clearButtonMode:UITextFieldViewModeNever
                         autoCorrectionType:UITextAutocorrectionTypeNo
                                   delegate:self];
    _passField.height = 0;
    _passField.textAlignment = NSTextAlignmentCenter;
    _passField.layer.borderWidth = 4;
    _passField.layer.borderColor = [UIColor colorWithColor:[UIColor paperColorBlueGray50] alpha:0.9].CGColor;
    _passField.backgroundColor = [UIColor colorWithColor:[UIColor paperColorBlueGray100] alpha:0.1];
    _passField.width = _passField.layer.borderWidth*2;
    _passField.origin = CGPointMake(_darkView.width/2 - _passField.layer.borderWidth, _darkView.origin.y);
    _passField.top = enterLabel.bottom+15;
    [_darkView addSubview:_passField];
    [_passField addTarget:self
                   action:@selector(textFieldDidChange:)
         forControlEvents:UIControlEventEditingChanged];
    
    BouncyButton* cancelButton = [[BouncyButton alloc] initWithFrame:CGRectMake(20, 30, 50, 50) raised:NO];
    cancelButton.backgroundColor = [UIColor clearColor];
    [cancelButton setFont:[FontAwesome fontWithSize:40]];
    [cancelButton setTitleColor:[UIColor paperColorBlueGray50]];
    [cancelButton setTitle:fa_times forState:UIControlStateNormal];
    cancelButton.layer.cornerRadius = cancelButton.width/2;
    [cancelButton addTarget:self action:@selector(cancelUnlock:) forControlEvents:UIControlEventTouchUpInside];
    cancelButton.alpha = 0.8;
    [_darkView addSubview:cancelButton];
    
    //Animate in the password textfield
    [UIView animateWithDuration:.4 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations: ^  { _darkView.backgroundColor = [UIColor colorWithColor:[UIColor blackColor] alpha:0.9]; } completion:^(BOOL completed) { }];
    
    [UIView animateWithDuration:.4 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations: ^  {  _passField.height = 70; } completion:^(BOOL completed) {
        
        [UIView animateWithDuration:.7 delay:.001 options:UIViewAnimationOptionCurveEaseInOut animations: ^  {  _passField.frame = CGRectMake(_darkView.frame.size.width*.05, _passField.frame.origin.y, _darkView.frame.size.width*0.9, _passField.height); } completion:^(BOOL completed) {
            [_passField becomeFirstResponder];
        }];
    }];
}

//If the user exits the unlock screen
-(void)cancelUnlock:(id)sender {
    [_passField resignFirstResponder];
    
    //Animate out everything
    [UIView animateWithDuration:.5 delay:0 usingSpringWithDamping:0.9 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseInOut animations: ^{ _darkView.transform = CGAffineTransformMakeScale(.001, .001); _darkView.origin = CGPointMake(0, 0);} completion:^(BOOL finished) {
        [_darkView removeFromSuperview];
     }];
}

//Have the user enter their touchID
-(void)enterTouchID:(id)sender {
    if (unlocked) {
        return;
    }
    
    //TouchID authentication
    [BFTouchID showTouchIDAuthenticationWithReason:BFLocalizedString(@"Authentication", @"")
                                     fallbackTitle:@""
                                        completion:^(TouchIDResult result) { //ask for the user's touchID
        switch (result) {
            case TouchIDResultSuccess: { //if the touchID was a success
                runOnMainThread(^{
                    unlocked = YES;
                    [self performUnlock:sender];
                });
                break;
            }
            case TouchIDResultAuthenticationFailed: { //if the touchID was a failure
                runOnMainThread(^{
                    [BFSystemSound playSystemSoundVibrate];
                });
                break;
            }
            case TouchIDResultUserCancel: { //if the touchID was a failure
                runOnMainThread(^{
                    
                });
                break;
            }
            default: {
                runOnMainThread(^{ //for every other reason (i.e touchID not enabled,) alert the user touchID could not be enabled
                    [BFSystemSound playSystemSoundVibrate];
                    SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"Unable to Access TouchID" andMessage:@"Make sure you have enabled touchID in your phone's settings."];
                    [alertView setTitleColor: [UIColor paperColorRed500]];
                    [alertView addButtonWithTitle:@"Cancel"
                                             type:SIAlertViewButtonTypeCancel
                                          handler:^(SIAlertView *alert) {
                                              
                                          }];
                    [alertView addButtonWithTitle:@"Try Again"
                                             type:SIAlertViewButtonTypeDefault
                                          handler:^(SIAlertView *alert) {
                                              [self enterTouchID:sender];
                                          }];
                    alertView.cornerRadius = 2;
                    alertView.transitionStyle = SIAlertViewTransitionStyleBounce;
                    [alertView show];
                    
                });
                break;
            }
        }
    }];
}

//If the user enters a successful password
-(void)unloadDarkView:(BOOL)animated {
    [_passField resignFirstResponder];
    _passField.text = @"";
    
    if (animated) {
        //Animate out the password Screen
        [UIView animateWithDuration:.5 delay:.1 options:UIViewAnimationOptionCurveEaseInOut animations: ^  {  _passField.width = _passField.layer.borderWidth*2; _passField.origin = CGPointMake(_darkView.width/2-_passField.layer.borderWidth, _passField.origin.y); } completion:^(BOOL completed) {
            
            [UIView animateWithDuration:.5 delay:0 usingSpringWithDamping:0.9 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseInOut animations: ^{ _darkView.transform = CGAffineTransformMakeScale(.001, 1);} completion:^(BOOL finished) {
                [_darkView removeFromSuperview];
                [self performUnlock:_passField];
            }];
        }];
    }
}

//Perform unlock animations
-(void)performUnlock:(id)sender {
    [UIView animateWithDuration:0.7 delay:.01 options:UIViewAnimationOptionCurveEaseInOut animations:^ {
        _waveView.alpha = 0;
        _turnView.layer.transform = CATransform3DMakeRotation(-(M_PI_2), 0, 0, 1);
    } completion:^ (BOOL finished) {
        [self performSegueWithIdentifier:@"LockToHome" sender:sender];
    }];
}

#pragma mark - UITextFieldDelegate

//When editing the password, if the password is a match, automatically unlock
-(void)textFieldDidChange:(UITextField*)textField {
    if (textField == _passField) {
         if ([textField.text isEqualToString: _firstPassword] || [textField.text isEqualToString: _secondPassword]) {
            textField.layer.borderColor = [UIColor colorWithColor:[UIColor paperColorBlue200] alpha:0.9].CGColor;
            unlocked = YES;
            [self unloadDarkView:YES];
        }
        else {
            textField.layer.borderColor = [UIColor colorWithColor:[UIColor paperColorBlueGray50] alpha:0.9].CGColor;
        }
    }
}

//Allow the user to manually hit the done button
-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    BOOL shouldReturn = NO;
    if (textField == _passField){
        if ([textField.text isEqualToString: _firstPassword] || [textField.text isEqualToString: _secondPassword]) {
            unlocked = YES;
            [self unloadDarkView:YES];
        }
        else { //If the password is not correct
            textField.layer.borderColor = [UIColor colorWithColor:[UIColor paperColorRed200] alpha:0.9].CGColor;
            [textField shake];
            [BFSystemSound playSystemSoundVibrate];
        }
    }
    
    return shouldReturn;
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
