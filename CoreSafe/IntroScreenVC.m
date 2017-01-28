//
//  IntroScreenVC.m
//  CoreSafe
//
//  Created by Main on 12/24/16.
//  Copyright © 2016 Matt Brotman. All rights reserved.
//

#import "IntroScreenVC.h"
#import "UIColor+BFPaperColors.h"
#import <BFPaperButton/BFPaperButton.h>
#import "font-awesome-codes.h"
#import "FontAwesome.h"
#import "UIView+DYARippleEffect.h"
#import "SIAlertView.h"
#import "ViewUtils.h"
#import "BFKit.h"
#import "BouncyButton.h"

@interface IntroScreenVC () <UITextFieldDelegate>

@property Password* firstPassword;
@property Password* secondPassword;

/***** Views *****/
@property UIView* firstView;
@property UIView* secondView;
@property UIView* thirdView;

/***** First SubViews *****/
@property BFPaperButton* createAccountButton;
@property UIButton* rightButton;

/***** Second SubViews *****/
@property UITextField* passField;
@property BouncyButton* finishFirstPassword;
@property UILabel* createCodeLabel;

/***** Third SubViews*****/
@property UIView* smallBackground;

@end

@implementation IntroScreenVC

NSTimer* rippleTimer;
BOOL didEnterTransition = NO;
BOOL settingUpSecondPassword = NO;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Set up first view
    _firstView = [[UIView alloc] initWithFrame:self.view.frame];
    _firstView.backgroundColor = [UIColor clearColor];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated {
    /***** Background *****/
    UIImageView* backImageView = [[UIImageView alloc] initWithFrame:self.view.frame];
    CIImage* backImg = [CIImage imageWithCGImage: [UIImage imageNamed:@"sunset.jpg"].CGImage];
    CIFilter* darkerFilter = [CIFilter filterWithName:@"CIGammaAdjust"];
    [darkerFilter setDefaults];
    [darkerFilter setValue:backImg forKey:kCIInputImageKey];
    backImageView.image = [UIImage imageWithCIImage:darkerFilter.outputImage];
    [self.view addSubview:backImageView];
    /*
    UIView* colorOverlay = [[UIView alloc] initWithFrame:self.firstView.frame];
    colorOverlay.backgroundColor = [UIColor colorWithColor:[UIColor paperColorIndigo900] alpha:0.6];
    [self.firstView addSubview:colorOverlay]; //add a color to tint the image
    */
    /*
    UIImageView* backLockView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.width)];
    backLockView.center = self.view.center;
    UIImage* backLockImage = [FontAwesome imageWithIcon:fa_lock iconColor:[UIColor colorWithColor:[UIColor paperColorBlueGray50] alpha:.4] iconSize:90];
    backLockView.image = backLockImage;
    [self.view addSubview:backLockView];
    */
    //blur the background
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    blurEffectView.frame = self.view.bounds;
    //blurEffectView.alpha = 1;
    blurEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:blurEffectView];
    
    /***** Button *****/
    [self.view addSubview:_firstView];
    
    _createAccountButton = [[BFPaperButton alloc] initWithFrame:CGRectMake(0, 0, self.firstView.frame.size.width*0.5f, self.firstView.frame.size.width*0.5f) raised:NO];
    _createAccountButton.center = self.firstView.center;
    [_createAccountButton setTitle:fa_user forState:UIControlStateNormal];
    [_createAccountButton setTitleFont:[FontAwesome fontWithSize:67]];
    [_createAccountButton setTitleColor:[UIColor colorWithColor:[UIColor paperColorBlueGray50] alpha:0.8] forState:UIControlStateNormal];
    [_createAccountButton setBackgroundColor: [UIColor colorWithColor:[UIColor paperColorBlueGray100] alpha:0.15]];
    _createAccountButton.layer.borderColor= [UIColor colorWithColor:_createAccountButton.currentTitleColor alpha:0.5].CGColor;
    _createAccountButton.layer.borderWidth=2.0f;
    [_createAccountButton addTarget:self action:@selector(transitionToSecondView:) forControlEvents:UIControlEventTouchUpInside];
    _createAccountButton.cornerRadius = _createAccountButton.frame.size.width / 2;
    [self.firstView addSubview: _createAccountButton];
    
    _rightButton = [[UIButton alloc] initWithFrame:_createAccountButton.frame];
    _rightButton.left = _createAccountButton.right-80;
    [_rightButton setTitle:fa_chevron_right forState:UIControlStateNormal];
    [_rightButton setFont:[FontAwesome fontWithSize:80]];
    [_rightButton setTitleColor:[UIColor colorWithColor:[UIColor paperColorBlueGray100] alpha:0.8] forState:UIControlStateNormal];
    [_rightButton setBackgroundColor: [UIColor clearColor]];
    [_rightButton addTarget:self action:@selector(transitionToSecondView:) forControlEvents:UIControlEventTouchUpInside];
    _rightButton.alpha = 0;
    [self.firstView addSubview:_rightButton];
    
    /***** Bars *****/
    /*
    CALayer* ubarLiner = [CALayer layer];
    ubarLiner.backgroundColor = _createAccountButton.layer.borderColor;
    ubarLiner.frame = CGRectMake(0, _upperBar.frame.size.height-2, self.firstView.frame.size.width, 2);
    [_upperBar.layer addSublayer:ubarLiner];
    */
}

