//
//  InfoVC.h
//  CoreSafe
//
//  Created by Main on 12/30/16.
//  Copyright © 2016 Matt Brotman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SafeNote.h"

@interface InfoVC : UIViewController

-(void)fillInfoArray;

-(void)toggleEditingMode;
-(void)saveAndReloadTableView;
-(void)addNote:(SafeNote*)note;
-(void)deleteNoteAtIndex:(NSUInteger)index;

@property NSUInteger currentlySelectedNoteIndex;

@end
