//
//  StairSegue.m
//  CoreSafe
//
//  Created by Main on 1/18/17.
//  Copyright © 2017 Matt Brotman. All rights reserved.
//

#import "StairSegue.h"
#import "ViewUtils.h"
#import "MainControllerVC.h"

@interface StairSegue ()

@property NSInteger tileNumber;
@property float tileMovementDuration;
@property float tileMovementDelay;
@property UIViewAnimationOptions options;

@end

@implementation StairSegue

- (instancetype)initWithIdentifier:(NSString *)identifier source:(UIViewController *)source destination:(UIViewController *)destination {

    if (self = [super initWithIdentifier:identifier source:source destination:destination]) {
        _tileNumber = 18;
        _tileMovementDuration = 0.5;
        _tileMovementDelay = 0.05;
        _options = UIViewAnimationOptionCurveEaseInOut;
    }
    
    return self;
}

- (UIImageView*)destinationViewSnapshot {
    UIViewController *destinationViewController = self.destinationViewController;
    UIGraphicsBeginImageContextWithOptions(destinationViewController.view.bounds.size, NO, 0);
    [destinationViewController.view drawViewHierarchyInRect:destinationViewController.view.bounds
                                         afterScreenUpdates:YES];
    UIImage *destinationViewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return [[UIImageView alloc] initWithImage:destinationViewImage];
}

- (UIImage*)sourceViewSnapshotImage {
    UIViewController *sourceViewController = self.sourceViewController;
    UIGraphicsBeginImageContextWithOptions(sourceViewController.view.bounds.size, NO, 0);
    [sourceViewController.view drawViewHierarchyInRect:sourceViewController.view.bounds
                                         afterScreenUpdates:NO];
    UIImage *sourceViewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return sourceViewImage;
}

- (UIImage *)cropImage:(UIImage*)image toRect:(CGRect)rect {
    CGFloat (^rad)(CGFloat) = ^CGFloat(CGFloat deg) {
        return deg / 180.0f * (CGFloat) M_PI;
    };
    
    // determine the orientation of the image and apply a transformation to the crop rectangle to shift it to the correct position
    CGAffineTransform rectTransform;
    switch (image.imageOrientation) {
        case UIImageOrientationLeft:
            rectTransform = CGAffineTransformTranslate(CGAffineTransformMakeRotation(rad(90)), 0, -image.size.height);
            break;
        case UIImageOrientationRight:
            rectTransform = CGAffineTransformTranslate(CGAffineTransformMakeRotation(rad(-90)), -image.size.width, 0);
            break;
        case UIImageOrientationDown:
            rectTransform = CGAffineTransformTranslate(CGAffineTransformMakeRotation(rad(-180)), -image.size.width, -image.size.height);
            break;
        default:
            rectTransform = CGAffineTransformIdentity;
    };
    
    // adjust the transformation scale based on the image scale
    rectTransform = CGAffineTransformScale(rectTransform, image.scale, image.scale);
    
    // apply the transformation to the rect to create a new, shifted rect
    CGRect transformedCropSquare = CGRectApplyAffineTransform(rect, rectTransform);
    // use the rect to crop the image
    CGImageRef imageRef = CGImageCreateWithImageInRect(image.CGImage, transformedCropSquare);
    // create a new UIImage and set the scale and orientation appropriately
    UIImage *result = [UIImage imageWithCGImage:imageRef scale:image.scale orientation:image.imageOrientation];
    // memory cleanup
    CGImageRelease(imageRef);
    
    return result;
}

- (NSMutableArray*)tilesWithImage:(UIImage*)image{
    NSMutableArray* imageViewArray = [[NSMutableArray alloc] initWithCapacity:_tileNumber];
    float yOrigin = 0;
    float tileHeight = self.sourceViewController.view.height / _tileNumber;
    for (int i = 0; i < _tileNumber; ++i) {
        CGRect imageFrame = CGRectMake(0, yOrigin,  self.sourceViewController.view.width, tileHeight);
        UIImage* tiledImage = [self cropImage:image toRect:imageFrame];
        
        UIImageView* imageView = [[UIImageView alloc] initWithFrame:imageFrame];
        imageView.image = tiledImage;
        imageView.top = yOrigin;
        
        [imageViewArray addObject:imageView];
        yOrigin += tileHeight;
    }
    
    return imageViewArray;
}

- (void)perform
{
    UIViewController *sourceViewController = self.sourceViewController;
    
    UIImage *sourceViewImage = [self sourceViewSnapshotImage];
    NSMutableArray* sourceViews = [self tilesWithImage:sourceViewImage];
    UIImageView *destinationViewSnapshot = self.destinationViewSnapshot;
    
    [sourceViewController.view addSubview:destinationViewSnapshot];
    for (UIImageView* imageView in sourceViews) {
        [sourceViewController.view addSubview:imageView];
    }
    
    float delay = 0;
    for (int i = 0; i < _tileNumber; i++) {
        UIImageView* imageView = sourceViews[i];
        __block BOOL lastAnimation = (i == _tileNumber-1);
        [UIView animateWithDuration:_tileMovementDuration
                              delay:delay
                            options:self.options
                         animations:^{
                             imageView.right = sourceViewController.view.left;
                         }
                         completion:^(BOOL finished) {
                             if (lastAnimation) {
                                 [self showDestinationViewController:^{
                                     [destinationViewSnapshot removeFromSuperview];
                                     [sourceViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
                                 }];
                             }
                         }
         ];
        delay += _tileMovementDelay;
    }
    
}

- (void)showDestinationViewController:(void (^)())completion
{
    [self.sourceViewController presentViewController:self.destinationViewController
                                            animated:NO
                                          completion:completion];
}

@end