-(void)viewDidAppear:(BOOL)animated {
    /*
    [UIView animateWithDuration:1.5 delay:1 usingSpringWithDamping:0.5 initialSpringVelocity:5 options:UIViewAnimationOptionCurveEaseInOut animations: ^{ _createAccountButton.center = CGPointMake(self.firstView.center.x-60, self.firstView.center.y); } completion:^(BOOL finished) {rippleTimer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(performRipple) userInfo:nil repeats:YES];}];
     */
    /***** Animate First View *****/
    [UIView animateWithDuration:1.5 delay:.1 options:UIViewAnimationOptionCurveEaseInOut animations: ^  {_createAccountButton.center = CGPointMake(self.firstView.center.x-50, self.firstView.center.y);} completion:^(BOOL completed) {[self performSelector:@selector(performRipple) withObject:nil afterDelay:3];}];
    [UIView animateWithDuration:1.5 delay:.1 options:UIViewAnimationOptionCurveEaseInOut animations: ^ {_rightButton.alpha = 1;} completion:nil];
}

/***** Animate a double ripple effect from the first button every few seconds *****/
-(void)performRipple{
    if (didEnterTransition){
        return;
    }
    static int numRipples = 0;
    UIView* ripple = [[UIView alloc] init];
    ripple.frame = _createAccountButton.frame;
    ripple.backgroundColor = [UIColor clearColor];
    ripple.layer.cornerRadius = ripple.frame.size.width/2;
    ripple.rippleColor = [UIColor colorWithCGColor:_createAccountButton.layer.borderColor];
    ripple.rippleTrailColor = [UIColor clearColor];
    [self.firstView insertSubview:ripple belowSubview:_createAccountButton];
    
    [ripple dya_ripple];

    [ripple performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:1.5];
    
    if (numRipples == 1){
        numRipples = 0;
    }
    else{
        [self performSelector:@selector(performRipple) withObject:nil afterDelay:.2];
        numRipples++;
    }
    
    if (![rippleTimer isValid] && numRipples == 1){
        rippleTimer = [NSTimer scheduledTimerWithTimeInterval:4 target:self selector:@selector(performRipple) userInfo:nil repeats:YES];
    }
}

/***** Slide the first view out and second view in, and load everything for the second view *****/
-(void)transitionToSecondView:(id)sender {
    static BOOL shouldTransition = YES;
    didEnterTransition = YES;
    if (shouldTransition){
        shouldTransition = NO;
        [rippleTimer invalidate];
        [self loadSecondView];
        
        [UIView animateWithDuration:2 delay:.001 options:UIViewAnimationOptionCurveEaseInOut animations: ^  {_firstView.right = self.view.left; } completion:^(BOOL completed) { [_firstView removeFromSuperview]; }];
        
        [UIView animateWithDuration:2 delay:.001 options:UIViewAnimationOptionCurveEaseInOut animations: ^  {_secondView.center = self.view.center; } completion:^(BOOL completed) {
            _passField.center = CGPointMake(_secondView.frame.size.width/2, _passField.center.y);
            [UIView animateWithDuration:.5 delay:.01 options:UIViewAnimationOptionCurveEaseInOut animations: ^  {  _passField.height = 70; } completion:^(BOOL completed) {
                [UIView animateWithDuration:.7 delay:.001 options:UIViewAnimationOptionCurveEaseInOut animations: ^  {  _passField.frame = CGRectMake(_secondView.frame.size.width*.05, _passField.frame.origin.y, _secondView.frame.size.width*0.9, _passField.height); } completion:^(BOOL completed) {
                    [_passField becomeFirstResponder];
                }];
            }];
        }];
    }
}

