//
//  ImageInfoEditorVC.h
//  CoreSafe
//
//  Created by Main on 1/10/17.
//  Copyright © 2017 Matt Brotman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SafeNote.h"

@interface ImageInfoEditorVC : UIViewController

@property SafeNote* safeNote;
@property BOOL isNewFile;
@property BOOL didModifyNote;

@end
