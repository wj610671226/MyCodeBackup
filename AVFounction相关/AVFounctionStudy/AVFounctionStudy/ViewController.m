//
//  ViewController.m
//  CC_VideoToolBoxLearning_1
//
//  Created by CC老师 on 2017/6/26.
//  Copyright © 2017年 Miss CC. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <VideoToolbox/VideoToolbox.h>
#import "AACEncoder.h"
#import "H264Encoder.h"
#import <objc/runtime.h>


@interface ViewController ()<AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureAudioDataOutputSampleBufferDelegate>

@property(nonatomic,strong)UILabel *cLabel;
@property(nonatomic,strong)AVCaptureSession *cCapturesession;
@property(nonatomic,strong)AVCaptureDeviceInput *cCaptureDeviceInput;
@property(nonatomic,strong)AVCaptureVideoDataOutput *cCaptureDataOutput;
@property(nonatomic,strong)AVCaptureVideoPreviewLayer *cPreviewLayer;


@property (nonatomic, strong) AVCaptureAudioDataOutput * mCaptureAudioOutput; // 音频输出
@property (nonatomic, strong) AVCaptureVideoDataOutput * mCaptureVideoOutput; // 视频输出
@property (nonatomic, strong) AACEncoder * aacEncoder;
@property (nonatomic, strong) NSFileHandle *audioFileHandele;;

//

@property (nonatomic, strong) H264Encoder * h264Encoder;

@end

@implementation ViewController
{
    dispatch_queue_t cCaptureQueue;
}

- (H264Encoder *)h264Encoder {
    if (!_h264Encoder) {
        _h264Encoder = [[H264Encoder alloc] init];
    }
    return _h264Encoder;
}

- (AACEncoder *)aacEncoder {
    if (!_aacEncoder) {
        _aacEncoder = [[AACEncoder alloc] init];
    }
    return _aacEncoder;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    //基础UI实现
    _cLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, 20, 200, 100)];
    _cLabel.text = @"cc课堂之H.264硬编码";
    _cLabel.textColor = [UIColor redColor];
    [self.view addSubview:_cLabel];
    
    UIButton *cButton = [[UIButton alloc]initWithFrame:CGRectMake(200, 20, 100, 100)];
    [cButton setTitle:@"play" forState:UIControlStateNormal];
    [cButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [cButton setBackgroundColor:[UIColor orangeColor]];
    [cButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:cButton];
}


-(void)buttonClick:(UIButton *)button
{
    
    if (!_cCapturesession || !_cCapturesession.isRunning ) {
        
        [button setTitle:@"Stop" forState:UIControlStateNormal];
        [self startCapture];
    } else
    {
        [button setTitle:@"Play" forState:UIControlStateNormal];
        [self stopCapture];
    }
}

// 开始捕捉  配置AVfoundation
- (void)startCapture
{
    self.cCapturesession = [[AVCaptureSession alloc]init];
    
    self.cCapturesession.sessionPreset = AVCaptureSessionPreset640x480;
    
    cCaptureQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    
    // 设置视频输入输出
    AVCaptureDevice *inputCamera = nil;
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices) {
        if ([device position] == AVCaptureDevicePositionBack) {
            inputCamera = device;
        }
    }
    
    self.cCaptureDeviceInput = [[AVCaptureDeviceInput alloc] initWithDevice:inputCamera error:nil];
    if ([self.cCapturesession canAddInput:self.cCaptureDeviceInput]) {
        [self.cCapturesession addInput:self.cCaptureDeviceInput];
    }
    self.cCaptureDataOutput = [[AVCaptureVideoDataOutput alloc]init];
    [self.cCaptureDataOutput setAlwaysDiscardsLateVideoFrames:NO];
    
    [self.cCaptureDataOutput setVideoSettings:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCVPixelFormatType_420YpCbCr8BiPlanarFullRange] forKey:(id)kCVPixelBufferPixelFormatTypeKey]];
    [self.cCaptureDataOutput setSampleBufferDelegate:self queue:cCaptureQueue];
    
    if ([self.cCapturesession canAddOutput:self.cCaptureDataOutput]) {
        [self.cCapturesession addOutput:self.cCaptureDataOutput];
    }
    
    AVCaptureConnection * connection = [self.cCaptureDataOutput connectionWithMediaType:AVMediaTypeVideo];
    [connection setVideoOrientation:AVCaptureVideoOrientationPortrait];
    
    // 设置音频输入输出
    NSArray * audioArray = [AVCaptureDevice devicesWithMediaType:AVMediaTypeAudio];
    AVCaptureDeviceInput * audioInput = [[AVCaptureDeviceInput alloc] initWithDevice:audioArray.lastObject error:nil];
    
    AVCaptureAudioDataOutput * audioOutPut = [[AVCaptureAudioDataOutput alloc] init];
    [audioOutPut setSampleBufferDelegate:self queue:cCaptureQueue];
    if ([self.cCapturesession canAddInput:audioInput]) {
        [self.cCapturesession addInput:audioInput];
    }
    
    if ([self.cCapturesession canAddOutput:audioOutPut]) {
        [self.cCapturesession addOutput:audioOutPut];
    }
    
    // 预览图层
    self.cPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.cCapturesession];
    [self.cPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspect];
    [self.cPreviewLayer setFrame:self.view.bounds];
    [self.view.layer addSublayer:self.cPreviewLayer];

    //开始捕捉
    [self.cCapturesession startRunning];

}

- (NSString *)saveFilePath:(NSString *)path {
    NSString * filePath = [NSHomeDirectory() stringByAppendingPathComponent:path];
    [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
    BOOL createFile = [[NSFileManager defaultManager] createFileAtPath:filePath contents:nil attributes:nil];
    NSLog(@"filePath = %@",filePath);
    return createFile ? filePath : @"";
}

//停止捕捉
- (void)stopCapture
{
    [self.cCapturesession stopRunning];
    
    [self.cPreviewLayer removeFromSuperlayer];
    
    [self.h264Encoder stopEncode];

    [self.aacEncoder stopEncodeAudio];
}

#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate
// avfoundation 获取到数据的时候
-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    // // CMSampleBufferRef  包括  CMTime(时间戳) + CMVideoGormatDesc(图像存储方式) + CVPixelBuffer（编码前的数据）
    // 根据captureOutput 判断音视频类型
    if ([captureOutput isKindOfClass:[AVCaptureVideoDataOutput class]]) {
        [self.h264Encoder encodeH264:sampleBuffer];
    } else {
        [self.aacEncoder encodeAudioSampleBuffer:sampleBuffer];
    }
}




@end
