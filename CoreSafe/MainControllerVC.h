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

/**
 * This is a wrapper controller for the 5 different view controllers.
 * What this does is simply contain the 5 different sections of the app, in a horizontal scrollable view.
 * The bar that appears when scrolling through the 5 controllers is part of this main controller.
 */
 
@interface MainControllerVC : UIViewController

//Our 5 controllers below
@property HomeVC* homeVC;
@property InfoVC* infoVC;
@property KeyVC* keyVC;
@property ImagesVC* imagesVC;
@property SettingsVC* settingsVC;

@end