/***** Load all the subviews for the second view *****/
-(void)loadSecondView {
    UIWindow* currWindow = [UIApplication sharedApplication].keyWindow;
    _secondView = [[UIView alloc] initWithFrame:self.view.frame];
    _secondView.left = self.view.right;
    _secondView.backgroundColor = [UIColor clearColor];
    [currWindow addSubview:_secondView];
    
    _createCodeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width*0.9, 70)];
    _createCodeLabel.center = CGPointMake(self.secondView.frame.size.width/2, 120);
    _createCodeLabel.backgroundColor = [UIColor clearColor];
    _createCodeLabel.textColor = [UIColor colorWithColor:[UIColor paperColorBlueGray50] alpha:0.8];
    [_createCodeLabel setFont:[UIFont fontWithName:@"ArialHebrew-Bold" size:20]];
    [_createCodeLabel setTextAlignment:NSTextAlignmentCenter];
    _createCodeLabel.text = @"Create a primary password:";
    [self.secondView addSubview:_createCodeLabel];
    
    _passField = [UITextField initWithFrame:_createCodeLabel.frame
                                placeholder:@"" color:[UIColor whiteColor]
                                       font:FontNameArialHebrew-bold
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
    _passField.top = _createCodeLabel.bottom+15;
    _passField.height = 0;
    _passField.textAlignment = NSTextAlignmentCenter;
    _passField.layer.borderWidth = 4;
    _passField.layer.borderColor = [UIColor colorWithColor:[UIColor paperColorBlueGray50] alpha:0.9].CGColor;
    _passField.backgroundColor = [UIColor colorWithColor:[UIColor paperColorBlueGray100] alpha:0.1];
    _passField.width = _passField.layer.borderWidth*2;
    [self.secondView addSubview:_passField];
    [_passField addTarget:self
                  action:@selector(textFieldDidChange:)
        forControlEvents:UIControlEventEditingChanged];
    
    _finishFirstPassword = [[BouncyButton alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width*0.6, 40) raised:NO];
    _finishFirstPassword.center = CGPointMake(_secondView.width/2, _secondView.height/2);
    _finishFirstPassword.backgroundColor = [UIColor colorWithColor:[UIColor paperColorBlueGray50] alpha:0.5];
    _finishFirstPassword.layer.cornerRadius = _finishFirstPassword.height/2;
    [_finishFirstPassword setTitleColor:[UIColor whiteColor]];
    [_finishFirstPassword setTitle:@"Continue" forState:UIControlStateNormal];
    [_finishFirstPassword setTitleFont:FontNameArialHebrew-bold size:18];
    _finishFirstPassword.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    _finishFirstPassword.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _finishFirstPassword.hidden = YES;
    [_secondView addSubview:_finishFirstPassword];
    [_finishFirstPassword addTarget:self action:@selector(enteredFirstPrimary:) forControlEvents:UIControlEventTouchUpInside];
}

