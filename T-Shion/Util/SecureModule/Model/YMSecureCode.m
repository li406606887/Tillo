//
//  YMSecureCode.m
//  SecureTest
//
//  Created by mac on 2019/4/9.
//  Copyright © 2019 mac. All rights reserved.
//

#import "YMSecureCode.h"
#import <UIKit/UIImage.h>
#import <AxolotlKit/NSData+keyVersionByte.h>
#import <CommonCrypto/CommonDigest.h>
#ifdef AilloTest
#import <AilloTest-Swift.h>
#else
#import <AilloRelease-Swift.h>
#endif

static uint32_t const YMFingerprintHashingVersion = 0;
static uint32_t const YMFingerprintScannableFormatVersion = 1;
static uint32_t const YMFingerprintDefaultHashIterations = 5200;

@interface YMSecureCode ()

@property (nonatomic, readonly) NSUInteger hashIterations;
@property (nonatomic, readonly) NSString *text;
@property (nonatomic, readonly) NSData *myFingerprintData;
@property (nonatomic, readonly) NSData *theirFingerprintData;
@property (nonatomic, readonly) NSString *theirName;

@end

@implementation YMSecureCode

+ (instancetype)fingerprintWithMyStableId:(NSString *)myStableId
                            myIdentityKey:(NSData *)myIdentityKeyWithoutKeyType
                            theirStableId:(NSString *)theirStableId
                         theirIdentityKey:(NSData *)theirIdentityKeyWithoutKeyType
                                theirName:(NSString *)theirName
{
    return [[self alloc] initWithMyStableId:myStableId myIdentityKey:myIdentityKeyWithoutKeyType theirStableId:theirStableId theirIdentityKey:theirIdentityKeyWithoutKeyType theirName:theirName];
}

- (instancetype)initWithMyStableId:(NSString *)myStableId myIdentityKey:(NSData *)myIdentityKeyWithoutKeyType theirStableId:(NSString *)theirStableId theirIdentityKey:(NSData *)theirIdentityKeyWithoutKeyType theirName:(NSString *)theirName {
    if (self = [super init]) {
        _myStableIdData = [myStableId dataUsingEncoding:NSUTF8StringEncoding];
        _myIdentityKey = [myIdentityKeyWithoutKeyType prependKeyType];
        _theirStableId = theirStableId;
        _theirStableIdData = [theirStableId dataUsingEncoding:NSUTF8StringEncoding];
        _theirIdentityKey = [theirIdentityKeyWithoutKeyType prependKeyType];
        _theirName = theirName;
        _hashIterations = YMFingerprintDefaultHashIterations;
        
        _myFingerprintData = [self dataForStableId:_myStableIdData publicKey:_myIdentityKey];
        _theirFingerprintData = [self dataForStableId:_theirStableIdData publicKey:_theirIdentityKey];
    }
    return self;
}

- (BOOL)matchesLogicalFingerprintsData:(NSData *)data {
    NSError *error = nil;
    FingerprintProtoLogicalFingerprints *_Nullable logicalFingerprints;
    logicalFingerprints = [FingerprintProtoLogicalFingerprints parseData:data error:&error];
    if (!logicalFingerprints || error) {
        NSLog(@"fingerprint failure: %@", error);
        return NO;
    }
    
    if (logicalFingerprints.version < YMFingerprintScannableFormatVersion) {
        NSLog(@"Verification failed. They're running an old version.");
        return NO;
    }
    
    if (logicalFingerprints.version > YMFingerprintScannableFormatVersion) {
        NSLog(@"Verification failed. We're running an old version.");
        return NO;
    }
    
    // Their local is *our* remote.
    FingerprintProtoLogicalFingerprint *localFingerprint = logicalFingerprints.remoteFingerprint;
    FingerprintProtoLogicalFingerprint *remoteFingerprint = logicalFingerprints.localFingerprint;
    
    if (![remoteFingerprint.identityData isEqual:[self scannableData:self.theirFingerprintData]]) {
        NSLog(@"Verification failed. We have the wrong fingerprint for them");
        return NO;
    }
    
    if (![localFingerprint.identityData isEqual:[self scannableData:self.myFingerprintData]]) {
        NSLog(@"Verification failed. They have the wrong fingerprint for us");
        return NO;
    }
    
    NSLog(@"Verification Succeeded.");
    return YES;
}

