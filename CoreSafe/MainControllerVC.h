//
//  MainControllerVC.h
//  CoreSafe
//
//  Created by Main on 12/30/16.
//  Copyright © 2016 Matt Brotman. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "HomeVC.h"
#import "InfoVC.h"
#import "KeyVC.h"
#import "ImagesVC.h"
#import "SettingsVC.h"

@interface MainControllerVC : UIViewController

@property HomeVC* homeVC;
@property InfoVC* infoVC;
@property KeyVC* keyVC;
@property ImagesVC* imagesVC;
@property SettingsVC* settingsVC;

@end
