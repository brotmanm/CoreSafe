//
//  PublicPhotoCollectionVC.h
//  CoreSafe
//
//  Created by Main on 8/4/16.
//  Copyright © 2016 Matt Brotman. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PublicPhotoCollectionVC;

@protocol PublicPhotoCollectionDelegate <NSObject>

@optional

-(void)photoCollection:(PublicPhotoCollectionVC*)vc didChooseImages:(NSArray*)imageDataArray;
-(void)photoCollectionDismissed:(PublicPhotoCollectionVC *)vc;

@end


@interface PublicPhotoCollectionVC : UIViewController

@property (nonatomic, weak) id <PublicPhotoCollectionDelegate> delegate;

@end