- (NSString *)text
{
    NSString *myDisplayString = [self stringForFingerprintData:self.myFingerprintData];
    NSString *theirDisplayString = [self stringForFingerprintData:self.theirFingerprintData];
    
    if ([theirDisplayString compare:myDisplayString] == NSOrderedAscending) {
        return [NSString stringWithFormat:@"%@%@", theirDisplayString, myDisplayString];
    } else {
        return [NSString stringWithFormat:@"%@%@", myDisplayString, theirDisplayString];
    }
}

/**
 * Formats numeric fingerprint, 3 lines in groups of 5 digits.
 */
- (NSString *)displayableText
{
    NSString *input = self.text;
    
    NSMutableArray<NSString *> *lines = [NSMutableArray new];
    
    NSUInteger lineLength = self.text.length / 3;
    for (uint i = 0; i < 3; i++) {
        NSString *line = [input substringWithRange:NSMakeRange(i * lineLength, lineLength)];
        
        NSMutableArray<NSString *> *chunks = [NSMutableArray new];
        for (uint i = 0; i < line.length / 5; i++) {
            NSString *nextChunk = [line substringWithRange:NSMakeRange(i * 5, 5)];
            [chunks addObject:nextChunk];
        }
        [lines addObject:[chunks componentsJoinedByString:@" "]];
    }
    
    return [lines componentsJoinedByString:@"\n"];
}


- (NSData *)dataFromShort:(uint32_t)aShort
{
    uint8_t bytes[] = {
        ((uint8_t)(aShort & 0xFF00) >> 8),
        (uint8_t)(aShort & 0x00FF)
    };
    
    return [NSData dataWithBytes:bytes length:2];
}

/**
 * An identifier for a mutable public key, belonging to an immutable identifier (stableId).
 *
 * This method is intended to be somewhat expensive to produce in order to be brute force adverse.
 *
 * @param stableIdData
 *      Immutable global identifier e.g. Signal Identifier, an e164 formatted phone number encoded as UTF-8 data
 * @param publicKey
 *      The current public key for <stableId>
 * @return
 *      All-number textual representation
 */
- (NSData *)dataForStableId:(NSData *)stableIdData publicKey:(NSData *)publicKey
{
    NSData *versionData = [self dataFromShort:YMFingerprintHashingVersion];
    NSMutableData *hash = [versionData mutableCopy];
    [hash appendData:publicKey];
    [hash appendData:stableIdData];
    
    NSMutableData *_Nullable digestData = [[NSMutableData alloc] initWithLength:CC_SHA512_DIGEST_LENGTH];
    if (!digestData) {
        @throw [NSException exceptionWithName:NSGenericException reason:@"Couldn't allocate buffer." userInfo:nil];
    }
    for (int i = 0; i < self.hashIterations; i++) {
        [hash appendData:publicKey];
        
        if (hash.length >= UINT32_MAX) {
            @throw [NSException exceptionWithName:@"Oversize Data" reason:@"Oversize hash." userInfo:nil];
        }
        
        CC_SHA512(hash.bytes, (uint32_t)hash.length, digestData.mutableBytes);
        // TODO get rid of this loop-allocation
        hash = [digestData mutableCopy];
    }
    
    return [hash copy];
}


