//
//  AACEncoder.m
//  AVFounctionStudy
//
//  Created by mac on 2018/11/1.
//  Copyright © 2018 mac. All rights reserved.
//

#import "AACEncoder.h"
#import <AudioToolbox/AudioToolbox.h>

@interface AACEncoder()

@property (nonatomic) AudioConverterRef audioConverter; // 音频转换器
@property (nonatomic) uint8_t * aacBuffer;
@property (nonatomic) NSUInteger aacBufferSize;
@property (nonatomic) char * pcmBuffer;
@property (nonatomic) size_t pcmBufferSize;
@property(nonatomic) dispatch_queue_t encoderQueue; // 编码队列
@property (nonatomic, strong) NSFileHandle * audioFileHandle;

@end

@implementation AACEncoder


- (NSFileHandle *)audioFileHandle {
    if (!_audioFileHandle) {
        NSString * filePath = [NSHomeDirectory() stringByAppendingPathComponent:@"/Documents/demo.aac"];
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
        BOOL createFile = [[NSFileManager defaultManager] createFileAtPath:filePath contents:nil attributes:nil];
        NSAssert(createFile, @"create audio path error");
        _audioFileHandle = [NSFileHandle fileHandleForWritingAtPath:filePath];
    }
    return _audioFileHandle;
}

- (void)dealloc {
    AudioConverterDispose(_audioConverter);
    free(_aacBuffer);
}

- (id)init {
    if (self = [super init]) {
        _encoderQueue = dispatch_queue_create("aac encode queue", DISPATCH_QUEUE_SERIAL);
        _audioConverter = NULL;
        _pcmBufferSize = 0;
        _pcmBuffer = NULL;
        _aacBufferSize = 1024;
        _aacBuffer = malloc(_aacBufferSize * sizeof(uint8_t));
        memset(_aacBuffer, 0, _aacBufferSize);
    }
    return self;
}


- (void)stopEncodeAudio {
    [self.audioFileHandle closeFile];
    self.audioFileHandle = NULL;
}

// 配置编码参数
- (void)setupEncoderFromSampleBuffer:(CMSampleBufferRef)sampleBuffer {
    
    NSLog(@"开始配置编码参数。。。。");
    
    // 获取原音频声音格式设置
    AudioStreamBasicDescription inAudioStreamBasicDescription = *CMAudioFormatDescriptionGetStreamBasicDescription((CMAudioFormatDescriptionRef)CMSampleBufferGetFormatDescription(sampleBuffer));
    AudioStreamBasicDescription outAudioStreamBasicDescription = {0};
    
    // 采样率
    outAudioStreamBasicDescription.mSampleRate = inAudioStreamBasicDescription.mSampleRate;
    // 格式  kAudioFormatMPEG4AAC  = 'aac' ,
    outAudioStreamBasicDescription.mFormatID = kAudioFormatMPEG4AAC;
    // 标签格式 无损编码
    outAudioStreamBasicDescription.mFormatFlags = kMPEG4Object_AAC_LC;
    // 每个Packet 的 Bytes 数量 0:动态大小格
    outAudioStreamBasicDescription.mBytesPerPacket = 0;
    // 每个Packet的帧数量，设置一个较大的固定值 1024
    outAudioStreamBasicDescription.mFramesPerPacket = 1024;
    // 每帧的Bytes数量
    outAudioStreamBasicDescription.mBytesPerFrame = 0;
    // 1 单声道 2: 立体声
    outAudioStreamBasicDescription.mChannelsPerFrame = 1;
    // 语言每采样点占用位数
    outAudioStreamBasicDescription.mBitsPerChannel = 0;
    // 保留参数（对齐当时）
    outAudioStreamBasicDescription.mReserved = 0;
    
    // 获取编码器
    AudioClassDescription * description = [self getAudioClassDescriptionWithType:kAudioFormatMPEG4AAC fromManufacturer:kAppleSoftwareAudioCodecManufacturer];
    
    // 创建编码器
    /*
     inAudioStreamBasicDescription 传入源音频格式
     outAudioStreamBasicDescription 目标音频格式
     第三个参数：传入音频编码器的个数
     description 传入音频编码器的描述
     */
    OSStatus status = AudioConverterNewSpecific(&inAudioStreamBasicDescription, &outAudioStreamBasicDescription, 1, description, &_audioConverter);
    if (status != 0) {
        NSLog(@"创建编码器失败");
    }
    
}


// 获取编码器
- (AudioClassDescription *)getAudioClassDescriptionWithType:(UInt32)type
                                           fromManufacturer:(UInt32)manufacturer
{
    NSLog(@"开始获取编码器。。。。");
    // 选择aac编码
    static AudioClassDescription desc;
    UInt32 encoderS = type;
    OSStatus status;
    UInt32 size;
    /*
     kAudioFormatProperty_Encoders 编码ID
     编码说明大小
     编码说明
     属性当前值的大小
     */
    status = AudioFormatGetPropertyInfo(kAudioFormatProperty_Encoders, sizeof(encoderS), &encoderS, &size);
    if (status) {
        NSLog(@"编码aac错误");
        return nil;
    }
    
    // 计算编码器的个数
    unsigned int count = size / sizeof(AudioClassDescription);
    
    // 定义编码器数组
    AudioClassDescription description[count];
    
    status = AudioFormatGetProperty(kAudioFormatProperty_Encoders, sizeof(encoderS), &encoderS, &size, description);
    
    for (unsigned int i = 0; i < count; i++) {
        if (type == description[i].mSubType && manufacturer == description[i].mManufacturer) {
            // 拷贝编码器到desc
            memcpy(&desc, &description[i], sizeof(desc));
            NSLog(@"找到aac编码器");
            return &desc;
        }
    }
    
    return nil;
}



