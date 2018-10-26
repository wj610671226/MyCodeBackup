//
//  MIT License
//
//  Copyright (c) 2015 Bob McCune http://bobmccune.com/
//  Copyright (c) 2015 TapHarmonic, LLC http://tapharmonic.com/
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

#import "THMovieWriter.h"
#import <AVFoundation/AVFoundation.h>
#import "THContextManager.h"
#import "THFunctions.h"
#import "THPhotoFilters.h"
#import "THNotifications.h"

static NSString *const THVideoFilename = @"movie.mov";

@interface THMovieWriter ()

@property (strong, nonatomic) AVAssetWriter *assetWriter;
@property (strong, nonatomic) AVAssetWriterInput *assetWriterVideoInput;
@property (strong, nonatomic) AVAssetWriterInput *assetWriterAudioInput;
@property (strong, nonatomic)
    AVAssetWriterInputPixelBufferAdaptor *assetWriterInputPixelBufferAdaptor;

@property (strong, nonatomic) dispatch_queue_t dispatchQueue;

@property (weak, nonatomic) CIContext *ciContext;
@property (nonatomic) CGColorSpaceRef colorSpace;
@property (strong, nonatomic) CIFilter *activeFilter;

@property (strong, nonatomic) NSDictionary *videoSettings;
@property (strong, nonatomic) NSDictionary *audioSettings;

@property (nonatomic) BOOL firstSample;

@end

@implementation THMovieWriter

- (id)initWithVideoSettings:(NSDictionary *)videoSettings
			  audioSettings:(NSDictionary *)audioSettings
              dispatchQueue:(dispatch_queue_t)dispatchQueue {

	self = [super init];
	if (self) {

        // Listing 8.13
        _videoSettings = videoSettings;
        _audioSettings = audioSettings;
        _dispatchQueue = dispatchQueue;
        
        //
        _ciContext = [THContextManager sharedInstance].ciContext;
        _colorSpace = CGColorSpaceCreateDeviceRGB();
        _activeFilter = [THPhotoFilters defaultFilter];
        _firstSample = YES;
        
        // 监听用户切换筛选器列表
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(filterChanged:) name:THFilterSelectionChangedNotification object:nil];
    }
	return self;
}

- (void)dealloc {
    // Listing 8.13
    CGColorSpaceRelease(_colorSpace);
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)filterChanged:(NSNotification *)notification {

    // Listing 8.13
    self.activeFilter = [notification.object copy];
}

- (void)startWriting {

    // Listing 8.14
    dispatch_async(self.dispatchQueue, ^{
        NSError * error = nil;
        NSString * fileType = AVFileTypeQuickTimeMovie;
        // 创建AVAssetWriter实例
        self.assetWriter = [AVAssetWriter assetWriterWithURL:[self outputURL] fileType:fileType error:&error];
        if (!self.assetWriter || error) {
            NSLog(@"startWriting error");
            return ;
        }
        
        // 创建AVAssetWriterInput输入
        self.assetWriterVideoInput = [[AVAssetWriterInput alloc] initWithMediaType:AVMediaTypeVideo outputSettings:self.videoSettings];
        // 设置为yes指定输入进行实时性优化
        self.assetWriterVideoInput.expectsMediaDataInRealTime = YES;
        
        // 固定屏幕为垂直方向
        UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
        self.assetWriterVideoInput.transform = THTransformForDeviceOrientation(orientation);
        
        // 配置
        NSDictionary * attributes = @{
                                      (id)kCVPixelBufferPixelFormatTypeKey: @(kCVPixelFormatType_32BGRA),
                                      (id)kCVPixelBufferWidthKey: self.videoSettings[AVVideoWidthKey],
                                      (id)kCVPixelBufferHeightKey: self.videoSettings[AVVideoHeightKey],
                                      (id)kCVPixelFormatOpenGLESCompatibility: (id)kCFBooleanTrue
                                      };
        
        // 创建AVAssetWriterInputPixelBufferAdaptor， 他提供一个优化的CVPixelBufferPool
        self.assetWriterInputPixelBufferAdaptor = [[AVAssetWriterInputPixelBufferAdaptor alloc] initWithAssetWriterInput:self.assetWriterVideoInput sourcePixelBufferAttributes:attributes];
        
        // 将视频输入添加到资源写入器
        if ([self.assetWriter canAddInput:self.assetWriterVideoInput]) {
            [self.assetWriter addInput:self.assetWriterVideoInput];
        } else {
            NSLog(@"add video input error");
            return;
        }
        
        // 将音频输入添加到资源写入器
        self.assetWriterAudioInput = [[AVAssetWriterInput alloc] initWithMediaType:AVMediaTypeAudio outputSettings:self.audioSettings];
        self.assetWriterAudioInput.expectsMediaDataInRealTime = YES;
        
        //
        if ([self.assetWriter canAddInput:self.assetWriterAudioInput]) {
            [self.assetWriter addInput:self.assetWriterAudioInput];
        } else {
            NSLog(@"add audio input error");
            return;
        }
        
        // 开始附加样本数据
        self.isWriting = YES;
        self.firstSample = YES;
    });
}

