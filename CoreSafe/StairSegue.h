//
//  StairSegue.h
//  CoreSafe
//
//  Created by Main on 1/18/17.
//  Copyright © 2017 Matt Brotman. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StairSegue : UIStoryboardSegue

- (instancetype)initWithIdentifier:(NSString *)identifier source:(UIViewController *)source destination:(UIViewController *)destination;
- (void)perform;

@end
