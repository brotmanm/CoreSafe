//
//  Password.m
//  CoreSafe
//
//  Created by Main on 12/25/16.
//  Copyright © 2016 Matt Brotman. All rights reserved.
//

#import "Password.h"
#import "BFKit.h"

@interface Password ()

@property NSString* string;
@property BOOL valid;

@end

@implementation Password

-(Password*)init {
    self = [super init];
    if (self){
        self.string = @"";
        self.valid = NO;
    }
    return self;
}

-(Password*)initWithString:(NSString*)passString {
    self = [super init];
    if (self){
        self.string = passString;
        if (self.string.length > 2){
            self.valid = YES;
        }
    }
    
    return self;
}

-(void)saveWithKey:(NSString*)defaultsKey {
    NSData* encryptedPasswordData = [BFCryptor AES128EncryptString:self.string withKey:@"c2WQM88"];
    
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:encryptedPasswordData forKey:defaultsKey];
    [defaults synchronize];
}

-(NSString*)stringRepresentation {
    return self.string;
}

-(BOOL)isValid {
    return self.valid;
}

-(void)update:(NSString*)newPassString {
    self.string = newPassString;
    if (self.string.length > 2){
        self.valid = YES;
    }
}

-(NSString*)strength {
    PasswordStrengthLevel s = [BFPassword checkPasswordStrength:self.string];
    NSString* str;
    switch (s) {
        case PasswordStrengthLevelVeryWeak:
            str = @"very weak";
            break;
        case PasswordStrengthLevelWeak:
            str = @"weak";
            break;
        case PasswordStrengthLevelAverage:
            str = @"average";
            break;
        case PasswordStrengthLevelStrong:
            str = @"strong";
            break;
        case PasswordStrengthLevelVeryStrong:
            str = @"very strong";
            break;
        case PasswordStrengthLevelSecure:
            str = @"secure";
            break;
        case PasswordStrengthLevelVerySecure:
            str = @"very secure";
            break;
    }
    
    return str;
}

@end
