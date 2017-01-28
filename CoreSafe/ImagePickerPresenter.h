//
//  ImagePickerPresenter.h
//  CoreSafe
//
//  Created by Main on 1/20/17.
//  Copyright © 2017 Matt Brotman. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^ImagePickerDidShowBlock)(void);

@interface ImagePickerPresenter : UIView

+(instancetype)presenterWithViewController:(UIViewController*)vc shouldPresentBlock:(ImagePickerDidShowBlock)block;

-(void)show;
-(void)remove;

@property (nonatomic, readonly) BOOL isShowing;

@end