// 回调函数
OSStatus inInputDataProc(AudioConverterRef inAudioConverter, UInt32 *ioNumberDataPackets, AudioBufferList *ioData, AudioStreamPacketDescription **outDataPacketDescription, void *inUserData)
{
    // 编码器
    AACEncoder *encoder = (__bridge AACEncoder *) inUserData;
    
    // 编码包的数据
    UInt32 requestPackes = *ioNumberDataPackets;
    // 将ioData填充到缓冲区
    size_t cp = [encoder copyPCMSamplesIntoBuffer:ioData];
    if (cp < requestPackes) {
        *ioNumberDataPackets = 0; // 清空
        return -1;
    }
    
    *ioNumberDataPackets = 1;
    return noErr;
}


// pcm -> 缓冲区
- (size_t)copyPCMSamplesIntoBuffer:(AudioBufferList*)ioData {
    // 获取pcm大小
    size_t os = _pcmBufferSize;
    if (!_pcmBufferSize) {
        return 0;
    }
    
    ioData->mBuffers[0].mData = _pcmBuffer;
    ioData->mBuffers[0].mDataByteSize = (int)_pcmBufferSize;
    // 清空
    _pcmBuffer = NULL;
    _pcmBufferSize = 0;
    return os;
}


// 编码数据
- (void)encodeAudioSampleBuffer:(CMSampleBufferRef)sampleBuffer {
    
    CFRetain(sampleBuffer);
    dispatch_sync(_encoderQueue, ^{
        if (!self.audioConverter) {
            // 配置编码参数
            [self setupEncoderFromSampleBuffer:sampleBuffer];
        }
        
        // 获取CMBlockBufferRef
        CMBlockBufferRef blockBuffer = CMSampleBufferGetDataBuffer(sampleBuffer);
        CFRetain(blockBuffer);
        
        // 获取_pcmBufferSize 和 _pcmBuffer
        OSStatus status = CMBlockBufferGetDataPointer(blockBuffer, 0, NULL, &self->_pcmBufferSize, &self->_pcmBuffer);
        if (status != kCMBlockBufferNoErr) {
            NSLog(@"获取 pcmBuffer 数据错误");
            return ;
        }
        
        // 清空
        memset(self->_aacBuffer, 0, self->_aacBufferSize);
        
        // 初始化缓冲列表
        AudioBufferList outAudioBufferList = {0}; // 结构体
        // 缓冲区个数
        outAudioBufferList.mNumberBuffers = 1;
        // 渠道个数
        outAudioBufferList.mBuffers[0].mNumberChannels = 1;
        // 缓存区大小
        outAudioBufferList.mBuffers[0].mDataByteSize = (int)self->_aacBufferSize;
        // 缓冲区内容
        outAudioBufferList.mBuffers[0].mData = self->_aacBuffer;
        
        // 编码
        AudioStreamPacketDescription * outPD = NULL;
        UInt32 inPutSize = 1;
        /*
         inInputDataProc 自己实现的编码数据的callback引用
         self 获取的数据
         inPutSize 输出数据的长度
         outAudioBUfferList 输出的数据
         outPD  输出数据的描述
         */
        status = AudioConverterFillComplexBuffer(self->_audioConverter,
                                                 inInputDataProc,
                                                 (__bridge void*)self,
                                                 &inPutSize,
                                                 &outAudioBufferList,
                                                 outPD
                                                 );
        
        // 编码后完成
        NSData * data = nil;
        if (status == noErr) {
            // 获取缓冲区的原始数据acc数据
            NSData * rawAAC = [NSData dataWithBytes:outAudioBufferList.mBuffers[0].mData length:outAudioBufferList.mBuffers[0].mDataByteSize];
            
            // 加头ADTS
            NSData * adtsHeader = [self adtsDataForPacketLength:rawAAC.length];
            NSMutableData * fullData = [NSMutableData dataWithData:adtsHeader];
            [fullData appendData:rawAAC];
            data = fullData;
        } else {
            NSLog(@"数据错误");
            return;
        }
        
        // 回调
        //        if (completionBlock) {
        //            dispatch_async(_callBackQueue, ^{
        //                completionBlock(data, nil);
        //            });
        //        }
        // 写入数据
        [self.audioFileHandle writeData:data];
        
        CFRelease(sampleBuffer);
        CFRelease(blockBuffer);
    });
}



/**
 *  Add ADTS header at the beginning of each and every AAC packet.
 *  This is needed as MediaCodec encoder generates a packet of raw
 *  AAC data.
 *
 *  Note the packetLen must count in the ADTS header itself.
 注意：packetLen 必须在ADTS头身计算
 *  See: http://wiki.multimedia.cx/index.php?title=ADTS
 *  Also: http://wiki.multimedia.cx/index.php?title=MPEG-4_Audio#Channel_Configurations
 **/
- (NSData*)adtsDataForPacketLength:(NSUInteger)packetLength {
    
    int adtsLength = 7;
    char *packet = malloc(sizeof(char) * adtsLength);
    
    int profile = 2;
    int freqIdx = 4;
    int chanCfg = 1;
    NSUInteger fullLength = adtsLength + packetLength;
    packet[0] = (char)0xFF;
    packet[1] = (char)0xF9;
    packet[2] = (char)(((profile-1)<<6) + (freqIdx<<2) +(chanCfg>>2));
    packet[3] = (char)(((chanCfg&3)<<6) + (fullLength>>11));
    packet[4] = (char)((fullLength&0x7FF) >> 3);
    packet[5] = (char)(((fullLength&7)<<5) + 0x1F);
    packet[6] = (char)0xFC;
    
    NSData *data = [NSData dataWithBytesNoCopy:packet length:adtsLength freeWhenDone:YES];
    return data;
}
@end
