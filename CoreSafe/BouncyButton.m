//
//  BouncyButton.m
//  CoreSafe
//
//  Created by Main on 12/25/16.
//  Copyright © 2016 Matt Brotman. All rights reserved.
//

#import "BouncyButton.h"

@interface BouncyButton ()

//@property CGRect originalFrame;

@end

@implementation BouncyButton

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setupRaised:YES];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupRaised:YES];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)decoder
{
    self = [super initWithCoder:decoder];
    if (self) {
        [self setupRaised:YES];
    }
    return self;
}

#pragma mark - Custom Initializers
- (instancetype)initWithRaised:(BOOL)raised
{
    self = [super init];
    if (self) {
        [self setupRaised:raised];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame raised:(BOOL)raised
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupRaised:raised];
    }
    return self;
}

- (void)setRaised:(BOOL)raised {
    [self createRectShadowWithOffset:CGSizeMake(3, 4) opacity:0.4 radius:4];
}

-(void)setupRaised:(BOOL)shouldBeRaised {
    if (shouldBeRaised){
        [self createRectShadowWithOffset:CGSizeMake(3, 4) opacity:0.4 radius:4];
    }
    //self.originalFrame = self.frame;
    
    [self addTarget:self action:@selector(bouncyTouchDown:) forControlEvents:UIControlEventTouchDown];
    [self addTarget:self action:@selector(bouncyTouchUp:) forControlEvents:UIControlEventTouchUpInside];
    [self addTarget:self action:@selector(bouncyTouchUp:) forControlEvents:UIControlEventTouchUpOutside];
    [self addTarget:self action:@selector(bouncyTouchUp:) forControlEvents:UIControlEventTouchCancel];
}

-(void)bouncyTouchDown:(id)sender {
    /*
    float scaleFactor = 0.75;
    CGFloat newWidth =  self.frame.size.width * scaleFactor;
    CGFloat newHeight = self.frame.size.height * scaleFactor;
    CGFloat newXPos = self.frame.origin.x + (self.frame.size.width - newWidth)/2;
    CGFloat newYPos = self.frame.origin.y + (self.frame.size.height - newHeight)/2;
     */
    [UIView animateWithDuration:.3 delay:0 usingSpringWithDamping:0.4 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseInOut animations: ^{
        self.transform = CGAffineTransformMakeScale( 0.75, 0.75);
        //self.frame = CGRectMake(newXPos, newYPos, newWidth, newHeight);
    } completion:^(BOOL finished) {  }];
}

-(void)bouncyTouchUp:(id)sender {
    [UIView animateWithDuration:.3 delay:0 usingSpringWithDamping:0.2 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseInOut animations: ^{
        self.transform = CGAffineTransformMakeScale( 1, 1);
        //self.frame = self.originalFrame;
    } completion:^(BOOL finished) {  }];
}

@end