-(void)enteredFirstPrimary:(id)sender {
    [_passField resignFirstResponder];
    if (settingUpSecondPassword) {
        _secondPassword = [[Password alloc] initWithString:_passField.text];
    }
    else {
        _firstPassword = [[Password alloc] initWithString:_passField.text];
    }
    
    SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"Password Strength" andMessage:[NSString stringWithFormat:@"This password is %@.", _firstPassword.strength]];
    [alertView addButtonWithTitle:@"Edit"
                             type:SIAlertViewButtonTypeCancel
                          handler:^(SIAlertView *alert) {
                              [_passField becomeFirstResponder];
                          }];
    [alertView addButtonWithTitle:@"Continue"
                             type:SIAlertViewButtonTypeDefault
                          handler:^(SIAlertView *alert) {
                              SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"Confirm Password" andMessage:@"Please enter your password again to confirm it."];
                              [alertView setTitleColor: [UIColor paperColorBlueGray500]];
                              UITextField* textField = [UITextField initWithFrame:CGRectZero
                                                                      placeholder:@"Re-Enter Password"
                                                                            color:[UIColor blackColor]
                                                                             font:FontNameArialHebrew
                                                                             size:15
                                                                       returnType:UIReturnKeyNext
                                                                     keyboardType:UIKeyboardTypeDefault
                                                                           secure:YES
                                                                      borderStyle:UITextBorderStyleNone
                                                               autoCapitalization:UITextAutocapitalizationTypeNone
                                                               keyboardAppearance:UIKeyboardAppearanceDark
                                                    enablesReturnKeyAutomatically:YES
                                                                  clearButtonMode:UITextFieldViewModeNever
                                                               autoCorrectionType:UITextAutocorrectionTypeNo
                                                                         delegate:nil];
                              textField.textAlignment = NSTextAlignmentCenter;
                              if (settingUpSecondPassword) {
                                  [alertView addTextFieldWithPlaceHolder:@"Re-Enter Secondary Password" andText:@"" andTextField:textField];
                              }
                              else {
                                  [alertView addTextFieldWithPlaceHolder:@"Re-Enter Primary Password" andText:@"" andTextField:textField];
                              }
                              [alertView addButtonWithTitle:@"Edit"
                                                       type:SIAlertViewButtonTypeCancel
                                                    handler:^(SIAlertView *alert) {
                                                        [_passField becomeFirstResponder];
                                                    }];
                              [alertView addButtonWithTitle:@"Continue"
                                                       type:SIAlertViewButtonTypeDefault
                                                    handler:^(SIAlertView *alert) {
                                                        if (settingUpSecondPassword) {
                                                            if ([[alertView.textFields[0] text] isEqualToString:_secondPassword.stringRepresentation]){
                                                                [_secondPassword saveWithKey:@"secondPassword"];
                                                                [self moveToThirdView];
                                                            }
                                                            else{
                                                                [self confirmPasswordFailed];
                                                            }
                                                        }
                                                        else {
                                                            if ([[alertView.textFields[0] text] isEqualToString:_firstPassword.stringRepresentation]){
                                                                [_firstPassword saveWithKey:@"firstPassword"];
                                                                [self setupSecondaryPassword];
                                                            }
                                                            else{
                                                                [self confirmPasswordFailed];
                                                            }
                                                        }
                                                    }];
                              alertView.cornerRadius = 3;
                              alertView.transitionStyle = SIAlertViewTransitionStyleDropDown;
                              [alertView show];
                          }];
    alertView.cornerRadius = 3;
    alertView.transitionStyle = SIAlertViewTransitionStyleBounce;
    [alertView show];
}

-(void)confirmPasswordFailed {
    [BFSystemSound playSystemSoundVibrate];
    SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"Mismatching Passwords" andMessage:@"These passwords do not match, please enter your primary password again to confirm it."];
    [alertView setTitleColor: [UIColor paperColorRed500]];
    UITextField* textField = [UITextField initWithFrame:CGRectZero
                                            placeholder:@"Re-Enter Primary Password"
                                                  color:[UIColor blackColor]
                                                   font:FontNameArialHebrew
                                                   size:15
                                             returnType:UIReturnKeyNext
                                           keyboardType:UIKeyboardTypeDefault
                                                 secure:YES
                                            borderStyle:UITextBorderStyleNone
                                     autoCapitalization:UITextAutocapitalizationTypeNone
                                     keyboardAppearance:UIKeyboardAppearanceDark
                          enablesReturnKeyAutomatically:YES
                                        clearButtonMode:UITextFieldViewModeNever
                                     autoCorrectionType:UITextAutocorrectionTypeNo
                                               delegate:nil];
    textField.textAlignment = NSTextAlignmentCenter;
    if (settingUpSecondPassword) {
        [alertView addTextFieldWithPlaceHolder:@"Re-Enter Secondary Password" andText:@"" andTextField:textField];
    }
    else {
        [alertView addTextFieldWithPlaceHolder:@"Re-Enter Primary Password" andText:@"" andTextField:textField];
    }
    [alertView addButtonWithTitle:@"Edit"
                             type:SIAlertViewButtonTypeDestructive
                          handler:^(SIAlertView *alert) {
                              [_passField becomeFirstResponder];
                          }];
    [alertView addButtonWithTitle:@"Continue"
                             type:SIAlertViewButtonTypeDefault
                          handler:^(SIAlertView *alert) {
                              if (settingUpSecondPassword) {
                                  if ([[alertView.textFields[0] text] isEqualToString:_secondPassword.stringRepresentation]){
                                      [_secondPassword saveWithKey:@"secondPassword"];
                                      [self moveToThirdView];
                                  }
                                  else{
                                      [self confirmPasswordFailed];
                                  }
                              }
                              else {
                                  if ([[alertView.textFields[0] text] isEqualToString:_firstPassword.stringRepresentation]){
                                      [_firstPassword saveWithKey:@"secondPassword"];
                                      [self setupSecondaryPassword];
                                  }
                                  else{
                                      [self confirmPasswordFailed];
                                  }
                              }
                          }];
    alertView.cornerRadius = 3;
    alertView.transitionStyle = SIAlertViewTransitionStyleDropDown;
    [alertView show];
}

