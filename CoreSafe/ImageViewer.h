//
//  ImageViewer.h
//  CoreSafe
//
//  Created by Main on 1/15/17.
//  Copyright © 2017 Matt Brotman. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ImageViewer;

@protocol ImageViewerDelegate <NSObject>

@optional

- (void)imageViewer:(ImageViewer*)viewer willShowWithIndex:(NSInteger)index;
- (void)imageViewer:(ImageViewer*)viewer didShowWithIndex:(NSInteger)index;
- (void)imageViewer:(ImageViewer*)viewer didDeleteImageAtIndex:(NSInteger)index;
- (void)imageViewer:(ImageViewer*)viewer didSaveImageAtIndex:(NSInteger)index;
- (void)imageViewer:(ImageViewer*)viewer dismissAnimationsBeganAtIndex:(NSInteger)index;
- (void)imageViewer:(ImageViewer*)viewer dismissAnimationsCancelledAtIndex:(NSInteger)index;
- (void)imageViewer:(ImageViewer*)viewer didDismissFromIndex:(NSInteger)index animated:(BOOL)animated;

@end

@interface ImageViewer : UIView

+(instancetype)imageViewerWithImages:(NSArray*)images currentIndex:(NSInteger)index originFrame:(CGRect)position;

@property (nonatomic, weak) id <ImageViewerDelegate> delegate;

@property (nonatomic) CGRect destinationRect;
@property (nonatomic, readonly) NSArray* imageArray;
@property (nonatomic, readonly) NSInteger originalIndex;

-(void)show:(BOOL)animated;
-(void)dismiss:(BOOL)animated;

@end
