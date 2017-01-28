//
//  ZoomableImage.h
//  CoreSafe
//
//  Created by Main on 1/15/17.
//  Copyright © 2017 Matt Brotman. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZoomableImage : UIView

@property (nonatomic, weak) UIImage* image;
@property (nonatomic, readonly) BOOL isZoomed;

+(instancetype)zoomableImageWithFrame:(CGRect)frame image:(UIImage*)myImage;

@end