// 添加从捕捉输入得到的CMSampleBuffer
- (void)processSampleBuffer:(CMSampleBufferRef)sampleBuffer {

    // Listing 8.15
    if (!self.isWriting) {
        return;
    }
    
    // CMSampleBufferGetFormatDescription可以处理音频和视频两类样本数据
    CMFormatDescriptionRef formatDesc = CMSampleBufferGetFormatDescription(sampleBuffer);
    
    CMMediaType mdeiaType = CMFormatDescriptionGetMediaType(formatDesc);
    if (mdeiaType == kCMMediaType_Video) {
        CMTime timestamp = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
        // 第一次启动会话
        if (self.firstSample) {
            if ([self.assetWriter startWriting]) {
                [self.assetWriter startSessionAtSourceTime:timestamp];
            } else {
                NSLog(@"start writing error");
            }
            self.firstSample = NO;
        }
        
        CVPixelBufferRef outputRenderBuffer = NULL;
        CVPixelBufferPoolRef pixelBufferPool = self.assetWriterInputPixelBufferAdaptor.pixelBufferPool;
        // 从像素buffer适配池中创建一个空的CVPixelBuffer,使用该像素buffer渲染筛选好的视频帧的输出
        OSStatus err = CVPixelBufferPoolCreatePixelBuffer(NULL, pixelBufferPool, &outputRenderBuffer);
        if (err) {
            NSLog(@"unable to obtain a pixel buffer from the pool");
            return;
        }
        // 获取视频样本数据CVPixelBufferRef
        CVPixelBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
        CIImage * sourceImage = [CIImage imageWithCVPixelBuffer:imageBuffer];
        [self.activeFilter setValue:sourceImage forKey:kCIInputImageKey];
        CIImage * filteredImage = self.activeFilter.outputImage;
        if (!filteredImage) {
            filteredImage = sourceImage;
        }
        // 将筛选好的CIImage的输出渲染到outputRenderBuffer
        [self.ciContext render:filteredImage toCVPixelBuffer:outputRenderBuffer bounds:filteredImage.extent colorSpace:self.colorSpace];
    
        if (self.assetWriterVideoInput.readyForMoreMediaData) {
            // 将数据附加到assetWriterInputPixelBufferAdaptor中处理
            if (![self.assetWriterInputPixelBufferAdaptor appendPixelBuffer:outputRenderBuffer withPresentationTime:timestamp]) {
                NSLog(@"error appending pixel buffer");
            }
        }
        CVPixelBufferRelease(outputRenderBuffer);
    } else if (!self.firstSample && mdeiaType == kCMMediaType_Audio) {
        // 音频处理
        if (self.assetWriterVideoInput.isReadyForMoreMediaData) {
            if (![self.assetWriterAudioInput appendSampleBuffer:sampleBuffer]) {
                NSLog(@"error appending audio sample buffer");
            }
        }
    }
}

- (void)stopWriting {

    // Listing 8.16
    // 不在处理样本数据
    self.isWriting = NO;
    dispatch_async(self.dispatchQueue, ^{
        // 停止写入会话
        [self.assetWriter finishWritingWithCompletionHandler:^{
            if (self.assetWriter.status == AVAssetWriterStatusCompleted) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSURL * fileURL = [self.assetWriter outputURL];
                    [self.delegate didWriteMovieAtURL:fileURL];
                });
            } else {
                NSLog(@"failed to write movie %@", self.assetWriter.error);
            }
        }];
    });
}

- (NSURL *)outputURL {
    // 定义url 配置AVAssetWriter
    NSString *filePath =
        [NSTemporaryDirectory() stringByAppendingPathComponent:THVideoFilename];
    NSURL *url = [NSURL fileURLWithPath:filePath];
    if ([[NSFileManager defaultManager] fileExistsAtPath:url.path]) {
        [[NSFileManager defaultManager] removeItemAtURL:url error:nil];
    }
    return url;
}

@end
