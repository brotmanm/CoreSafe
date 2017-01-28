//
//  MainControllerVC.m
//  CoreSafe
//
//  Created by Main on 12/30/16.
//  Copyright © 2016 Matt Brotman. All rights reserved.
//

#import "MainControllerVC.h"
#import "CarbonKit.h"
#import "UIColor+BFPaperColors.h"
#import "font-awesome-codes.h"
#import "FontAwesome.h"
#import "UINavigationBar+Awesome.h"
#import "BFKit.h"
#import "BFRadialWaveView.h"

@interface MainControllerVC () <CarbonTabSwipeNavigationDelegate>

@property NSArray* swipeItems;
@property CarbonTabSwipeNavigation* swipeNav;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *leftBarButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *rightBarButton;

@property UIView* darkIndicatorBackground;

@end

@implementation MainControllerVC

int currentIndex = 0;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.homeVC = [self.storyboard instantiateViewControllerWithIdentifier:@"HomeVC"];
    self.infoVC = [self.storyboard instantiateViewControllerWithIdentifier:@"InfoVC"];
    self.keyVC = [self.storyboard instantiateViewControllerWithIdentifier:@"KeyVC"];
    self.imagesVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ImagesVC"];
    self.settingsVC = [self.storyboard instantiateViewControllerWithIdentifier:@"SettingsVC"];
    
    _swipeItems = @[fa_home, fa_folder, fa_key, fa_picture_o, fa_cog];
    self.swipeNav = [[CarbonTabSwipeNavigation alloc] initWithItems:_swipeItems delegate:self];
    [self.swipeNav insertIntoRootViewController:self];
    
    [self.navigationController.navigationBar lt_setBackgroundColor:[UIColor paperColorBlueGray700]];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor paperColorBlue50],
                                                 
                                                                      NSFontAttributeName: [UIFont fontWithName:@"ArialHebrew-Bold" size:20]}];
    [self.navigationController.navigationBar setTintColor:[UIColor paperColorBlue100]];
    self.navigationController.navigationBar.translucent = YES;
    
    _swipeNav.toolbar.translucent = NO;
    _swipeNav.toolbar.barTintColor = [UIColor paperColorBlueGray700];
    [_swipeNav setIndicatorColor:[UIColor colorWithColor:[UIColor paperColorBlue100] alpha:1]];
    [_swipeNav setTabExtraWidth:0];
    [_swipeNav.carbonSegmentedControl setWidth:80 forSegmentAtIndex:0];
    [_swipeNav.carbonSegmentedControl setWidth:80 forSegmentAtIndex:1];
    [_swipeNav.carbonSegmentedControl setWidth:80 forSegmentAtIndex:2];
    [_swipeNav.carbonSegmentedControl setWidth:80 forSegmentAtIndex:3];
    [_swipeNav.carbonSegmentedControl setWidth:80 forSegmentAtIndex:4];
    
    // Custimize segmented control
    [_swipeNav setNormalColor:[UIColor colorWithColor:[UIColor paperColorBlue100] alpha:0.6]
                                        font:[FontAwesome fontWithSize:22]];
    [_swipeNav setSelectedColor:[UIColor colorWithColor:[UIColor paperColorBlue100] alpha:1] font:[FontAwesome fontWithSize:26]];
    
    [self.view setBackgroundColor:[UIColor paperColorBlueGray900]];
    
    [self.leftBarButton setTitleTextAttributes:@{
                                                 NSFontAttributeName:[FontAwesome fontWithSize:26],
                                                 NSForegroundColorAttributeName: [UIColor paperColorBlue100]
                                                 } forState:UIControlStateNormal];
    [self.leftBarButton setTarget:self];
    
    [self.rightBarButton setTitleTextAttributes:@{
                                                  NSFontAttributeName:[FontAwesome fontWithSize:26],
                                                  NSForegroundColorAttributeName: [UIColor paperColorBlue100]
                                                  } forState:UIControlStateNormal];
    [self.rightBarButton setTarget:self];
    [self.rightBarButton setAction:@selector(rightButtonAction:)];
    
    _darkIndicatorBackground = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    _darkIndicatorBackground.backgroundColor = [UIColor colorWithColor:[UIColor blackColor] alpha:0.25];
    _darkIndicatorBackground.alpha = 0;
    BFRadialWaveView* waveView = [[BFRadialWaveView alloc] initWithView:_darkIndicatorBackground circles:12 color:[UIColor paperColorBlueGray100] mode:BFRadialWaveViewMode_Default strokeWidth:4 withGradient:NO];
    [self.view addSubview:_darkIndicatorBackground];
    [waveView show];
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(void){
        
        [self setupViewControllers];
        
        dispatch_async(dispatch_get_main_queue(), ^(void){
            
            [_darkIndicatorBackground removeFromSuperview];
            
        });
    });
}

-(void)setupViewControllers {
    [self.infoVC fillInfoArray];
    [self.imagesVC fillImages];
}

-(void)viewDidAppear:(BOOL)animated {
    _darkIndicatorBackground.alpha = 1;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)lockApp:(id)sender {
    [self performSegueWithIdentifier:@"LockSegue" sender:sender];
}

-(void)rightButtonAction:(id)sender {
    switch (currentIndex) {
        case 0:
            break;
        case 1:
            [self.infoVC toggleEditingMode];
            break;
        case 2:
            break;
        case 3:
            [self.imagesVC goToCamera];
            break;
        case 4:
            break;
        default:
            break;
    }

}

#pragma mark - CarbonTabSwipeNavigation Delegate
- (nonnull UIViewController *)carbonTabSwipeNavigation: (nonnull CarbonTabSwipeNavigation *)carbontTabSwipeNavigation
                                 viewControllerAtIndex:(NSUInteger)index {
    switch (index) {
        case 0:
            return self.homeVC;
        case 1:
            return self.infoVC;
        case 2:
            return self.keyVC;
        case 3:
            return self.imagesVC;
        case 4:
            return self.settingsVC;
        default:
            return self.homeVC;
    }
}

- (void)carbonTabSwipeNavigation:(nonnull CarbonTabSwipeNavigation *)carbonTabSwipeNavigation
                 willMoveAtIndex:(NSUInteger)index {
    switch (index) {
        case 0:
            self.title = @"Home";
            
            self.leftBarButton.title = fa_lock;
            [self.leftBarButton setAction:@selector(lockApp:)];
            
            self.rightBarButton.title = fa_info_circle;
            break;
        case 1:
            self.title = @"Private Information";
            
            self.rightBarButton.title = fa_list;
            break;
        case 2:
            self.title = @"Passwords";
            
            self.rightBarButton.title = fa_list;
            break;
        case 3:
            self.title = @"Private Images";
            
            self.rightBarButton.title = fa_camera;
            break;
        case 4:
            self.title = @"Settings";
            
            self.rightBarButton.title = fa_info_circle;
            break;
    }
}

- (void)carbonTabSwipeNavigation:(nonnull CarbonTabSwipeNavigation *)carbonTabSwipeNavigation
                  didMoveAtIndex:(NSUInteger)index {
    currentIndex = (int)index;
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
