//
//  InfoVC.m
//  CoreSafe
//
//  Created by Main on 12/30/16.
//  Copyright © 2016 Matt Brotman. All rights reserved.
//

#import "InfoVC.h"
#import "UIColor+BFPaperColors.h"
#import "BouncyButton.h"
#import "BFKit.h"
#import "ViewUtils.h"
#import "font-awesome-codes.h"
#import "FontAwesome.h"
#import "InfoEditorControllerVC.h"
#import "BFRadialWaveView.h"

@interface InfoVC () <UITableViewDelegate, UITableViewDataSource>

@property NSMutableArray* infoArray;
@property UITableView* infoTableView;

@end

@implementation InfoVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor paperColorBlueGray900]];
    
    UIImageView* backgroundImageView = [[UIImageView alloc] initWithFrame:self.view.frame];
    backgroundImageView.image = [UIImage imageNamed:@"himMountains.jpg"];
    [self.view addSubview:backgroundImageView];
    
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];  // or UIBlurEffectStyleDark
    UIVisualEffectView *blurView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    UIVibrancyEffect *vibrancyEffect = [UIVibrancyEffect effectForBlurEffect:blurEffect];
    UIVisualEffectView *vibrancyView = [[UIVisualEffectView alloc] initWithEffect:vibrancyEffect];
    vibrancyView.frame = self.view.frame;
    blurView.frame = self.view.frame;
    [blurView addSubview:vibrancyView];
    blurView.backgroundColor = [UIColor colorWithColor:[UIColor paperColorGray900] alpha:0.5];
    [self.view addSubview:blurView];
             
    self.infoTableView=[[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];
    self.infoTableView.height = _infoTableView.height - 105;
    [self.infoTableView setBackgroundColor:[UIColor clearColor]];
    [self.infoTableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    self.infoTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.infoTableView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    [self.infoTableView registerClass:UITableViewCell.class forCellReuseIdentifier:@"InfoCell"];
    self.infoTableView.allowsSelectionDuringEditing = YES;
    self.infoTableView.showsVerticalScrollIndicator = NO;
    self.infoTableView.dataSource=self;
    self.infoTableView.delegate=self;
    [vibrancyView.contentView addSubview:self.infoTableView];
    
    BouncyButton* addButton = [[BouncyButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2-20, 0, 46, 46) raised:YES];
    addButton.bottom = SCREEN_HEIGHT-130;
    //addButton.center = CGPointMake(self.view.width/2, self.view.height);
    addButton.backgroundColor = [UIColor colorWithColor:[UIColor paperColorBlueGray700] alpha:0.75];
    [addButton setFont:[FontAwesome fontWithSize:28]];
    [addButton setTitleColor:[UIColor paperColorBlueGray100]];
    [addButton setTitle:fa_plus forState:UIControlStateNormal];
    [addButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
    addButton.layer.cornerRadius = addButton.width/2;
    [addButton addTarget:self action:@selector(addInfo:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:addButton];
}

-(void)fillInfoArray {
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSArray* immutableInfoArray = [defaults objectForKey:@"infoArray"];
    if (immutableInfoArray) {
        self.infoArray = [[NSMutableArray alloc] initWithArray:immutableInfoArray];
    }
    else {
        self.infoArray = [[NSMutableArray alloc] init];
    }
    
    for (int i = 0; i < _infoArray.count; ++i){
        NSData* encryptedData = [self.infoArray objectAtIndex:i];
        SafeNote* safeNote = [SafeNote decryptSafeNoteData:encryptedData];
        if (!safeNote){
            safeNote = [[SafeNote alloc] init];
        }
        [self.infoArray replaceObjectAtIndex:i withObject:safeNote];
    }
}

-(void)viewWillAppear:(BOOL)animated {
    self.navigationController.viewControllers[0].title = @"Private Information";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)toggleEditingMode {
    [self.infoTableView setEditing:!self.infoTableView.editing animated: YES];
}

-(void)saveAndReloadTableView {
    [self.infoTableView reloadData];
}

-(void)addNote:(SafeNote *)note {
    [self.infoArray addObject:note];
    [self saveAndReloadTableView];
}

-(void)deleteNoteAtIndex:(NSUInteger)index {
    [self.infoArray removeObjectAtIndex:index];
    [self saveAndReloadTableView];
}

-(void)addInfo:(id)sender {
    if ([sender isKindOfClass:[UIButton class]]) {
        InfoEditorControllerVC* controllerVC = [self.storyboard instantiateViewControllerWithIdentifier:@"InfoEditor"];
        controllerVC.isNewFile = YES;
        controllerVC.presentingVC = self;
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controllerVC];
        [self presentViewController:navigationController animated:YES completion:nil];
    }
}

#pragma mark - UITableViewDelegate / UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return self.infoArray.count;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"InfoCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"InfoCell"];
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
    
    SafeNote* safeNote = (SafeNote*)[self.infoArray objectAtIndex:indexPath.row];
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
    return @"Tap top right button to move and delete files";
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
    [self performSegueWithIdentifier:@"PushEditor" sender:[tableView cellForRowAtIndexPath:indexPath]];
    self.currentlySelectedNoteIndex = indexPath.row;
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath{
    [self.infoArray moveObjectFromIndex:sourceIndexPath.row toIndex:destinationIndexPath.row];
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.infoArray removeObjectAtIndex:indexPath.row];
        [self.infoTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

-(BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}


 #pragma mark - Navigation

 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
     if (self.infoTableView.editing) {
         [self.infoTableView setEditing:NO animated:YES];
     }
     
     UIViewController* vc = [segue destinationViewController];
     if ([sender isKindOfClass:[UITableViewCell class]]) {
         InfoEditorControllerVC* infoEditorVC = (InfoEditorControllerVC*)vc;
         
         infoEditorVC.safeNote = [self.infoArray objectAtIndex:[self.infoTableView indexPathForSelectedRow].row];
         infoEditorVC.isNewFile = NO;
         infoEditorVC.presentingVC = self;
     }
 }
 

-(IBAction)unwindToInfoVC:(UIStoryboardSegue*)segue {

}

@end
