//
//  PublicPhotoCollectionVC.m
//  CoreSafe
//
//  Created by Main on 8/4/16.
//  Copyright © 2016 Matt Brotman. All rights reserved.
//

#import "PublicPhotoCollectionVC.h"
#import "UIColor+BFPaperColors.h"
#import "BFKit.h"
#import "UINavigationBar+Awesome.h"
#import <Photos/Photos.h>
#import "BFRadialWaveView.h"
#import "SIAlertVIew.h"
#import "ImageCell.h"

@interface PublicPhotoCollectionVC () <UICollectionViewDataSource, UICollectionViewDelegate>

@property UICollectionView* collectionView;
@property NSArray* photoLibrary;
@property NSMutableArray* selectedIndexPaths;
@property NSMutableArray* photosToAdd;

@property float cellSize;
@property float collectionViewCushion;
@property float cellsPerRow;

@end

@implementation PublicPhotoCollectionVC
@synthesize delegate;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    CGFloat topOfView = [UIApplication sharedApplication].statusBarFrame.size.height + self.navigationController.navigationBar.frame.size.height;
    
    self.view.backgroundColor = [UIColor paperColorBlueGray500];
    
    [self.navigationController.navigationBar lt_setBackgroundColor:[UIColor paperColorBlueGray900]]; //configure our navbar
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor paperColorBlue100]}];
    self.navigationController.navigationBar.tintColor = [UIColor paperColorBlue100];
    self.navigationController.navigationBar.alpha = 0;
    
    UIBarButtonItem* cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelPhotoCollection:)];
    self.navigationItem.leftBarButtonItem = cancelButton;
    UIBarButtonItem* chooseButton = [[UIBarButtonItem alloc] initWithTitle:@"Choose" style:UIBarButtonItemStylePlain target:self action:@selector(savePhotoCollection:)];
    self.navigationItem.rightBarButtonItem = chooseButton;
    
    self.photosToAdd = [[NSMutableArray alloc] init];
    
    self.selectedIndexPaths = [[NSMutableArray alloc] init];
    
    if ([PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusAuthorized){
        __block BFRadialWaveView* waveView = [[BFRadialWaveView alloc] initWithView:self.view circles:10 color:[UIColor paperColorBlueGray900] mode:BFRadialWaveViewMode_Default strokeWidth:5 withGradient:NO];
        [waveView show]; //start a loading indicator
        
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
            
            self.photoLibrary = [[[self getAllPhotosFromCamera] reverseObjectEnumerator] allObjects]; //request an array of all the phone's photos on a seperate queue
            
            dispatch_async(dispatch_get_main_queue(), ^(void){
                
                [waveView removeFromSuperview]; //once complete disable our loading indiciator
                
                UICollectionViewFlowLayout* layout=[[UICollectionViewFlowLayout alloc] init];//collection view for image page
                _collectionViewCushion = 4.0;
                if ([UIDevice isiPad]) {
                    _cellsPerRow = 5;
                }
                else {
                    _cellsPerRow = 3;
                }
                _cellSize = (float)(int)((SCREEN_WIDTH - (_cellsPerRow+1)*_collectionViewCushion) / _cellsPerRow);
                layout.sectionInset = UIEdgeInsetsMake(_collectionViewCushion, _collectionViewCushion, _collectionViewCushion, _collectionViewCushion);
                layout.itemSize = CGSizeMake(_cellSize, _cellSize);
                layout.minimumInteritemSpacing = _collectionViewCushion;
                layout.minimumLineSpacing = _collectionViewCushion;
                self.collectionView=[[UICollectionView alloc] initWithFrame:CGRectMake(0, topOfView+1, SCREEN_WIDTH, SCREEN_HEIGHT-topOfView) collectionViewLayout:layout];
                [self.collectionView setDataSource:self];
                [self.collectionView setDelegate:self];
                [self.collectionView registerClass:[ImageCell class] forCellWithReuseIdentifier:@"ImageCell"];
                [self.collectionView setBackgroundColor:[UIColor paperColorBlueGray500]];
                self.collectionView.showsVerticalScrollIndicator = YES;
                
                [self fadeInCollectionView:_collectionView];
                
            });
        });
    }
    else{
        SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"Error!" andMessage:@"We need permission to access your photo library.\nPlease go to your settings."];
        alertView.titleColor = [UIColor paperColorRed500];
        [alertView addButtonWithTitle:@"OK"
                                 type:SIAlertViewButtonTypeCancel
                              handler:^(SIAlertView *alert) {
                                  if ([delegate respondsToSelector:@selector(photoCollectionDismissed:)]) {
                                      [delegate photoCollectionDismissed:self];
                                  }
                                  [self dismissViewControllerAnimated:YES completion:nil];
                              }];
        alertView.cornerRadius = 5;
        alertView.transitionStyle = SIAlertViewTransitionStyleBounce;
        [alertView show];
    }

}

-(void)fadeInCollectionView:(UICollectionView*)cv {
    cv.alpha = 0;
    [self.view addSubview:cv];
    [UIView animateWithDuration:0.3
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.navigationController.navigationBar.alpha = 1;
                         cv.alpha = 1;
                     } completion:^(BOOL finished) {
                         nil;
                     }];
}