-(void)setupSecondaryPassword {
    _finishFirstPassword.hidden = YES;
    _passField.text = @"";
    [UIView animateWithDuration:.7 delay:.01 options:UIViewAnimationOptionCurveEaseInOut animations: ^  { _passField.frame = CGRectMake(_passField.center.x-_passField.layer.borderWidth, _passField.frame.origin.y, _passField.layer.borderWidth*2, _passField.height); } completion:^(BOOL completed) {
        settingUpSecondPassword = YES;
        
        [UIView transitionWithView:_createCodeLabel duration:0.5 options:UIViewAnimationOptionTransitionCrossDissolve animations:^ { _createCodeLabel.text = @"Create a secondary password:"; } completion:^(BOOL finished) {
            [UIView animateWithDuration:.7 delay:.001 options:UIViewAnimationOptionCurveEaseInOut animations: ^  {  _passField.frame = CGRectMake(_secondView.frame.size.width*.05, _passField.frame.origin.y, _secondView.frame.size.width*0.9, _passField.height); } completion:^(BOOL completed) {
                [_passField becomeFirstResponder];
            }];
        }];
    }];
    
}

-(void)moveToThirdView {
    _finishFirstPassword.enabled = NO;
    _passField.text = @"";
    [self loadThirdView];
    [UIView animateWithDuration:.7 delay:.01 options:UIViewAnimationOptionCurveEaseInOut animations: ^  { _passField.frame = CGRectMake(_passField.center.x-_passField.layer.borderWidth, _passField.frame.origin.y, _passField.layer.borderWidth*2, _passField.height); }completion:^(BOOL finished) {
        [UIView animateWithDuration:.5 delay:0 options:UIViewAnimationOptionCurveEaseIn animations: ^  { _passField.frame = CGRectMake(_passField.center.x-_passField.layer.borderWidth, _passField.frame.origin.y, _passField.layer.borderWidth*2, 0); } completion:^(BOOL finished) {
            [UIView animateWithDuration:.7 delay:0 usingSpringWithDamping:0.9 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseInOut animations: ^{ _finishFirstPassword.transform = CGAffineTransformMakeScale(.001, .001); } completion:^(BOOL finished) {
                _finishFirstPassword.hidden = YES;
                [UIView animateWithDuration:2 delay:.0 options:UIViewAnimationOptionCurveEaseInOut animations:^ { _secondView.right = self.view.left; } completion:^(BOOL finished) {
                    [_secondView removeFromSuperview];
                }];
                [UIView animateWithDuration:2 delay:.0 options:UIViewAnimationOptionCurveEaseInOut animations:^ { _thirdView.center = self.view.center; } completion:^(BOOL finished) {
                    
                }];
            }];
        }];
    }];
}

