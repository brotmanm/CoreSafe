//
//  Password.h
//  CoreSafe
//
//  Created by Main on 12/25/16.
//  Copyright © 2016 Matt Brotman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BFPassword.h"

@interface Password : NSObject

-(Password*)init;
-(Password*)initWithString:(NSString*)passString;
-(NSString*)stringRepresentation;
-(void)saveWithKey:(NSString*)defaultsKey;
-(BOOL)isValid;
-(void)update:(NSString*)newPassString;
-(NSString*)strength;


@end
