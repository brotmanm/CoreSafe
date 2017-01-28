//
//  InfoEditorControllerVC.m
//  CoreSafe
//
//  Created by Main on 1/10/17.
//  Copyright © 2017 Matt Brotman. All rights reserved.
//

#import "InfoEditorControllerVC.h"
#import "CarbonKit.h"
#import "UIColor+BFPaperColors.h"
#import "font-awesome-codes.h"
#import "FontAwesome.h"
#import "UINavigationBar+Awesome.h"
#import "BFKit.h"
#import "MainControllerVC.h"
#import "SIAlertView.h"
#import "ViewUtils.h"

@interface InfoEditorControllerVC () <CarbonTabSwipeNavigationDelegate>

@property NSArray* swipeItems;
@property CarbonTabSwipeNavigation* swipeNav;
@property int currentIndex;
@property NSString* originalTitle;

@end

@implementation InfoEditorControllerVC
@synthesize isNewFile;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if (isNewFile) {
        UIBarButtonItem* leftbutton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)];
        self.navigationItem.leftBarButtonItem = leftbutton;
        UIBarButtonItem* rightButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(save:)];
        self.navigationItem.rightBarButtonItem = rightButton;
        
        [self.navigationController.navigationBar lt_setBackgroundColor:[UIColor paperColorBlueGray700]];
        [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor paperColorBlue50],
                                                                          
                                                                          NSFontAttributeName: [UIFont fontWithName:@"ArialHebrew-Bold" size:20]}];
        [self.navigationController.navigationBar setTintColor:[UIColor paperColorBlue100]];
        self.navigationController.navigationBar.translucent = YES;
        
        self.safeNote = [[SafeNote alloc] init];
    }
    else {
        UIBarButtonItem* rightButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(trash:)];
        self.navigationItem.rightBarButtonItem = rightButton;
        
        self.originalTitle = self.safeNote.title;
        
        //MainControllerVC* main = self.navigationController.viewControllers[0];
        //main.title = @"Files";
    }
    
    self.textInfoEditorVC = [self.storyboard instantiateViewControllerWithIdentifier:@"TextInfoEditorVC"];
    self.textInfoEditorVC.safeNote = self.safeNote;
    self.textInfoEditorVC.isNewFile = self.isNewFile;
    
    self.imageInfoEditorVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ImageInfoEditorVC"];
    self.imageInfoEditorVC.safeNote = self.safeNote;
    self.imageInfoEditorVC.isNewFile = self.isNewFile;
    
    _swipeItems = @[fa_pencil_square_o, fa_picture_o];
    self.swipeNav = [[CarbonTabSwipeNavigation alloc] initWithItems:_swipeItems delegate:self];
    [self.swipeNav insertIntoRootViewController:self];
    
    _swipeNav.toolbar.translucent = NO;
    _swipeNav.toolbar.barTintColor = [UIColor paperColorBlueGray800];
    [_swipeNav setIndicatorColor:[UIColor colorWithColor:[UIColor paperColorBlue100] alpha:1]];
    [_swipeNav setTabExtraWidth:0];
    [_swipeNav.carbonSegmentedControl setWidth:self.view.width/2 forSegmentAtIndex:0];
    [_swipeNav.carbonSegmentedControl setWidth:self.view.width/2 forSegmentAtIndex:1];
    
    [_swipeNav setNormalColor:[UIColor colorWithColor:[UIColor paperColorBlue100] alpha:0.6]
                         font:[FontAwesome fontWithSize:22]];
    [_swipeNav setSelectedColor:[UIColor colorWithColor:[UIColor paperColorBlue100] alpha:1] font:[FontAwesome fontWithSize:26]];
    
    [self.view setBackgroundColor:[UIColor paperColorBlueGray900]];
    
    if (!isNewFile && ([_safeNote hasFirstImage] || [_safeNote hasSecondImage]) && _safeNote.imageSelected){
        [_swipeNav setCurrentTabIndex:1 withAnimation:NO];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillDisappear:(BOOL)animated {
    if (self.textInfoEditorVC.didModifyNote || self.imageInfoEditorVC.didModifyNote) {
        if (self.safeNote.title.length == 0) {
            self.safeNote.title = self.originalTitle;
        }
        self.textInfoEditorVC.didModifyNote = NO;
        self.imageInfoEditorVC.didModifyNote = NO;
        [self.presentingVC saveAndReloadTableView];
    }
}

-(void)trash:(id)sender {
    SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"Delete File" andMessage:@"Are you sure you want to delete this file?"];
    //[alertView setTitleColor: [UIColor paperColorRed500]];
    [alertView addButtonWithTitle:@"Cancel"
                             type:SIAlertViewButtonTypeCancel
                          handler:^(SIAlertView *alert) {
                              
                          }];
    [alertView addButtonWithTitle:@"Delete"
                             type:SIAlertViewButtonTypeDestructive
                          handler:^(SIAlertView *alert) {
                              [self.presentingVC deleteNoteAtIndex:self.presentingVC.currentlySelectedNoteIndex];
                              [self performSegueWithIdentifier:@"UnwindToInfoVC" sender:sender];
                            }];
    alertView.cornerRadius = 5;
    alertView.transitionStyle = SIAlertViewTransitionStyleSlideFromBottom;
    [alertView show];

}

-(void)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)save:(id)sender {
    if (self.safeNote.title.length == 0) {
        [BFSystemSound playSystemSoundVibrate];
        SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"Missing Name" andMessage:@"Please provide a name for this file before saving."];
        [alertView setTitleColor: [UIColor paperColorRed500]];
        [alertView addButtonWithTitle:@"OK"
                                 type:SIAlertViewButtonTypeCancel
                              handler:^(SIAlertView *alert) {
                                  if (_currentIndex == 1) {
                                      [_swipeNav setCurrentTabIndex:0 withAnimation:YES];
                                  }
                              }];
        alertView.cornerRadius = 3;
        alertView.transitionStyle = SIAlertViewTransitionStyleBounce;
        [alertView show];

    }
    else {
        if (self.presentingVC) {
            [self.presentingVC addNote:self.safeNote];
        }
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - CarbonTabSwipeNavigation Delegate
- (nonnull UIViewController *)carbonTabSwipeNavigation: (nonnull CarbonTabSwipeNavigation *)carbontTabSwipeNavigation
                                 viewControllerAtIndex:(NSUInteger)index {
    switch (index) {
        case 0:
            return self.textInfoEditorVC;
        case 1:
            return self.imageInfoEditorVC;
    }
    return self.textInfoEditorVC;
}

- (void)carbonTabSwipeNavigation:(nonnull CarbonTabSwipeNavigation *)carbonTabSwipeNavigation
                 willMoveAtIndex:(NSUInteger)index {
    switch (index) {
        case 0:
            [self.textInfoEditorVC.titleTextField resignFirstResponder];
            [self.textInfoEditorVC.entryTextView resignFirstResponder];
            break;
        case 1:
            break;
    }
}

- (void)carbonTabSwipeNavigation:(nonnull CarbonTabSwipeNavigation *)carbonTabSwipeNavigation
                  didMoveAtIndex:(NSUInteger)index {
    _currentIndex = (int)index;
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
