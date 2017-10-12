//
//  IntroScreenVC.h
//  CoreSafe
//
//  Created by Main on 12/24/16.
//  Copyright © 2016 Matt Brotman. All rights reserved.
//

#import <UIKit/UIKit.h>
#include "Password.h"

/**
 * This is the setup screen for first time users.
 * Here they will be prompted for two passwords, and will be given the option to enable touchID to unlock the app.
 * Everything should be nice an animated, but some things may still need some tweaking.
 */
@interface IntroScreenVC : UIViewController

@property BOOL touchIDEnabled;

@end
