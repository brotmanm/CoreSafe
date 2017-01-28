//
//  TextInfoEditorVC.h
//  CoreSafe
//
//  Created by Main on 1/10/17.
//  Copyright © 2017 Matt Brotman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SafeNote.h"

@interface TextInfoEditorVC : UIViewController

@property SafeNote* safeNote;
@property BOOL isNewFile;
@property UITextField* titleTextField;
@property UITextView* entryTextView;
@property BOOL didModifyNote;

@end
