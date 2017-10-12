//
//  KeyVC.m
//  CoreSafe
//
//  Created by Main on 12/30/16.
//  Copyright © 2016 Matt Brotman. All rights reserved.
//

#import "KeyVC.h"
#import "UIColor+BFPaperColors.h"
#import "BouncyButton.h"
#import "BFKit.h"
#import "ViewUtils.h"
#import "font-awesome-codes.h"
#import "FontAwesome.h"
#import "BFRadialWaveView.h"

@interface KeyVC () <UITableViewDelegate, UITableViewDataSource>

@property NSMutableArray* keyArray;
@property UITableView* keyTableView;

@end

@implementation KeyVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor paperColorBlueGray900]];
    
    UIImageView* backgroundImageView = [[UIImageView alloc] initWithFrame:self.view.frame];
    backgroundImageView.image = [UIImage imageNamed:@"key.jpg"];
    [self.view addSubview:backgroundImageView];
    
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    UIVisualEffectView *blurView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    UIVibrancyEffect *vibrancyEffect = [UIVibrancyEffect effectForBlurEffect:blurEffect];
    UIVisualEffectView *vibrancyView = [[UIVisualEffectView alloc] initWithEffect:vibrancyEffect];
    vibrancyView.frame = self.view.frame;
    blurView.frame = self.view.frame;
    [blurView addSubview:vibrancyView];
    blurView.backgroundColor = [UIColor colorWithColor:[UIColor paperColorGray900] alpha:0.5];
    [self.view addSubview:blurView];
    
    self.keyTableView=[[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];
    self.keyTableView.height = _keyTableView.height - 105;
    [self.keyTableView setBackgroundColor:[UIColor clearColor]];
    [self.keyTableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    self.keyTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.keyTableView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    [self.keyTableView registerClass:UITableViewCell.class forCellReuseIdentifier:@"KeyCell"];
    self.keyTableView.allowsSelectionDuringEditing = YES;
    self.keyTableView.showsVerticalScrollIndicator = NO;
    self.keyTableView.dataSource=self;
    self.keyTableView.delegate=self;
    [vibrancyView.contentView addSubview:self.keyTableView];
    
    BouncyButton* addButton = [[BouncyButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2-20, 0, 46, 46) raised:YES];
    addButton.bottom = SCREEN_HEIGHT-130;
    //addButton.center = CGPointMake(self.view.width/2, self.view.height);
    addButton.backgroundColor = [UIColor colorWithColor:[UIColor paperColorTeal700] alpha:0.7];
    [addButton setFont:[FontAwesome fontWithSize:28]];
    [addButton setTitleColor:[UIColor whiteColor]];
    [addButton setTitle:fa_plus forState:UIControlStateNormal];
    [addButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
    addButton.layer.cornerRadius = addButton.width/2;
    [addButton addTarget:self action:@selector(addPassword:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:addButton];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)fillKeyArray {
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSArray* immutableInfoArray = [defaults objectForKey:@"keyArray"];
    if (immutableInfoArray) {
        self.keyArray = [[NSMutableArray alloc] initWithArray:immutableInfoArray];
    }
    else {
        self.keyArray = [[NSMutableArray alloc] init];
    }
    
    for (int i = 0; i < _keyArray.count; ++i){
        NSData* encryptedData = [self.keyArray objectAtIndex:i];
        SafeNote* safeNote = [SafeNote decryptSafeNoteData:encryptedData];
        if (!safeNote){
            safeNote = [[SafeNote alloc] init];
        }
        [self.keyArray replaceObjectAtIndex:i withObject:safeNote];
    }
}

-(void)toggleEditingMode {
    [self.keyTableView setEditing:!self.keyTableView.editing animated: YES];
}

-(void)saveAndReloadTableView {
    [self.keyTableView reloadData];
}

-(void)addNote:(SafeNote *)note {
    [self.keyArray addObject:note];
    [self saveAndReloadTableView];
}

-(void)deleteNoteAtIndex:(NSUInteger)index {
    [self.keyArray removeObjectAtIndex:index];
    [self saveAndReloadTableView];
}

-(void)addPassword:(id)sender {
    if ([sender isKindOfClass:[UIButton class]]) {
        /*
        InfoEditorControllerVC* controllerVC = [self.storyboard instantiateViewControllerWithIdentifier:@"InfoEditor"];
        controllerVC.isNewFile = YES;
        controllerVC.presentingVC = self;
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controllerVC];
        [self presentViewController:navigationController animated:YES completion:nil];
         */
    }
}

#pragma mark - UITableViewDelegate / UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return self.keyArray.count;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"KeyCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"KeyCell"];
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    cell.textLabel.font = [UIFont fontWithName:@"ArialRoundedMTBold" size:18];
    cell.textLabel.numberOfLines = 1;
    cell.textLabel.minimumFontSize = 12;
    cell.textLabel.adjustsFontSizeToFitWidth = YES;
    cell.textLabel.left = cell.textLabel.left + 30;
    cell.textLabel.width = cell.textLabel.width - 30;
    [cell.textLabel setTextColor:[UIColor blackColor]];
    [cell.textLabel setHighlightedTextColor:[UIColor blackColor]];
    [cell.textLabel setTintColor:[UIColor blackColor]];
    
    CALayer* divider = [CALayer layer];
    divider.frame = CGRectMake(50, 0, SCREEN_WIDTH-50, 2);
    divider.backgroundColor = [UIColor colorWithColor:[UIColor blackColor] alpha:2].CGColor;
    [cell.layer addSublayer:divider];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    //[cell setBackgroundColor:[UIColor colorWithColor:[UIColor paperColorCyan900] alpha:1]];
    [cell setBackgroundColor:[UIColor colorWithColor:[UIColor whiteColor] alpha:1]];
    
    SafeNote* safeNote = (SafeNote*)[self.keyArray objectAtIndex:indexPath.row];
    cell.imageView.image = [self getIconFromString:safeNote.title];
    
    cell.textLabel.text = safeNote.title;
}

-(UIImage*)getIconFromString:(NSString*)titleString {
    NSString* string = titleString.lowercaseString;
    UIImage* iconImage;
    UIColor* color = [UIColor colorWithColor:[UIColor blackColor] alpha:0.8];
    if ([string containsString:@"credit"]) {
        iconImage = [FontAwesome imageWithIcon:fa_credit_card iconColor:color iconSize:25];
    }
    else if ([string containsString:@"card"]) {
        iconImage = [FontAwesome imageWithIcon:fa_credit_card iconColor:color iconSize:25];
    }
    else if ([string containsString:@"shop"]) {
        iconImage = [FontAwesome imageWithIcon:fa_shopping_cart iconColor:color iconSize:25];
    }
    else if ([string containsString:@"store"]) {
        iconImage = [FontAwesome imageWithIcon:fa_shopping_cart iconColor:color iconSize:25];
    }
    else if ([string containsString:@"list"]) {
        iconImage = [FontAwesome imageWithIcon:fa_list_alt iconColor:color iconSize:25];
    }
    else if (titleString.length >= 10) {
        iconImage = [FontAwesome imageWithIcon:fa_file_text iconColor:color iconSize:25];
    }
    else {
        iconImage = [FontAwesome imageWithIcon:fa_file iconColor:color iconSize:25];
    }
    
    return iconImage;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}

-(BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return @"Tap top right button to move and delete passwords";
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    header.textLabel.textColor = [UIColor colorWithColor:[UIColor paperColorBlue100] alpha:0.8];
    header.textLabel.font = [UIFont fontWithName:@"ArialRoundedMTBold" size:13];
    
    CGRect headerFrame = header.frame;
    header.textLabel.frame = headerFrame;
    header.textLabel.textAlignment = NSTextAlignmentCenter;
    header.contentView.backgroundColor = [UIColor paperColorBlueGray900];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //[self performSegueWithIdentifier:@"PushEditor" sender:[tableView cellForRowAtIndexPath:indexPath]];
    self.currentlySelectedNoteIndex = indexPath.row;
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath{
    [self.keyArray moveObjectFromIndex:sourceIndexPath.row toIndex:destinationIndexPath.row];
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.keyArray removeObjectAtIndex:indexPath.row];
        [self.keyTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

-(BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if (self.keyTableView.editing) {
        [self.keyTableView setEditing:NO animated:YES];
    }
    
    UIViewController* vc = [segue destinationViewController];
    if ([sender isKindOfClass:[UITableViewCell class]]) {
        /*
        InfoEditorControllerVC* infoEditorVC = (InfoEditorControllerVC*)vc;
        
        infoEditorVC.safeNote = [self.keyArray objectAtIndex:[self.keyTableView indexPathForSelectedRow].row];
        infoEditorVC.isNewFile = NO;
        infoEditorVC.presentingVC = self;
         */
    }
}


-(IBAction)unwindToKeyVC:(UIStoryboardSegue*)segue {
    
}

@end
