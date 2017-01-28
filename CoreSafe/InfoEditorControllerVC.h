//
//  InfoEditorControllerVC.h
//  CoreSafe
//
//  Created by Main on 1/10/17.
//  Copyright © 2017 Matt Brotman. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TextInfoEditorVC.h"
#import "ImageInfoEditorVC.h"
#import "SafeNote.h"
#import "InfoVC.h"

@interface InfoEditorControllerVC : UIViewController

@property TextInfoEditorVC* textInfoEditorVC;
@property ImageInfoEditorVC* imageInfoEditorVC;
@property BOOL isNewFile;
@property SafeNote* safeNote;
@property BOOL didSave;
@property InfoVC* presentingVC;

@end
