//
//  ImagesVC.m
//  CoreSafe
//
//  Created by Main on 12/30/16.
//  Copyright © 2016 Matt Brotman. All rights reserved.
//

#import "ImagesVC.h"
#import "BFKit.h"
#import "ImageCell.h"
#import "BouncyButton.h"
#import "CameraVC.h"
#import "ViewUtils.h"
#import "UIColor+BFPaperColors.h"
#import "ImageViewer.h"
#import "PublicPhotoCollectionVC.h"

@interface ImagesVC () <UICollectionViewDelegate, UICollectionViewDataSource, ImageViewerDelegate, PublicPhotoCollectionDelegate>

@property NSMutableArray* images;

@property UICollectionView* collectionView;
@property float cellSize;
@property float collectionViewCushion;
@property float cellsPerRow;

@property (weak, nonatomic) PublicPhotoCollectionVC* publicCollection;
@property ImagePickerPresenter* presenter;
@property BOOL presentingPPC;

@end

@implementation ImagesVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    CGFloat topOfView = [UIApplication sharedApplication].statusBarFrame.size.height + self.navigationController.navigationBar.frame.size.height + 40;
    
    self.view.backgroundColor = [UIColor paperColorBlueGray900];
        
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
    
    self.collectionView=[[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - topOfView) collectionViewLayout:layout];
    [self.collectionView setDataSource:self];
    [self.collectionView setDelegate:self];
    [self.collectionView registerClass:[ImageCell class] forCellWithReuseIdentifier:@"ImageCell"];
    [self.collectionView setBackgroundColor:[UIColor clearColor]];
    self.collectionView.showsVerticalScrollIndicator = NO;
        
    [self.view addSubview:self.collectionView];
    
    _presentingPPC = NO;
    _presenter = [ImagePickerPresenter presenterWithViewController:self shouldPresentBlock:^{
        if (!_publicCollection) {
            _publicCollection = [self.storyboard instantiateViewControllerWithIdentifier:@"PublicPhotoCollectionVC"];
            _publicCollection.delegate = self;
        }
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:_publicCollection];
        [self presentViewController:navigationController animated:NO completion:^{
            [_presenter remove];
            self.presentingPPC = YES;
        }];
    }];
}

-(void)viewDidAppear:(BOOL)animated {
    if (!_presenter.isShowing) {
        [_presenter show];
    }
}
-(void)viewWillDisappear:(BOOL)animated {
    if (!_presentingPPC) {
        [_presenter remove];
    }
}

- (void)fillImages {
    _images = [[NSMutableArray alloc] init];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)goToCamera {
    if ([UIImagePickerController isSourceTypeAvailable:
         UIImagePickerControllerSourceTypeCamera])
    {
        CameraVC* camera = [[CameraVC alloc] init];
        camera.didDismiss = ^(BOOL usingPhoto, UIImage* image) {
            if (usingPhoto) {
                [_images insertObject:UIImagePNGRepresentation(image) atIndex:0];
                [_collectionView reloadData];
            }
        };
        [self presentViewController:camera animated:YES completion:^ {
            
        }];
    }
}


#pragma mark - UICollectionViewDataSource / Delegate
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.images.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ImageCell* cell = (ImageCell*)[collectionView dequeueReusableCellWithReuseIdentifier:@"ImageCell" forIndexPath:indexPath];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(void) {
        
        UIImage* scaledImage = [self imageWithImage:[UIImage imageWithData:[_images objectAtIndex:indexPath.row]] scaledToFillSize:CGSizeMake(_cellSize, _cellSize)];
        
        dispatch_sync(dispatch_get_main_queue(), ^(void) {
            
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

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    CGRect frame = [self getConvertedFrameFromIndex:indexPath.row];
    ImageViewer* imageViewer = [ImageViewer imageViewerWithImages:_images currentIndex:indexPath.row originFrame:frame];
    imageViewer.delegate = self;
    [imageViewer show:YES];
}

#pragma mark - ImageViewerDelegate
-(void)imageViewer:(ImageViewer *)viewer dismissAnimationsBeganAtIndex:(NSInteger)index {
    ImageCell* cell =  (ImageCell*)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    [cell cover];
    
    [_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:NO];
    viewer.destinationRect = [self getConvertedFrameFromIndex:index];
}
-(void)imageViewer:(ImageViewer *)viewer dismissAnimationsCancelledAtIndex:(NSInteger)index {
    ImageCell* cell =  (ImageCell*)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    [cell uncover];
}
-(void)imageViewer:(ImageViewer *)viewer didDismissFromIndex:(NSInteger)index animated:(BOOL)animated {
    ImageCell* cell =  (ImageCell*)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    [cell uncover];
}

-(CGRect)getConvertedFrameFromIndex:(NSInteger)index {
    NSIndexPath* indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    UICollectionViewLayoutAttributes* attributes = [_collectionView layoutAttributesForItemAtIndexPath:indexPath];
    CGRect frame = [_collectionView convertRect:attributes.frame toView:nil];
    return frame;
}

#pragma mark - PublicPhotCollectionDelegate
-(void)photoCollection:(PublicPhotoCollectionVC *)vc didChooseImages:(NSArray *)imageDataArray {
    [_images insertObjects:imageDataArray atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, imageDataArray.count)]];
    [_collectionView reloadData];
}

-(void)photoCollectionDismissed:(PublicPhotoCollectionVC *)vc {
    [_presenter show];
    self.presentingPPC = NO;
}

@end
