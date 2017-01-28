//
//  ImageViewer.m
//  CoreSafe
//
//  Created by Main on 1/15/17.
//  Copyright © 2017 Matt Brotman. All rights reserved.
//

#import "ImageViewer.h"
#import "ViewUtils.h"
#import "BFKit.h"
#import "SRActionSheet.h"
#import "SIAlertView.h"
#import "BFRadialWaveView.h"
#import "ZoomableImage.h"

@interface ImageViewer () <UIScrollViewDelegate, UIGestureRecognizerDelegate>

@property NSInteger currentIndex;
@property CGRect originalRect;

@property UIScrollView* imageScroller;
@property UIVisualEffectView* blurView;
@property UIImageView* phonyImageView;
@property SRActionSheet* actionSheet;

@property UITapGestureRecognizer* tap;
@property UIPanGestureRecognizer* pan;

@property NSMutableArray* loadedIndeces;

@end

@implementation ImageViewer
@synthesize delegate;
@synthesize destinationRect;
@synthesize imageArray;
@synthesize originalIndex;

+(instancetype)imageViewerWithImages:(NSArray*)images currentIndex:(NSInteger)index originFrame:(CGRect)position {
    return [[self alloc] initWithImages:images currentIndex:index originFrame:position];
}

-(instancetype)initWithImages:(NSArray*)images currentIndex:(NSInteger)index originFrame:(CGRect)position {
    if (self = [super initWithFrame:[UIScreen mainScreen].bounds]) {
        self.backgroundColor = [UIColor clearColor];
        imageArray = images;
        self.currentIndex = index;
        originalIndex = index;
        self.originalRect = position;
        self.destinationRect = position;
        _loadedIndeces = [[NSMutableArray alloc] init];
        
        [self setup];
    }
    
    return self;
}

-(void)setup {
    [self addSubview:({
        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        _blurView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        _blurView.frame = self.frame;
        _blurView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _blurView.alpha = 0;
        _blurView;
    })];
    
    [self addSubview:({
        _imageScroller = [UIScrollView initWithFrame:self.frame
                                         contentSize:CGSizeMake(self.width * imageArray.count, self.height)
                                       clipsToBounds:YES
                                       pagingEnabled:YES
                                showScrollIndicators:NO
                                            delegate:self];
        _imageScroller.backgroundColor = [UIColor clearColor];
        _imageScroller.hidden = YES;
        _imageScroller;
    })];
    [_imageScroller setContentOffset:CGPointMake(self.width * self.currentIndex, 0)];
    [self loadObjectsAroundIndex:_currentIndex];
    
    [self addPhonyImage];
    
    _actionSheet = [SRActionSheet sr_actionSheetViewWithTitle:nil
                                                  cancelTitle:@"Cancel"
                                             destructiveTitle:nil
                                                  otherTitles:@[@"Save",@"Delete"]
                                                  otherImages:nil
                                             selectSheetBlock:^(SRActionSheet *actionSheet, NSInteger index) {
                                                 if (index == 0) {
                                                     [self performSaveActions];
                                                 }
                                                 else if (index == 1) {
                                                     [self performDeleteActions];
                                                 }
                                             }];
    
    _tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [self addGestureRecognizer:_tap];
    _pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    [_pan setMinimumNumberOfTouches:1];
    [_pan setMaximumNumberOfTouches:1];
    [self addGestureRecognizer:_pan];
}

- (UIImage*)imageFromObj:(id)obj {
    UIImage* img;
    if ([obj isKindOfClass:[UIImage class]]) {
        img = (UIImage*)obj;
    }
    else if ([obj isKindOfClass:[NSData class]]) {
        NSData* data = (NSData*)obj;
        img = [UIImage imageWithData:data];
    }
    else {
        NSLog(@"Invalid images");
        img = [UIImage imageWithColor:[UIColor blackColor]];
    }
    
    return img;
}

-(void)loadObjectsAroundIndex:(NSInteger)index {
    if (index == 0) {
        if (imageArray.count == 1) {
            [self loadObjectsFromIndex:0 throughIndex:0];
        }
        else {
            [self loadObjectsFromIndex:0 throughIndex:1];
        }
    }
    else if (index == imageArray.count - 1) {
        [self loadObjectsFromIndex:index-1 throughIndex:index];
    }
    else {
        [self loadObjectsFromIndex:index-1 throughIndex:index+1];
    }
}

