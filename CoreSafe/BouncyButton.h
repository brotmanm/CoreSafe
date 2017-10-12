//
//  BouncyButton.h
//  CoreSafe
//
//  Created by Main on 12/25/16.
//  Copyright © 2016 Matt Brotman. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BouncyButton : UIButton

- (instancetype)initWithRaised:(BOOL)raised;
- (instancetype)initWithFrame:(CGRect)frame raised:(BOOL)raised;
- (void)setRaised:(BOOL)raised;

@end
