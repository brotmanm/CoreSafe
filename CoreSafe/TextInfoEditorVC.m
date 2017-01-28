//
//  TextInfoEditorVC.m
//  CoreSafe
//
//  Created by Main on 1/10/17.
//  Copyright © 2017 Matt Brotman. All rights reserved.
//

#import "TextInfoEditorVC.h"
#import "UIColor+BFPaperColors.h"
#import "font-awesome-codes.h"
#import "FontAwesome.h"
#import "BFKit.h"
#import "ViewUtils.h"
#import "BouncyButton.h"
#import "SIAlertView.h"

@interface TextInfoEditorVC () <UITextFieldDelegate, UITextViewDelegate, UIScrollViewDelegate>

@property UIView* divider;
@property UIScrollView* scroller;

@end

@implementation TextInfoEditorVC

NSString* titleTextFieldPlaceHolder;
NSString* entryTextViewPlaceholder;
CGFloat startingPoint;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    startingPoint = self.navigationController.navigationBar.height+[UIApplication sharedApplication].statusBarFrame.size.height;
    
    titleTextFieldPlaceHolder = @"File name";
    entryTextViewPlaceholder = @"File contents";
    
    [self.view setBackgroundColor:[UIColor paperColorBlueGray900]];
    
    self.scroller = [UIScrollView initWithFrame:self.view.frame contentSize:CGSizeMake(self.view.width, self.view.height) clipsToBounds:YES pagingEnabled:NO showScrollIndicators:NO delegate:self];
    self.scroller.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_scroller];
    
    self.titleTextField = [[UITextField alloc] initWithFrame:CGRectMake(14, 15, self.view.width-20, 35)];
    self.titleTextField.borderStyle = UITextBorderStyleNone;
    self.titleTextField.font = [UIFont fontWithName:@"ArialRoundedMTBold" size:21];
    self.titleTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.titleTextField.autocapitalizationType = UITextAutocapitalizationTypeWords;
    self.titleTextField.keyboardAppearance = UIKeyboardAppearanceDark;
    self.titleTextField.returnKeyType = UIReturnKeyDone;
    self.titleTextField.clearButtonMode = UITextFieldViewModeNever;
    self.titleTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentBottom;
    self.titleTextField.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    self.titleTextField.textColor = [UIColor colorWithColor:[UIColor whiteColor] alpha:0.15];
    [self.titleTextField addTarget:self
                   action:@selector(textFieldDidChange:)
         forControlEvents:UIControlEventEditingChanged];
    self.titleTextField.delegate = self;
    
    self.entryTextView = [[UITextView alloc] initWithFrame:CGRectMake(10, 0, self.view.width-20, SCREEN_HEIGHT-_titleTextField.bottom-227)];
    self.entryTextView.top = self.titleTextField.bottom + 11;
    self.entryTextView.delegate = self;
    self.entryTextView.font = [UIFont fontWithName:@"ArialRoundedMTBold" size:18];
    self.entryTextView.textColor = [UIColor colorWithColor:[UIColor whiteColor] alpha:0.15];
    self.entryTextView.backgroundColor = [UIColor clearColor];
    self.entryTextView.autocorrectionType = UITextAutocorrectionTypeDefault;
    self.entryTextView.keyboardType = UIKeyboardTypeDefault;
    self.entryTextView.keyboardAppearance = UIKeyboardAppearanceDark;
    self.entryTextView.returnKeyType = UIReturnKeyDefault;
    
    if (self.isNewFile) {
        _divider = [[UIView alloc] initWithFrame:CGRectMake(0, startingPoint, 3, self.view.height-startingPoint)];
        _divider.backgroundColor = [UIColor colorWithColor:[UIColor paperColorBlue100] alpha:0.5];
        _divider.center = CGPointMake(self.view.width/2, _divider.center.y);
        [self.scroller addSubview:_divider];
        
        self.titleTextField.alpha = 0;
        self.entryTextView.alpha = 0;
        [UIView animateWithDuration:0.6 delay:0.15 options:UIViewAnimationOptionCurveEaseInOut animations:^ {
            _divider.frame = CGRectMake(0, self.titleTextField.bottom + 6, 20, 3);
        } completion:^ (BOOL finished) {
            [self.scroller addSubview:self.titleTextField];
            [self.scroller addSubview:self.entryTextView];
            self.titleTextField.text = titleTextFieldPlaceHolder;
            self.entryTextView.text = entryTextViewPlaceholder;
            [UIView animateWithDuration:0.4 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^ {
                _divider.width = self.view.width;
                self.titleTextField.alpha = 1;
                self.entryTextView.alpha = 1;
            } completion:^ (BOOL finished) {
                
            }];
        }];
    }
    else {
        _divider = [[UIView alloc] initWithFrame:CGRectMake(0, self.titleTextField.bottom + 6, 0, 3)];
        _divider.backgroundColor = [UIColor colorWithColor:[UIColor paperColorBlue100] alpha:0.5];
        [self.scroller addSubview:_divider];
        
        self.titleTextField.alpha = 0;
        self.entryTextView.alpha = 0;
        [self.scroller addSubview:self.titleTextField];
        [self.scroller addSubview:self.entryTextView];
        if (_safeNote.title.length != 0 && ![_safeNote.title isEqualToString:titleTextFieldPlaceHolder]) {
            self.titleTextField.text = _safeNote.title;
            self.titleTextField.textColor = [UIColor paperColorBlue50];
        }
        else {
            self.titleTextField.text = titleTextFieldPlaceHolder;
        }
        if ([_safeNote getContent].length != 0 && ![[_safeNote getContent] isEqualToString:entryTextViewPlaceholder]) {
            self.entryTextView.text = [_safeNote getContent];
            self.entryTextView.textColor = [UIColor paperColorBlue50];
        }
        else {
            self.entryTextView.text = entryTextViewPlaceholder;
        }
        
        [UIView animateWithDuration:0.4 delay:0.1 options:UIViewAnimationOptionCurveEaseInOut animations:^ {
            _divider.width = self.view.width;
            self.titleTextField.alpha = 1;
            self.entryTextView.alpha = 1;
        } completion:^ (BOOL finished) {
            
        }];
    }
    
}

