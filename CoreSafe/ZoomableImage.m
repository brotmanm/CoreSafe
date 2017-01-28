//
//  ZoomableImage.m
//  CoreSafe
//
//  Created by Main on 1/15/17.
//  Copyright © 2017 Matt Brotman. All rights reserved.
//

#import "ZoomableImage.h"
#import "ViewUtils.h"
#import "BFKit.h"

@interface ZoomableImage () <UIScrollViewDelegate>

@property UIScrollView* scrollerView;
@property UIImageView* imageView;

@end

@implementation ZoomableImage
@synthesize image;
@synthesize isZoomed;

+(instancetype)zoomableImageWithFrame:(CGRect)frame image:(UIImage*)myImage {
    return [[self alloc] initWithFrame:frame image:myImage];
}

-(instancetype)initWithFrame:(CGRect)frame image:(UIImage*)myImage {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
    }
    
    [self setupWithImage:myImage];
    return self;
}

-(void)setupWithImage:(UIImage*)myImage {
    _scrollerView = [UIScrollView initWithFrame:self.frame
                                    contentSize:self.frame.size
                                  clipsToBounds:YES
                                  pagingEnabled:NO
                           showScrollIndicators:NO
                                       delegate:self];
    _scrollerView.minimumZoomScale = 1.0;
    _scrollerView.maximumZoomScale = 5.0;
    [self addSubview:_scrollerView];
    
    _imageView=[[UIImageView alloc]initWithFrame:self.frame];
    _imageView.backgroundColor = [UIColor clearColor];
    _imageView.contentMode = UIViewContentModeScaleAspectFit;
    _imageView.clipsToBounds = YES;
    _imageView.layer.shouldRasterize = YES;
    _imageView.layer.rasterizationScale = [UIScreen mainScreen].scale;
    [_imageView setImage:myImage];
    _imageView.userInteractionEnabled = YES;
    [_scrollerView addSubview:_imageView];
}

#pragma mark - UIScrollViewDelegate

-(UIView*)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

-(void)scrollViewDidZoom:(UIScrollView *)scrollView {
    if (scrollView.zoomScale <= 1.0) {
        isZoomed = NO;
    }
    else {
        isZoomed = YES;
    }
}

@end