-(void)loadObjectsFromIndex:(NSInteger)firstInteger throughIndex:(NSInteger)secondInteger {
    for (NSInteger i = secondInteger; i >= firstInteger; i--) {
        if (![_loadedIndeces containsObject:[NSNumber numberWithInteger:i]]) {
            [_loadedIndeces addObject:[NSNumber numberWithInteger:i]];
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(void) {
                
                id obj = imageArray[i];
                UIImage* img = [self imageFromObj:obj];
                NSInteger imgIndex = i;
                ZoomableImage* zoomImage = [ZoomableImage zoomableImageWithFrame:self.frame image:img];
                zoomImage.origin = CGPointMake(self.width * imgIndex, 0);
                zoomImage.tag = imgIndex;

                dispatch_sync(dispatch_get_main_queue(), ^(void) {
                    
                    [self.imageScroller addSubview:zoomImage];
                    
                });
            });
        }
    }
}

-(void)addPhonyImage {
    [self addSubview:({
        _phonyImageView = [[UIImageView alloc] initWithFrame:_originalRect];
        _phonyImageView.backgroundColor = [UIColor clearColor];
        _phonyImageView.clipsToBounds = YES;
        _phonyImageView.userInteractionEnabled = YES;
        _phonyImageView.contentMode = UIViewContentModeScaleAspectFill;
        _phonyImageView.image = [self imageFromObj:imageArray[_currentIndex]];
        _phonyImageView;
    })];
}

-(CGSize)scaleImageView:(UIImageView*)imageView {
    CGSize imageSize = CGSizeMake(imageView.image.size.width / imageView.image.scale, imageView.image.size.height / imageView.image.scale);
    CGFloat widthRatio = imageSize.width / self.bounds.size.width;
    CGFloat heightRatio = imageSize.height / self.bounds.size.height;
    if (widthRatio > heightRatio) {
        imageSize = CGSizeMake(imageSize.width / widthRatio, imageSize.height / widthRatio);
    }
    else {
        imageSize = CGSizeMake(imageSize.width / heightRatio, imageSize.height / heightRatio);
    }
    if (imageSize.width > SCREEN_WIDTH) {
        imageSize.width = SCREEN_WIDTH;
    }
    if (imageSize.height > SCREEN_HEIGHT) {
        imageSize.height = SCREEN_HEIGHT;
    }

    return imageSize;
}

-(void)show:(BOOL)animated {
    if ([delegate respondsToSelector:@selector(imageViewer:willShowWithIndex:)]) {
        [delegate imageViewer:self willShowWithIndex:_currentIndex];
    }
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    if (animated) {
        CGSize imageSize = [self scaleImageView:_phonyImageView];
        
        [UIView animateWithDuration:0.5
                              delay:0
             usingSpringWithDamping:0.7
              initialSpringVelocity:0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^ {
                             _phonyImageView.height = imageSize.height;
                             _phonyImageView.width = imageSize.width;
                             _phonyImageView.center = CGPointMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2);
                             _blurView.alpha = 1;
                         }completion:^(BOOL finished) {
                             _imageScroller.hidden = NO;
                             [_phonyImageView removeFromSuperview];
                             if ([delegate respondsToSelector:@selector(imageViewer:didShowWithIndex:)]) {
                                 [delegate imageViewer:self didShowWithIndex:_currentIndex];
                             }
                         }];
    }
    else {
        [_phonyImageView setFrame:self.frame];
        [_phonyImageView removeFromSuperview];
        _blurView.alpha = 1;
        _imageScroller.hidden = NO;
        if ([delegate respondsToSelector:@selector(imageViewer:didShowWithIndex:)]) {
            [delegate imageViewer:self didShowWithIndex:_currentIndex];
        }
    }
}

