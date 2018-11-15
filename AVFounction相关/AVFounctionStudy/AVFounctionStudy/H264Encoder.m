//
//  H264Encoder.m
//  AVFounctionStudy
//
//  Created by mac on 2018/11/1.
//  Copyright © 2018 mac. All rights reserved.
//

#import "H264Encoder.h"
#import <VideoToolbox/VideoToolbox.h>

@interface H264Encoder()
@property(nonatomic, assign)int frameID;
@property(nonatomic, assign)VTCompressionSessionRef cEncodeingSession;
@property (nonatomic, strong) NSFileHandle * videoFileHandle;
@property (nonatomic, strong) dispatch_queue_t encodeQueue;
@end

@implementation H264Encoder

- (instancetype)init
{
    self = [super init];
    if (self) {
        dispatch_sync(self.encodeQueue, ^{
            [self initVideoToolbox];
        });
    }
    return self;
}

- (void)stopEncode
{
    VTCompressionSessionCompleteFrames(self.cEncodeingSession, kCMTimeInvalid);
    VTCompressionSessionInvalidate(self.cEncodeingSession);
    CFRelease(self.cEncodeingSession);
    self.cEncodeingSession = NULL;
    [self.videoFileHandle closeFile];
    self.videoFileHandle = NULL;
}


- (void)encodeH264:(CMSampleBufferRef)sampleBuffer {
    dispatch_sync(self.encodeQueue, ^{
        NSLog(@"H264编码中...");
        // 拿到每一帧的未编码的数据
        CVImageBufferRef imageBuffer = (CVImageBufferRef)CMSampleBufferGetImageBuffer(sampleBuffer);
        // 根据当前的帧数创建帧时间
        CMTime ptime = CMTimeMake(self.frameID ++, 1000);
        // 编码准备
        VTEncodeInfoFlags flags; // 0 同步编码 1表示异步编码
        OSStatus status = VTCompressionSessionEncodeFrame(self.cEncodeingSession, imageBuffer, ptime, kCMTimeInvalid, NULL, NULL, &flags);
        if (status != noErr) {
            VTCompressionSessionInvalidate(self.cEncodeingSession);
            CFRelease(self.cEncodeingSession);
            self.cEncodeingSession = NULL;
            return;
        } else {
            NSLog(@"encode error status = %d", (int)status);
        }
    });
}

- (void)initVideoToolbox {
    // 用于记录是第几帧数据
    self.frameID = 0;
    // 捕捉视频的宽高
    int width = [UIScreen mainScreen].bounds.size.width;
    int height = [UIScreen mainScreen].bounds.size.height;
    // 创建一个编码器 didCompressH264编码回调函数
    OSStatus status = VTCompressionSessionCreate(NULL, width, height, kCMVideoCodecType_H264,
                                                 NULL, NULL, NULL,
                                                 didCompressH264,
                                                 (__bridge void*)self, &_cEncodeingSession);
    
    if (status != 0) {
        NSLog(@"创建编码器失败 status = %d", (int)status);
        return ;
    }
    
    // 设置实施编码输出
    VTSessionSetProperty(self.cEncodeingSession, kVTCompressionPropertyKey_RealTime, kCFBooleanTrue);
    VTSessionSetProperty(self.cEncodeingSession, kVTCompressionPropertyKey_ProfileLevel, kVTProfileLevel_H264_Baseline_AutoLevel);
    
    // 设置关键帧（GOPsize）间隔
    int frameInterval = 30;
    CFNumberRef frameIntervalRef = CFNumberCreate(kCFAllocatorDefault, kCFNumberIntType, &frameInterval);
    VTSessionSetProperty(self.cEncodeingSession, kVTCompressionPropertyKey_MaxKeyFrameInterval, frameIntervalRef);
    
    // 设置期望帧率，不是实际帧率
    int fps = 30;
    CFNumberRef fpsRef = CFNumberCreate(kCFAllocatorDefault, kCFNumberIntType, &fps);
    VTSessionSetProperty(self.cEncodeingSession, kVTCompressionPropertyKey_ExpectedFrameRate, fpsRef);
    
    // 设置码率，单位是byte （编码效率, 码率越高,则画面越清晰, 如果码率较低会引起马赛克 --> 码率高有利于还原原始画面,但是也不利于传输）
    int bigRate = width * height * 3 * 4 * 8;
    CFNumberRef bigRateRef = CFNumberCreate(kCFAllocatorDefault, kCFNumberSInt32Type, &bigRate);
    VTSessionSetProperty(self.cEncodeingSession, kVTCompressionPropertyKey_AverageBitRate, bigRateRef);
    
    int bigRateLimit = width * height * 3 * 4;
    CFNumberRef bigRateLimitRef = CFNumberCreate(kCFAllocatorDefault, kCFNumberSInt32Type, &bigRateLimit);
    VTSessionSetProperty(self.cEncodeingSession, kVTCompressionPropertyKey_DataRateLimits, bigRateLimitRef);
    
    // 开始准备编码
    VTCompressionSessionPrepareToEncodeFrames(self.cEncodeingSession);
}

