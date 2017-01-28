//
//  ImagePickerPresenter.m
//  CoreSafe
//
//  Created by Main on 1/20/17.
//  Copyright © 2017 Matt Brotman. All rights reserved.
//

#import "ImagePickerPresenter.h"
#import "UIColor+BFPaperColors.h"
#import "ViewUtils.h"

#ifndef SCREEN_WIDTH
#define SCREEN_WIDTH ((([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortrait) || ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortraitUpsideDown)) ? [[UIScreen mainScreen] bounds].size.width : [[UIScreen mainScreen] bounds].size.height)
#endif

#ifndef SCREEN_HEIGHT
#define SCREEN_HEIGHT ((([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortrait) || ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortraitUpsideDown)) ? [[UIScreen mainScreen] bounds].size.height : [[UIScreen mainScreen] bounds].size.width)
#endif

@interface ImagePickerPresenter ()

@property UIView* moveableBar;
@property UILabel* barLabel;
@property UIView* whiteScreen;

@property UIPanGestureRecognizer* pan;
@property CGPoint originalOrigin;

@property UIViewController* presenter;
@property ImagePickerDidShowBlock didShowBlock;

@end

@implementation ImagePickerPresenter
@synthesize isShowing;

+(instancetype)presenterWithViewController:(UIViewController*)vc shouldPresentBlock:(ImagePickerDidShowBlock)block{
    return [[self alloc] initWithViewController:vc shouldPresentBlock:block];
}

-(instancetype)initWithViewController:(UIViewController*)vc shouldPresentBlock:(ImagePickerDidShowBlock)block {
    if (self = [super init]) {
        self.presenter = vc;
        self.didShowBlock = block;
        
        self.moveableBar = [[UIView alloc] init];
        self.barLabel = [[UILabel alloc] init];
        self.whiteScreen = [[UIView alloc] init];
        
        [self setup];
    }
    
    return self;
}

-(void)setup {
    self.frame = CGRectMake(0, SCREEN_HEIGHT-30, SCREEN_WIDTH, SCREEN_HEIGHT*2);
    _originalOrigin = self.origin;
    self.backgroundColor = [UIColor clearColor];
    
    self.moveableBar.frame = CGRectMake(0, 0, SCREEN_WIDTH, 60);
    self.moveableBar.layer.cornerRadius = 25;
    self.moveableBar.backgroundColor = [UIColor darkGrayColor];
    [self.moveableBar addSubview:({
        self.barLabel.frame = CGRectMake(30, 0, SCREEN_WIDTH-60, self.moveableBar.frame.size.height/2);
        self.barLabel.backgroundColor = [UIColor clearColor];
        self.barLabel.textColor = [UIColor lightGrayColor];
        self.barLabel.font = [UIFont fontWithName:@"ArialRoundedMTBold" size:14];
        self.barLabel.textAlignment = NSTextAlignmentCenter;
        self.barLabel.text = @"Swipe here for device photos";
        self.barLabel;
    })];
    self.moveableBar.alpha = 0.75;
    _pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    [_pan setMinimumNumberOfTouches:1];
    [_pan setMaximumNumberOfTouches:1];
    [self.moveableBar addGestureRecognizer:_pan];
    [self addSubview:self.moveableBar];
    
    [self addSubview:({
        self.whiteScreen.frame = CGRectMake(0, 30, SCREEN_WIDTH, SCREEN_HEIGHT*2 - 30);
        self.whiteScreen.backgroundColor = [UIColor paperColorBlueGray500];
        self.whiteScreen;
    })];
}

-(void)pan:(UIPanGestureRecognizer*)gesture {
    if (gesture.state == UIGestureRecognizerStateBegan) {
        
    }
    else if (gesture.state == UIGestureRecognizerStateChanged) {
        CGPoint translate = [gesture translationInView:gesture.view];
        if (self.top <= SCREEN_HEIGHT-30 && self.top >= -30) {
            self.origin = CGPointMake(_originalOrigin.x, _originalOrigin.y + translate.y);
        }
    }
    else if(gesture.state == UIGestureRecognizerStateEnded || gesture.state == UIGestureRecognizerStateCancelled) {
        float distanceMoved = fabs(_originalOrigin.y - self.origin.y);
        if (distanceMoved < 250) {
            [UIView animateWithDuration:0.23
                                  delay:0
                                options:UIViewAnimationOptionCurveEaseOut
                             animations:^{
                                 self.origin = _originalOrigin;
                             } completion:^(BOOL finished) {
                                 nil;
                             }];
        }
        else {
            [UIView animateWithDuration:0.23
                                  delay:0
                                options:UIViewAnimationOptionCurveEaseOut
                             animations:^{
                                 self.top = -30;
                             } completion:^(BOOL finished) {
                                 if (_didShowBlock) {
                                     _didShowBlock();
                                 }
                             }];

        }
    }
}

-(void)show {
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    isShowing = YES;
}

-(void)remove {
    self.origin = _originalOrigin;
    [self removeFromSuperview];
    isShowing = NO;
}

@end