- (void)didReceiveMemoryWarning {
    NSLog(@"Error");
    if ([delegate respondsToSelector:@selector(photoCollectionDismissed:)]) {
        [delegate photoCollectionDismissed:self];
    }
    [self dismissViewControllerAnimated:YES completion:nil]; //segue to our main VC if we recieve a memory warning
    //[super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)cancelPhotoCollection:(id)sender {
    if ([delegate respondsToSelector:@selector(photoCollectionDismissed:)]) {
        [delegate photoCollectionDismissed:self];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(void)savePhotoCollection:(id)sender {
    if ([delegate respondsToSelector:@selector(photoCollection:didChooseImages:)]) {
        [delegate photoCollection:self didChooseImages:_photosToAdd];
    }
    if ([delegate respondsToSelector:@selector(photoCollectionDismissed:)]) {
        [delegate photoCollectionDismissed:self];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(NSArray*)getAllPhotosFromCamera
{
    NSArray *imageArray = [[NSArray alloc] init];
    //NSMutableArray *mutableArray =[[NSMutableArray alloc]init];
    
    PHImageRequestOptions *requestOptions = [[PHImageRequestOptions alloc] init]; //set up our request options
    requestOptions.resizeMode   = PHImageRequestOptionsResizeModeExact;
    requestOptions.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    requestOptions.synchronous = YES;
    PHFetchResult *result = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:nil]; //get the user's images
    
    PHImageManager *manager = [PHImageManager defaultManager];
    NSMutableArray *images = [NSMutableArray arrayWithCapacity:[result count]];
    
    // assets contains PHAsset objects.
    
    __block UIImage *ima;
    for (PHAsset *asset in result) { //for each photo asset
        // This method will cause a memory leak for a large photo library
        /*
        @autoreleasepool {
        [manager requestImageForAsset:asset
                           targetSize:PHImageManagerMaximumSize
                          contentMode:PHImageContentModeDefault
                              options:requestOptions
                        resultHandler:^void(UIImage *image, NSDictionary *info) {
                                ima = image;
                                [images addObject:ima];
                        }];
        }
         */
        // So use this method instead
        [manager requestImageDataForAsset:asset
                                  options:requestOptions
                            resultHandler:^(NSData *imageData, NSString *dataUTI, UIImageOrientation orientation, NSDictionary *info)
         {
             [images addObject:imageData]; //convert the data to an image and then add the image to our images array
             
         }];
    }
    
    imageArray = [images copy];
    return imageArray;
}

#pragma mark -Collection View Delegate
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell* cell = [collectionView cellForItemAtIndexPath:indexPath];
    if (cell.layer.borderWidth == 0){
        cell.layer.borderWidth = 8;
        cell.layer.borderColor = [UIColor paperColorBlue100].CGColor; //highlight the photo on selection if unselected
        
        [self.photosToAdd addObject:[self.photoLibrary objectAtIndex:indexPath.row]]; //add the photo to our photos to add array
        [self.selectedIndexPaths addObject:indexPath];
    }
    else{
        cell.layer.borderWidth = 0;
        cell.layer.borderColor = [UIColor clearColor].CGColor; //un-highlight the photo on selection if unselected
        
        [self.photosToAdd removeObject:[self.photoLibrary objectAtIndex:indexPath.row]]; //remove the photo from our photos to add array
        [self.selectedIndexPaths removeObject:indexPath];
    }
    [cell pulseViewWithDuration:.4];
    
}

#pragma mark -Collection View Data Source
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.photoLibrary.count; //number of cells is the size of the user's photo library
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ImageCell* cell = (ImageCell*)[collectionView dequeueReusableCellWithReuseIdentifier:@"ImageCell" forIndexPath:indexPath];

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(void) {
        
        UIImage* scaledImage = [self imageWithImage:[UIImage imageWithData:[_photoLibrary objectAtIndex:indexPath.row]] scaledToFillSize:CGSizeMake(_cellSize, _cellSize)];
        
        dispatch_sync(dispatch_get_main_queue(), ^(void) {
            
            if (![self.selectedIndexPaths containsObject:indexPath]){
                cell.layer.borderWidth = 0;
                cell.layer.borderColor = [UIColor clearColor].CGColor;
            }
            else{
                NSLog(@"here");
                cell.layer.borderWidth = 8;
                cell.layer.borderColor = [UIColor paperColorBlue100].CGColor;
            }
            cell.imageView.image = scaledImage;
            
        });
    });
    
    return cell;
}

- (UIImage *)imageWithImage:(UIImage *)image scaledToFillSize:(CGSize)size //scale the image to fit in the size without distorting it
{
    CGFloat scale = MAX(size.width/image.size.width, size.height/image.size.height);
    CGFloat width = image.size.width * scale;
    CGFloat height = image.size.height * scale;
    CGRect imageRect = CGRectMake((size.width - width)/2.0f,
                                  (size.height - height)/2.0f,
                                  width,
                                  height);
    
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    [image drawInRect:imageRect];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}
@end
