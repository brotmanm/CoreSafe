//
//  ImageCell.h
//  CoreSafe
//
//  Created by Main on 1/16/17.
//  Copyright © 2017 Matt Brotman. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImageCell : UICollectionViewCell

- (void)cover;
- (void)uncover;

@property (nonatomic) UIImageView* imageView;
@property (nonatomic, readonly) BOOL isCovered;


@end
