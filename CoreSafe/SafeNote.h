//
//  SafeNote.h
//  CoreSafe
//
//  Created by Main on 1/2/17.
//  Copyright © 2017 Matt Brotman. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SafeNote : NSObject <NSCoding>

@property NSString* title;
@property BOOL imageSelected;

-(BOOL)hasFirstImage;
-(BOOL)hasSecondImage;
-(NSString*)getContent;
-(void)setContent:(NSString*)note;
-(NSData*)getFirstImageData;
-(NSData*)getSecondImageData;
-(void)setFirstImageData:(NSData*)data;
-(void)setSecondImageData:(NSData*)data;
-(void)clearFirstImageData;
-(void)clearSecondImageData;

+(NSData*)encryptSafeNote:(SafeNote*)note;
+(SafeNote*)decryptSafeNoteData:(NSData*)noteData;

@end
