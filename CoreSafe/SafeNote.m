
//
//  SafeNote.m
//  CoreSafe
//
//  Created by Main on 1/2/17.
//  Copyright © 2017 Matt Brotman. All rights reserved.
//

#import "SafeNote.h"
#import "BFKit.h"

@interface SafeNote ()

@property BOOL containsFirstImage;
@property BOOL containsSecondImage;
@property (nonatomic) NSString* content;
@property (nonatomic) NSData* firstImgData;
@property (nonatomic) NSData* secondImgData;

@end

@implementation SafeNote

@synthesize title;
@synthesize imageSelected;

- (id)initWithCoder:(NSCoder *)decoder {
    if (self = [super init]) {
        self.containsFirstImage = [decoder decodeBoolForKey:@"containsFirstImage"];
        self.containsSecondImage = [decoder decodeBoolForKey:@"containsSecondImage"];
        imageSelected = [decoder decodeBoolForKey:@"imageSelected"];
        title = [decoder decodeObjectForKey:@"title"];
        self.content = [decoder decodeObjectForKey:@"content"];
        self.firstImgData = [decoder decodeObjectForKey:@"firstImgData"];
        self.secondImgData = [decoder decodeObjectForKey:@"secondImgData"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeBool:self.containsFirstImage forKey:@"containsFirstImage"];
    [encoder encodeBool:self.containsSecondImage forKey:@"containsSecondImage"];
    [encoder encodeBool:imageSelected forKey:@"imageSelected"];
    [encoder encodeObject:title forKey:@"title"];
    [encoder encodeObject:self.content forKey:@"content"];
    [encoder encodeObject:self.firstImgData forKey:@"firstImgData"];
    [encoder encodeObject:self.secondImgData forKey:@"secondImgData"];
}

-(BOOL)hasFirstImage {
    return self.containsFirstImage;
}

-(BOOL)hasSecondImage {
    return self.containsSecondImage;
}

-(NSString*)getContent {
    return _content;
}

-(void)setContent:(NSString*)note {
    _content = note;
}

-(NSData*)getFirstImageData {
    if (self.containsFirstImage) {
        return self.firstImgData;
    }
    else {
        NSLog(@"Error getting first image data.");
        return [NSData data];
    }
}

-(NSData*)getSecondImageData {
    if (self.containsSecondImage) {
        return self.secondImgData;
    }
    else {
        NSLog(@"Error getting second image data.");
        return [NSData data];
    }
}

-(void)setFirstImageData:(NSData*)data {
    if (data && data.length > 0) {
        self.firstImgData = [NSData dataWithData:data];
        self.containsFirstImage = YES;
    }
    else {
        NSLog(@"Error setting first image data.");
    }
}

-(void)setSecondImageData:(NSData*)data {
    if (data && data.length > 0) {
        self.secondImgData = [NSData dataWithData:data];
        self.containsSecondImage = YES;
    }
    else {
        NSLog(@"Error setting second image data.");
    }
}

-(void)clearFirstImageData {
    self.firstImgData = [NSData data];
    self.containsFirstImage = NO;
}

-(void)clearSecondImageData {
    self.secondImgData = [NSData data];
    self.containsSecondImage = NO;
}

+(NSData*)encryptSafeNote:(SafeNote*)note {
    NSData* unencryptedData = [NSKeyedArchiver archivedDataWithRootObject:note];
    NSData* encryptedData = [BFCryptor AES128EncryptData:unencryptedData withKey:@"c2WQM88"];
    return encryptedData;
}

+(SafeNote*)decryptSafeNoteData:(NSData*)noteData {
    NSData* unencryptedData = [BFCryptor AES128DecryptData:noteData withKey:@"c2WQM88"];
    SafeNote* note = [NSKeyedUnarchiver unarchiveObjectWithData:unencryptedData];
    if (note) {
        return note;
    }
    else {
        NSLog(@"Unable to decrypt SafeNote");
        return [[SafeNote alloc] init];
    }
}


@end