-(void)loadThirdView {
    _thirdView = [[UIView alloc] initWithFrame:self.view.frame];
    _thirdView.backgroundColor = [UIColor clearColor];
    _thirdView.left = _secondView.right;
    [self.view addSubview:_thirdView];
    
    _smallBackground = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _thirdView.width*0.85, _thirdView.width*0.85)];
    _smallBackground.center = CGPointMake(_thirdView.width/2, _thirdView.height/2);
    _smallBackground.backgroundColor = [UIColor colorWithColor:[UIColor paperColorBlueGray50] alpha:0.3];
    _smallBackground.layer.cornerRadius = 10;
    [_thirdView addSubview:_smallBackground];
    
    UILabel* enableTouchLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, _smallBackground.width*0.9, 50)];
    enableTouchLabel.center = CGPointMake(_thirdView.width/2, _thirdView.height/2);
    enableTouchLabel.backgroundColor = [UIColor clearColor];
    enableTouchLabel.textColor = [UIColor colorWithColor:[UIColor whiteColor] alpha:1];
    [enableTouchLabel setFont:[UIFont fontWithName:@"ArialHebrew-Bold" size:24]];
    [enableTouchLabel setTextAlignment:NSTextAlignmentCenter];
    enableTouchLabel.text = @"Enable touchID?";
    [self.thirdView addSubview:enableTouchLabel];
    
    UIImageView* touchImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, _smallBackground.width*0.5, _smallBackground.width*0.45)];
    touchImageView.image = [UIImage imageNamed:@"touchID.png"];
    touchImageView.center = CGPointMake(_thirdView.width/2, _smallBackground.top + _smallBackground.height*0.25);
    [_thirdView addSubview:touchImageView];
    
    BouncyButton* noButton = [[BouncyButton alloc] initWithFrame:CGRectMake(0, 0, _smallBackground.width*.4, 40) raised:NO];
    noButton.left = _smallBackground.left + _smallBackground.width*0.05;
    noButton.bottom = _smallBackground.bottom - 30;
    noButton.backgroundColor = [UIColor colorWithColor:[UIColor paperColorBlueGray700] alpha:0.9];
    noButton.layer.cornerRadius = noButton.height/2;
    [noButton setTitleColor:[UIColor whiteColor]];
    [noButton setTitle:@"No" forState:UIControlStateNormal];
    [noButton setTitleFont:FontNameArialHebrew-bold  size:18];
    noButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    noButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [_thirdView addSubview:noButton];
    [noButton addTarget:self action:@selector(continueToMain:) forControlEvents:UIControlEventTouchUpInside];
    
    BouncyButton* yesButton = [[BouncyButton alloc] initWithFrame:CGRectMake(0, 0, _smallBackground.width*.4, 40) raised:NO];
    yesButton.right = _smallBackground.right - _smallBackground.width*0.05;
    yesButton.bottom = _smallBackground.bottom - 30;
    yesButton.backgroundColor = [UIColor colorWithColor:[UIColor paperColorBlueGray700] alpha:0.75];
    yesButton.layer.cornerRadius = yesButton.height/2;
    [yesButton setTitleColor:[UIColor whiteColor]];
    [yesButton setTitle:@"Yes" forState:UIControlStateNormal];
    [yesButton setTitleFont:FontNameArialHebrew-bold size:18];
    yesButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    yesButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [_thirdView addSubview:yesButton];
    [yesButton addTarget:self action:@selector(enableTouchID:) forControlEvents:UIControlEventTouchUpInside];
    if (!SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
        yesButton.enabled = NO;
    }
}

-(void)enableTouchID:(id)sender {
    [BFTouchID showTouchIDAuthenticationWithReason:BFLocalizedString(@"Authentication", @"") fallbackTitle:@""  completion:^(TouchIDResult result) { //ask for the user's touchID
        switch (result) {
            case TouchIDResultSuccess: { //if the touchID was a success, alert the user of a success and disable the button
                runOnMainThread(^{
                    SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"TouchID Authentication Successful" andMessage:@"You will now be able to use your touchID as well as your passwords."];
                    [alertView setTitleColor: [UIColor paperColorBlueGray500]];
                    [alertView addButtonWithTitle:@"Continue"
                                             type:SIAlertViewButtonTypeDefault
                                          handler:^(SIAlertView *alert) {
                                              _touchIDEnabled = YES;
                                              [self continueToMain:sender];
                                          }];
                    alertView.cornerRadius = 2;
                    alertView.transitionStyle = SIAlertViewTransitionStyleBounce;
                    [alertView show];
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
                    SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"Unable to Enable TouchID" andMessage:@"Make sure you have enabled touchID in your phone's settings."];
                    [alertView setTitleColor: [UIColor paperColorRed500]];
                    [alertView addButtonWithTitle:@"Cancel"
                                             type:SIAlertViewButtonTypeCancel
                                          handler:^(SIAlertView *alert) {
                                              
                                          }];
                    [alertView addButtonWithTitle:@"Try Again"
                                             type:SIAlertViewButtonTypeDefault
                                          handler:^(SIAlertView *alert) {
                                              _touchIDEnabled = NO;
                                              [self enableTouchID:sender];
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


-(void)continueToMain:(id)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults setBool:_touchIDEnabled forKey:@"touchIDEnabled"];
    
    BOOL setupComplete = [defaults boolForKey:@"setupComplete"];
    if (setupComplete != true) {
        [defaults setBool:YES forKey:@"setupComplete"];
    }
    
    [defaults synchronize];
    [self performSegueWithIdentifier:@"ToMain" sender:sender];
}

#pragma mark - UITextFieldDelegate
-(void)textFieldDidChange:(UITextField*)textField {
    if (textField == _passField){
        if (textField.text.length > 2){
            _finishFirstPassword.hidden = NO;
        }
        else{
            _finishFirstPassword.hidden = YES;
        }
    }
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    BOOL shouldReturn = NO;
    if (textField == _passField){
        if (textField.text.length > 2){
            shouldReturn = YES;
            [self enteredFirstPrimary:textField];
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