-(void)viewWillDisappear:(BOOL)animated {
    [_titleTextField resignFirstResponder];
    [_entryTextView resignFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [_titleTextField resignFirstResponder];
    [_entryTextView resignFirstResponder];
}

-(void)didChange:(id)sender {
    self.didModifyNote = YES;
}

#pragma mark -UITextField Delegate
-(void)textFieldDidBeginEditing:(UITextField *)textField {
    if ([textField.text isEqualToString:titleTextFieldPlaceHolder]) {
        textField.text = @"";
        textField.textColor = [UIColor paperColorBlue50];
    }
}

-(void)textFieldDidEndEditing:(UITextField *)textField {
    if ([textField.text isEqualToString:@""]) {
        textField.text = titleTextFieldPlaceHolder;
        textField.textColor = [UIColor colorWithColor:[UIColor whiteColor] alpha:0.15];
    }
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    if (textField == self.titleTextField){
        [self.entryTextView becomeFirstResponder];
    }
    return YES;
}

-(void)textFieldDidChange:(UITextField*)textField {
    [self didChange:textField];
    
    if ([textField.text isEqualToString:titleTextFieldPlaceHolder]){
        [self.safeNote setTitle:@""];
    }
    else {
        [self.safeNote setTitle:textField.text];
    }
}

#pragma mark -UITextView Delegate
- (void)textViewDidBeginEditing:(UITextView *)textView{
    if ([textView.text isEqualToString:entryTextViewPlaceholder]) {
        textView.text = @"";
        textView.textColor = [UIColor paperColorBlue50];
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@""]) {
        textView.text = entryTextViewPlaceholder;
        textView.textColor = [UIColor colorWithColor:[UIColor whiteColor] alpha:0.15];
    }
}

-(void)textViewDidChange:(UITextView *)textView {
    [self didChange:textView];
    
    if ([textView.text isEqualToString:entryTextViewPlaceholder]){
        [self.safeNote setContent:@""];
    }
    else {
        [self.safeNote setContent:textView.text];
    }
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
