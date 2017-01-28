//
//  ImageCell.m
//  CoreSafe
//
//  Created by Main on 1/16/17.
//  Copyright © 2017 Matt Brotman. All rights reserved.
//

#import "ImageCell.h"

@interface ImageCell ()

@end

@implementation ImageCell
@synthesize isCovered;
@synthesize imageView;

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self setup];
    }
    
    return self;
}

-(void)awakeFromNib
{
    [super awakeFromNib];
    
    self.contentView.frame = self.bounds;
    self.contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
}

- (void)setup {
    if (!imageView) {
        imageView = [[UIImageView alloc] initWithFrame:self.contentView.bounds];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
        [self.contentView addSubview:imageView];
    }
    
    self.clipsToBounds = YES;
    self.backgroundColor = [UIColor blackColor];
}

-(void)prepareForReuse {
    [super prepareForReuse];
    self.imageView.layer.shouldRasterize = YES;
    self.imageView.layer.rasterizationScale = [UIScreen mainScreen].scale;
    imageView.image = nil;
    imageView.frame = self.contentView.bounds;
}

- (void)cover {
    self.backgroundColor = [UIColor clearColor];
    imageView.hidden = YES;
    isCovered = YES;
}
- (void)uncover {
    imageView.hidden = NO;
    self.backgroundColor = [UIColor blackColor];
    isCovered = NO;
}

@end