-(void)dismiss:(BOOL)animated {
    if (animated) {
        [UIView animateWithDuration:0.5
                              delay:0
             usingSpringWithDamping:0.8
              initialSpringVelocity:0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^ {
                             _phonyImageView.frame = self.destinationRect;
                             _blurView.alpha = 0;
                         }completion:^(BOOL finished) {
                             if ([delegate respondsToSelector:@selector(imageViewer:didDismissFromIndex:animated:)]){
                                 [delegate imageViewer:self didDismissFromIndex:_currentIndex animated:animated];
                             }
                             [self removeFromSuperview];
                             _actionSheet.isShowing = NO;
                         }];

    }
    else {
        [UIView animateWithDuration:0.2
                         animations:^ {
                             self.alpha = 0;
                         }completion:^(BOOL finished) {
                             if ([delegate respondsToSelector:@selector(imageViewer:didDismissFromIndex:animated:)]){
                                 [delegate imageViewer:self didDismissFromIndex:_currentIndex animated:animated];
                             }
                             [self removeFromSuperview];
                             _actionSheet.isShowing = NO;
                         }];
    }
}

-(void)pan:(UIPanGestureRecognizer*)gesture {
    if (gesture.state == UIGestureRecognizerStateBegan) {
        if ([delegate respondsToSelector:@selector(imageViewer:dismissAnimationsBeganAtIndex:)]){
            [delegate imageViewer:self dismissAnimationsBeganAtIndex:_currentIndex];
        }
        
        _phonyImageView.image = [self imageFromObj:imageArray[_currentIndex]];;
        [self addSubview:_phonyImageView];
        _imageScroller.hidden = YES;
    }
    else if (gesture.state == UIGestureRecognizerStateChanged) {
        CGPoint translate = [gesture translationInView:gesture.view];
        _phonyImageView.center = CGPointMake(self.center.x + translate.x, self.center.y + translate.y);
    }
    else if(gesture.state == UIGestureRecognizerStateEnded || gesture.state == UIGestureRecognizerStateCancelled) {
        float distanceMoved = fabs(self.center.y - self.phonyImageView.center.y);
        //CGPoint finalVelocity = [gesture velocityInView:gesture.view];
        static const float distanceToDismiss = 70.0;
        //static const float velocityToDismiss = 70.0;
        
        if (distanceMoved > distanceToDismiss) {
            [self dismiss:YES];
        }
        else {
            if ([delegate respondsToSelector:@selector(imageViewer:dismissAnimationsCancelledAtIndex:)]){
                [delegate imageViewer:self dismissAnimationsCancelledAtIndex:_currentIndex];
            }
            
            CGSize imageSize = [self scaleImageView:_phonyImageView];
            [UIView animateWithDuration:0.5
                                  delay:0
                 usingSpringWithDamping:0.8
                  initialSpringVelocity:0
                                options:UIViewAnimationOptionCurveEaseInOut
                             animations:^ {
                                 _phonyImageView.height = imageSize.height;
                                 _phonyImageView.width = imageSize.width;
                                 _phonyImageView.center = CGPointMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2);
                                 _blurView.alpha = 1;
                             }completion:^(BOOL finished) {
                                 _imageScroller.hidden = NO;
                                 [_phonyImageView removeFromSuperview];
                             }];
        }

    }
}

-(void)handleTap:(UIGestureRecognizer*)gesture {
    if (!_actionSheet.isShowing) {
        [_actionSheet show];
    }
}

-(void)performSaveActions {
    if ([delegate respondsToSelector:@selector(imageViewer:didSaveImageAtIndex:)]){
        [delegate imageViewer:self didSaveImageAtIndex:_currentIndex];
    }
}
-(void)performDeleteActions {
    if ([delegate respondsToSelector:@selector(imageViewer:didDeleteImageAtIndex:)]){
        [delegate imageViewer:self didDeleteImageAtIndex:_currentIndex];
    }
}

#pragma mark - UIGesterRecognizerDelegate
-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

#pragma mark - UIScrollViewDelegate
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (scrollView == self.imageScroller){
    }
}

-(void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    _tap.enabled = YES;
    _pan.enabled = YES;
    NSLog(@"ended animation");
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGPoint scrollOffset= self.imageScroller.contentOffset;
    _currentIndex=(int)scrollOffset.x/self.frame.size.width;
    [self loadObjectsAroundIndex:_currentIndex];
}

@end
