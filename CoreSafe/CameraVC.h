//
//  CameraVC.h
//  iLock
//
//  Created by Main on 8/13/16.
//  Copyright © 2016 Matt Brotman. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CameraVC : UIViewController

@property (nonatomic, copy) void (^didDismiss)(BOOL usingImage, UIImage* image);

@end
