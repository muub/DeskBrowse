#import <Foundation/Foundation.h>

@interface NSData (NSDataExtension)

// Canonical Base32 encoding/decoding.
// decode
+ (NSData *) dataWithBase32String:(NSString *)base32;
// encode
- (NSString *) base32String;

@end