- (NSString *)stringForFingerprintData:(NSData *)data
{
    return [NSString stringWithFormat:@"%@%@%@%@%@%@",
            [self encodedChunkFromData:data offset:0],
            [self encodedChunkFromData:data offset:5],
            [self encodedChunkFromData:data offset:10],
            [self encodedChunkFromData:data offset:15],
            [self encodedChunkFromData:data offset:20],
            [self encodedChunkFromData:data offset:25]];
}

- (NSString *)encodedChunkFromData:(NSData *)data offset:(uint)offset
{
    uint8_t fiveBytes[5];
    [data getBytes:fiveBytes range:NSMakeRange(offset, 5)];
    
    int chunk = [self uint64From5Bytes:fiveBytes] % 100000;
    return [NSString stringWithFormat:@"%05d", chunk];
}

- (int64_t)uint64From5Bytes:(uint8_t[])bytes
{
    int64_t result = ((bytes[0] & 0xffLL) << 32) |
    ((bytes[1] & 0xffLL) << 24) |
    ((bytes[2] & 0xffLL) << 16) |
    ((bytes[3] & 0xffLL) <<  8) |
    ((bytes[4] & 0xffLL));
    
    return result;
}

- (NSData *)scannableData:(NSData *)data
{
    return [data subdataWithRange:NSMakeRange(0, 32)];
}

- (nullable UIImage *)image
{
    FingerprintProtoLogicalFingerprintBuilder *remoteFingerprintBuilder =
    [FingerprintProtoLogicalFingerprint builderWithIdentityData:[self scannableData:self.theirFingerprintData]];
    NSError *error;
    FingerprintProtoLogicalFingerprint *_Nullable remoteFingerprint =
    [remoteFingerprintBuilder buildAndReturnError:&error];
    if (!remoteFingerprint || error) {
        NSLog(@"could not build proto: %@", error);
        return nil;
    }
    
    FingerprintProtoLogicalFingerprintBuilder *localFingerprintBuilder =
    [FingerprintProtoLogicalFingerprint builderWithIdentityData:[self scannableData:self.myFingerprintData]];
    FingerprintProtoLogicalFingerprint *_Nullable localFingerprint =
    [localFingerprintBuilder buildAndReturnError:&error];
    if (!localFingerprint || error) {
        NSLog(@"could not build proto: %@", error);
        return nil;
    }
    
    FingerprintProtoLogicalFingerprintsBuilder *logicalFingerprintsBuilder =
    [FingerprintProtoLogicalFingerprints builderWithVersion:YMFingerprintScannableFormatVersion
                                           localFingerprint:localFingerprint
                                          remoteFingerprint:remoteFingerprint];
    
    // Build ByteMode QR (Latin-1 encodable data)
    NSData *_Nullable fingerprintData = [logicalFingerprintsBuilder buildSerializedDataAndReturnError:&error];
    if (!fingerprintData || error) {
        NSLog(@"could not serialize proto: %@", error);
        return nil;
    }
    
    NSLog(@"Building fingerprint with data: %@", fingerprintData);
    
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    [filter setDefaults];
    [filter setValue:fingerprintData forKey:@"inputMessage"];
    [filter setValue:@"H" forKey:@"inputCorrectionLevel"];
    
    CIImage *ciImage = [filter outputImage];
    if (!ciImage) {
        NSLog(@"Failed to create QR image from fingerprint text: %@", self.text);
        return nil;
    }
    if (self.qrCodeSize.width > 1)
    {
        CGFloat scale = self.qrCodeSize.width / ciImage.extent.size.width;
        ciImage = [ciImage imageByApplyingTransform:CGAffineTransformMakeScale(scale, scale)];
    }
    // UIImages backed by a CIImage won't render without antialiasing, so we convert the backign image to a CGImage,
    // which can be scaled crisply.
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef cgImage = [context createCGImage:ciImage fromRect:ciImage.extent];
    UIImage *qrImage = [UIImage imageWithCGImage:cgImage];
    CGImageRelease(cgImage);
    
    return qrImage;
}

@end
