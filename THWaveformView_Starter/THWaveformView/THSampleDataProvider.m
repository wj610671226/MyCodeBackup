//
//  MIT License
//
//  Copyright (c) 2014 Bob McCune http://bobmccune.com/
//  Copyright (c) 2014 TapHarmonic, LLC http://tapharmonic.com/
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "THSampleDataProvider.h"

@implementation THSampleDataProvider

// 读取音频样本
+ (void)loadAudioSamplesFromAsset:(AVAsset *)asset
                  completionBlock:(THSampleDataCompletionBlock)completionBlock {
    
    // Listing 8.2
    NSString * tracks = @"tracks";
    // 异步载入资源
    [asset loadValuesAsynchronouslyForKeys:@[tracks] completionHandler:^{
        AVKeyValueStatus status = [asset statusOfValueForKey:tracks error:nil];
        NSData * sampleData = nil;
        if (status == AVKeyValueStatusLoaded) {
            // 从音频轨道中读取样本
            sampleData = [self readAudioSamplesFromAsset:asset];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completionBlock(sampleData);
        });
    }];
}

+ (NSData *)readAudioSamplesFromAsset:(AVAsset *)asset {

    // Listing 8.3
    NSError * error = nil;
    // 创建一个AVAssetReader实例读取AVAsset资源
    AVAssetReader * assetReader = [[AVAssetReader alloc] initWithAsset:asset error:&error];
    if (!assetReader) {
        NSLog(@"error asset = %@", error.localizedDescription);
        return nil;
    }
    // 获取资源的第一个轨道
    AVAssetTrack * track = [asset tracksWithMediaType:AVMediaTypeAudio].firstObject;
    // 读取音频的解压配置
    NSDictionary * outputSettings = @{
                                      AVFormatIDKey: @(kAudioFormatLinearPCM),
                                      AVLinearPCMIsBigEndianKey: @NO,
                                      AVLinearPCMIsFloatKey: @NO,
                                      AVLinearPCMBitDepthKey: @(16)
                                      };
    // 创建一个输出实例
    AVAssetReaderTrackOutput * trackOutput = [[AVAssetReaderTrackOutput alloc] initWithTrack:track outputSettings:outputSettings];
    [assetReader addOutput:trackOutput];
    [assetReader startReading];
    
    NSMutableData * sampleData = [NSMutableData data];
    while (assetReader.status == AVAssetReaderStatusReading) {
        CMSampleBufferRef sampleBuffer = [trackOutput copyNextSampleBuffer];
        // 从CMSampleBufferRef音频样本中获取CMBlockBufferRef
        if (sampleBuffer) {
            CMBlockBufferRef blockBufferRef = CMSampleBufferGetDataBuffer(sampleBuffer);
            size_t length = CMBlockBufferGetDataLength(blockBufferRef);
            SInt16 sampleBytes[length];
            CMBlockBufferCopyDataBytes(blockBufferRef, 0, length, sampleBytes);
            [sampleData appendBytes:sampleBytes length:length];
            CMSampleBufferInvalidate(sampleBuffer);
            CFRelease(sampleBuffer);
        }
    }
    
    if (assetReader.status == AVAssetReaderStatusCompleted) {
        return sampleData;
    } else {
        NSLog(@"failed to read audio samples from asset");
        return nil;
    }
    
}

@end