#pragma mark - 编码回调
// 编码完成回调
void didCompressH264(void *outputCallbackRefCon, void *sourceFrameRefCon, OSStatus status, VTEncodeInfoFlags infoFlags, CMSampleBufferRef sampleBuffer)
{
    // CMSampleBufferRef  包括  CMTime(时间戳) + CMVideoGormatDesc(图像存储方式) + CMBlockBuffer（编码后的数据）
    // 获取h264编码的数据 sampleBuffer
    
    NSLog(@"didCompressH264: status = %d  infoFlags = %u", (int)status, (unsigned int)infoFlags);
    // 状态错误
    if (status != 0) {
        return;
    }
    
    // 没准备好
    if (!CMSampleBufferDataIsReady(sampleBuffer)) {
        NSLog(@"didCompressH264 data is not ready");
        return;
    }
    
    // 需要调用oc的方法
    H264Encoder * self = (__bridge H264Encoder*)outputCallbackRefCon;
    
    // 判断当前帧是否为关键帧
    bool keyFrame = !CFDictionaryContainsKey(CFArrayGetValueAtIndex(CMSampleBufferGetSampleAttachmentsArray(sampleBuffer, true), 0), kCMSampleAttachmentKey_NotSync);
    if (keyFrame) {
        // sps 序列参数集  pps 图像参数集    h264
        // 获取图像编码后的存储信息
        CMFormatDescriptionRef format = CMSampleBufferGetFormatDescription(sampleBuffer);
        // 获取 sps 内容、大小、长度
        size_t spsCount, spsLength;
        const uint8_t *spsSet;
        OSStatus spsStatus = CMVideoFormatDescriptionGetH264ParameterSetAtIndex(format,
                                                                                0,
                                                                                &spsSet,
                                                                                &spsLength,
                                                                                &spsCount,
                                                                                0);
        if (spsStatus == noErr) {
            // 获取pps信息
            size_t ppsCount, ppsLength;
            const uint8_t *ppsSet;
            OSStatus ppsStatus = CMVideoFormatDescriptionGetH264ParameterSetAtIndex(format,
                                                                                    1,
                                                                                    &ppsSet,
                                                                                    &ppsLength,
                                                                                    &ppsCount,
                                                                                    0);
            if (ppsStatus == noErr) {
                
                // 将sps pps转成 NSData 写入文件
                NSData * spsData = [NSData dataWithBytes:spsSet length:spsLength];
                NSData * ppsData = [NSData dataWithBytes:ppsSet length:ppsLength];
                
                if (self) {
                    [self gotSpsPps:spsData pps:ppsData];
                }
            }
        }
    }
    
    // 获取数据块
    CMBlockBufferRef dataBuffer = CMSampleBufferGetDataBuffer(sampleBuffer);
    size_t length, totleLength;
    char *dataPointer;
    OSStatus blockStatus = CMBlockBufferGetDataPointer(dataBuffer,
                                                       0,
                                                       &length,
                                                       &totleLength,
                                                       &dataPointer);
    if (blockStatus == noErr) {
        size_t bufferOfSet = 0;
        // 返回的nalu数据前四个字节不是0001的startcode，而是大端模式的帧长度length
        static const int AVCCHeaderLength = 4;
        // 获取nalu数据
        while (bufferOfSet < totleLength - AVCCHeaderLength) {
            UInt32 NALUnitLength = 0;
            // Read the NAL unit length
            memcpy(&NALUnitLength, dataPointer + bufferOfSet, AVCCHeaderLength);
            
            // 大端模式 转换为 系统端模式
            NALUnitLength = CFSwapInt32BigToHost(NALUnitLength);
            
            // 获取nalu数据
            NSData * data = [[NSData alloc] initWithBytes:(dataPointer + AVCCHeaderLength + bufferOfSet) length:NALUnitLength];
            // 将 nalu数据 写入文件
            [self gotEncodedData:data isKeyFrame:keyFrame];
            
            // 移动偏移量
            bufferOfSet += AVCCHeaderLength + NALUnitLength;
        }
    }
}


- (void)gotSpsPps:(NSData*)sps pps:(NSData*)pps
{
    NSLog(@"gotSpsPps %lu - %lu", (unsigned long)sps.length, (unsigned long)pps.length);
    const char bytres[] = "\x00\x00\x00\x01";
    size_t length = (sizeof bytres) - 1;
    NSData * byteHeader = [NSData dataWithBytes:bytres length:length];
    
    [self.videoFileHandle writeData:byteHeader];
    [self.videoFileHandle writeData:sps];
    [self.videoFileHandle writeData:byteHeader];
    [self.videoFileHandle writeData:pps];
}

- (void)gotEncodedData:(NSData*)data isKeyFrame:(BOOL)isKeyFrame
{
    NSLog(@"gotEncodedData = %lu", (unsigned long)data.length);
    
    if (self.videoFileHandle != NULL) {
        const char bytres[] = "\x00\x00\x00\x01";
        size_t length = (sizeof bytres) - 1;
        NSData * byteHeader = [NSData dataWithBytes:bytres length:length];
        [self.videoFileHandle writeData:byteHeader];
        [self.videoFileHandle writeData:data];
    }
}

#pragma mark - get
- (dispatch_queue_t)encodeQueue {
    if (!_encodeQueue) {
        _encodeQueue = dispatch_queue_create("encode_video_queue", DISPATCH_QUEUE_SERIAL);
    }
    return _encodeQueue;
}

- (NSFileHandle *)videoFileHandle {
    if (!_videoFileHandle) {
        NSString * filePath = [NSHomeDirectory() stringByAppendingPathComponent:@"/Documents/demo.h264"];
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
        BOOL createFile = [[NSFileManager defaultManager] createFileAtPath:filePath contents:nil attributes:nil];
        NSAssert(createFile, @"create video path error");
        _videoFileHandle = [NSFileHandle fileHandleForWritingAtPath:filePath];
    }
    return _videoFileHandle;
}
@end
