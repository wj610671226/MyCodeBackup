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

#import "THCameraController.h"
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "NSFileManager+THAdditions.h"

NSString *const THThumbnailCreatedNotification = @"THThumbnailCreated";

@interface THCameraController () <AVCaptureFileOutputRecordingDelegate>

@property (strong, nonatomic) dispatch_queue_t videoQueue;
@property (strong, nonatomic) AVCaptureSession *captureSession;
@property (weak, nonatomic) AVCaptureDeviceInput *activeVideoInput;
@property (strong, nonatomic) AVCaptureStillImageOutput *imageOutput;
@property (strong, nonatomic) AVCaptureMovieFileOutput *movieOutput;
@property (strong, nonatomic) NSURL *outputURL;

@end

@implementation THCameraController

- (BOOL)setupSession:(NSError **)error {
    // Listing 6.4
    // 初始化session
    self.captureSession = [[AVCaptureSession alloc] init];
    self.captureSession.sessionPreset = AVCaptureSessionPresetHigh;
    
    // 设置视频设备
    AVCaptureDevice * videoDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    AVCaptureDeviceInput * videoInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:error];
    if (videoInput) {
        if ([self.captureSession canAddInput:videoInput]) {
            [self.captureSession addInput:videoInput];
            self.activeVideoInput = videoInput;
        }
    } else {
        return NO;
    }
    
    // 设置音频设备
    AVCaptureDevice * audioDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
    AVCaptureDeviceInput * audioInput = [AVCaptureDeviceInput deviceInputWithDevice:audioDevice error:error];
    if (audioInput) {
        if ([self.captureSession canAddInput:audioInput]) {
            [self.captureSession addInput:audioInput];
        }
    } else {
        return NO;
    }
    
    // 设置image output
    self.imageOutput = [[AVCaptureStillImageOutput alloc] init];
    self.imageOutput.outputSettings = @{AVVideoCodecKey: AVVideoCodecJPEG};
    if ([self.captureSession canAddOutput:self.imageOutput]) {
        [self.captureSession addOutput:self.imageOutput];
    }
    
    // 设置movie output
    self.movieOutput = [[AVCaptureMovieFileOutput alloc] init];
    if ([self.captureSession canAddOutput:self.movieOutput]) {
        [self.captureSession addOutput:self.movieOutput];
    }
    self.videoQueue = dispatch_queue_create("com.videoQueue", NULL);
    return YES;
}

- (void)startSession {

    // Listing 6.5
    // 启动会话
    if (![self.captureSession isRunning]) {
        dispatch_async(self.videoQueue, ^{
            [self.captureSession startRunning];
        });
    }
}

- (void)stopSession {

    // Listing 6.5
    if ([self.captureSession isRunning]) {
        dispatch_async(self.videoQueue, ^{
            [self.captureSession stopRunning];
        });
    }
}

#pragma mark - Device Configuration

- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition)position {

    // Listing 6.6
    // 获取有效的摄像头参数
    NSArray * devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice * device in devices) {
        if (device.position == position) {
            return device;
        }
    }
    return nil;
}

- (AVCaptureDevice *)activeCamera {

    // Listing 6.6
    // 返回激活的捕捉设备输入的属性
    return self.activeVideoInput.device;
}

- (AVCaptureDevice *)inactiveCamera {

    // Listing 6.6
    AVCaptureDevice * device = nil;
    // 获取当前摄像头的反向摄像头
    if (self.cameraCount > 1) {
        if ([self activeCamera].position == AVCaptureDevicePositionBack) {
            device = [self cameraWithPosition:AVCaptureDevicePositionFront];
        } else {
            device = [self cameraWithPosition:AVCaptureDevicePositionBack];
        }
    }
    return device;
}

- (BOOL)canSwitchCameras {

    // Listing 6.6
    // 判断是否有2个摄像头以上
    return self.cameraCount > 1;
}

- (NSUInteger)cameraCount {

    // Listing 6.6
    // 获取摄像头个数
    return [[AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo] count];
}

// 切换摄像头
- (BOOL)switchCameras {

    // Listing 6.7
    // 判断是否可以切换摄像头
    if (![self canSwitchCameras]) {
        return NO;
    }
    
    NSError * error;
    // 获取未激活的摄像头，并创建一个新的输入
    AVCaptureDevice * videoDevoce = [self inactiveCamera];
    AVCaptureDeviceInput * videoInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevoce error:&error];
    
    
    if (videoInput) {
        // 移除就的输入，添加新的输入
        [self.captureSession beginConfiguration];
        [self.captureSession removeInput:self.activeVideoInput];
        if ([self.captureSession canAddInput:videoInput]) {
            [self.captureSession addInput:videoInput];
            self.activeVideoInput = videoInput;
        } else {
            [self.captureSession addInput:self.activeVideoInput];
        }
        [self.captureSession commitConfiguration];
    } else {
        [self.delegate deviceConfigurationFailedWithError:error];
        return NO;
    }
    return YES;
}

#pragma mark - Focus Methods

// 点击对焦
- (BOOL)cameraSupportsTapToFocus {
    
    // Listing 6.8
    // 判断设备是否支持对焦的功能
    return [[self activeCamera] isFocusPointOfInterestSupported];
}

- (void)focusAtPoint:(CGPoint)point {
    // Listing 6.8
    AVCaptureDevice * device = [self activeCamera];
    // 判断是否支持对焦并自动对焦
    if (device.isFocusPointOfInterestSupported && [device isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
        NSError * error;
        if ([device lockForConfiguration:&error]) {
            // 自动对焦点
            device.focusPointOfInterest = point;
            device.focusMode = AVCaptureFocusModeAutoFocus;
            [device unlockForConfiguration];
        } else {
            [self.delegate deviceConfigurationFailedWithError:error];
        }
    }
}

#pragma mark - Exposure Methods

// 点击曝光
- (BOOL)cameraSupportsTapToExpose {
 
    // Listing 6.9
    // 判断激活设备是否支持曝光
    return [[self activeCamera] isExposurePointOfInterestSupported];
}

static const NSString *THCameraAdjustingExposureContext;

- (void)exposeAtPoint:(CGPoint)point {

    // Listing 6.9
    AVCaptureDevice * device = [self activeCamera];
    AVCaptureExposureMode exposureMode = AVCaptureExposureModeContinuousAutoExposure;
    if (device.isExposurePointOfInterestSupported && [device isExposureModeSupported:exposureMode]) {
        NSError * error;
        // 锁定设备配置，设置exposurePointOfInterest、exposureMode的值
        if ([device lockForConfiguration:&error]) {
            device.exposurePointOfInterest = point;
            device.exposureMode = exposureMode;
            // 判断设备是否支持自动曝光模式
            if ([device isExposureModeSupported:AVCaptureExposureModeLocked]) {
                [device addObserver:self forKeyPath:@"adjustingExposure" options:NSKeyValueObservingOptionNew context:&THCameraAdjustingExposureContext];
            }
            
            [device unlockForConfiguration];
        } else {
            [self.delegate deviceConfigurationFailedWithError:error];
        }
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {

    // Listing 6.9
    if (context == &THCameraAdjustingExposureContext) {
        AVCaptureDevice * device = (AVCaptureDevice *)object;
        //  判断设备是否不再调整曝光等级
        if (!device.isAdjustingExposure && [device isExposureModeSupported:AVCaptureExposureModeLocked]) {
            // 移除通知
            [object removeObserver:self forKeyPath:@"adjustingExposure" context:&THCameraAdjustingExposureContext];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                NSError * error;
                if ([device lockForConfiguration:&error]) {
                    device.exposureMode = AVCaptureExposureModeLocked;
                    [device unlockForConfiguration];
                } else {
                    [self.delegate deviceConfigurationFailedWithError:error];
                }
            });
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

// 重新设置对焦和曝光
- (void)resetFocusAndExposureModes {

    // Listing 6.10
    AVCaptureDevice * device = [self activeCamera];
    AVCaptureFocusMode focusMode = AVCaptureFocusModeContinuousAutoFocus;
    BOOL canResetFocus = [device isFocusPointOfInterestSupported] && [device isFocusModeSupported:focusMode];
    AVCaptureExposureMode exposureMode = AVCaptureExposureModeContinuousAutoExposure;
    BOOL canResetExposure = [device isExposurePointOfInterestSupported] && [device isExposureModeSupported:exposureMode];
    
    CGPoint centerPoint = CGPointMake(0.5, 0.5);
    NSError * error;
    if ([device lockForConfiguration:&error]) {
        if (canResetFocus) {
            device.focusMode = focusMode;
            device.focusPointOfInterest = centerPoint;
        }
        
        if (canResetExposure) {
            device.exposureMode = exposureMode;
            device.exposurePointOfInterest = centerPoint;
        }
        
        [device unlockForConfiguration];
    } else {
        [self.delegate deviceConfigurationFailedWithError:error];
    }
}



#pragma mark - Flash and Torch Modes

// 调整闪光灯和手电筒模式
- (BOOL)cameraHasFlash {

    // Listing 6.11
    
    return [[self activeCamera] hasFlash];
}

- (AVCaptureFlashMode)flashMode {

    // Listing 6.11
    
    return [[self activeCamera] flashMode];
}

- (void)setFlashMode:(AVCaptureFlashMode)flashMode {

    // Listing 6.11
    AVCaptureDevice * device = [self activeCamera];
    if ([device isFlashModeSupported:flashMode]) {
        NSError * error;
        if ([device lockForConfiguration:&error]) {
            device.flashMode = flashMode;
            [device unlockForConfiguration];
        } else {
            [self.delegate deviceConfigurationFailedWithError:error];
        }
    }
}

- (BOOL)cameraHasTorch {

    // Listing 6.11
    
    return [[self activeCamera] hasTorch];
}

- (AVCaptureTorchMode)torchMode {
    // Listing 6.11
    return [[self activeCamera] torchMode];
}

- (void)setTorchMode:(AVCaptureTorchMode)torchMode {
    // Listing 6.11
    AVCaptureDevice * device = [self activeCamera];
    if ([device isTorchModeSupported:torchMode]) {
        NSError * error;
        if ([device lockForConfiguration:&error]) {
            device.torchMode = torchMode;
            [device unlockForConfiguration];
        } else {
            [self.delegate deviceConfigurationFailedWithError:error];
        }
    }
}


#pragma mark - Image Capture Methods

// 捕捉静态图片
- (void)captureStillImage {
    // Listing 6.12
    AVCaptureConnection * connection = [self.imageOutput connectionWithMediaType:AVMediaTypeVideo];
    
    // 调整方向
    if (connection.isVideoOrientationSupported) {
        connection.videoOrientation = [self currentVideoOrientation];
    }
    
    [self.imageOutput captureStillImageAsynchronouslyFromConnection:connection completionHandler:^(CMSampleBufferRef  _Nullable imageDataSampleBuffer, NSError * _Nullable error) {
        if (imageDataSampleBuffer != NULL) {
            // 获取图片信息
            NSData * imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
            UIImage * image = [[UIImage alloc] initWithData:imageData];
            NSLog(@"image = %@", image);
            [self writeImageToAssetsLibrary:image];
        } else {
            NSLog(@"捕捉静态图片 sampleBuffer error = %@", error.localizedDescription);
        }
    }];
}

- (AVCaptureVideoOrientation)currentVideoOrientation {
    // Listing 6.12
    AVCaptureVideoOrientation orientation;
    // 根据设备方向切换AVCaptureVideoOrientation方向，注意左右是相反的
    switch ([UIDevice currentDevice].orientation) {
        case UIDeviceOrientationPortrait:
            orientation = AVCaptureVideoOrientationPortrait;
            break;
        case UIDeviceOrientationLandscapeRight:
            orientation = AVCaptureVideoOrientationLandscapeLeft;
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            orientation = AVCaptureVideoOrientationPortraitUpsideDown;
            break;
        default:
            orientation = AVCaptureVideoOrientationLandscapeRight;
            break;
    }
    return orientation;
    // Listing 6.13
}


// 将图片写入照片库
- (void)writeImageToAssetsLibrary:(UIImage *)image {
    // Listing 6.13
    ALAssetsLibrary * library = [[ALAssetsLibrary alloc] init];
    [library writeImageToSavedPhotosAlbum:image.CGImage orientation:(NSInteger)image.imageOrientation completionBlock:^(NSURL *assetURL, NSError *error) {
        if (!error) {
            [self postThumbnailNotifification:image];
        } else {
            NSLog(@"writeImageToAssetsLibrary error = %@", error.localizedDescription);
        }
    }];
}

- (void)postThumbnailNotifification:(UIImage *)image {
    // Listing 6.13
    [[NSNotificationCenter defaultCenter] postNotificationName:THThumbnailCreatedNotification object:image];
}

#pragma mark - Video Capture Methods

// 视频录制
- (BOOL)isRecording {
    // Listing 6.14
    // 是否录制中
    return self.movieOutput.isRecording;
}

- (void)startRecording {
    // Listing 6.14
    if (![self isRecording]) {
        // 获取当前连接信息
        AVCaptureConnection * videoConnection = [self.movieOutput connectionWithMediaType:AVMediaTypeVideo];
        
        // 方向处理
        if ([videoConnection isVideoOrientationSupported]) {
            videoConnection.videoOrientation = self.currentVideoOrientation;
        }
        
        // 设置录制视频稳定
        if ([videoConnection isVideoOrientationSupported]) {
            videoConnection.enablesVideoStabilizationWhenAvailable = YES;
        }
        
        // 降低对焦速度，平滑对焦
        AVCaptureDevice * device = [self activeCamera];
        if (device.isSmoothAutoFocusSupported) {
            NSError * error;
            if ([device lockForConfiguration:&error]) {
                device.smoothAutoFocusEnabled = YES;
                [device unlockForConfiguration];
            } else {
                [self.delegate deviceConfigurationFailedWithError:error];
            }
        }
        
        // 获取视频存储地址
        self.outputURL = [self uniqueURL];
        // 设置代理开始录制
        [self.movieOutput startRecordingToOutputFileURL:self.outputURL recordingDelegate:self];
    }
}

- (CMTime)recordedDuration {
    return self.movieOutput.recordedDuration;
}

- (NSURL *)uniqueURL {
    // Listing 6.14
    NSFileManager * fileManager = [NSFileManager defaultManager];
    NSString * dirPath = [fileManager temporaryDirectoryWithTemplateString:@"kamera.XXXXXX"];
    if (dirPath) {
        NSString * filePath = [dirPath stringByAppendingPathComponent:@"kamera_movie.mov"];
        return [NSURL fileURLWithPath:filePath];
    }
    return nil;
}

- (void)stopRecording {
    // Listing 6.14
    if ([self isRecording]) {
        [self.movieOutput stopRecording];
    }
}

#pragma mark - AVCaptureFileOutputRecordingDelegate
- (void)captureOutput:(AVCaptureFileOutput *)captureOutput
didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL
      fromConnections:(NSArray *)connections
                error:(NSError *)error {
    // Listing 6.15   写入视频
    if (error) {
        [self.delegate mediaCaptureFailedWithError:error];
    } else {
        [self writeVideoToAssetsLibrary:[self.outputURL copy]];
    }
    self.outputURL = nil;
}

- (void)writeVideoToAssetsLibrary:(NSURL *)videoURL {
    // Listing 6.15
    ALAssetsLibrary * library = [[ALAssetsLibrary alloc] init];
    // 检查视频是否可以写入
    if ([library videoAtPathIsCompatibleWithSavedPhotosAlbum:videoURL]) {
        [library writeVideoAtPathToSavedPhotosAlbum:videoURL completionBlock:^(NSURL *assetURL, NSError *error) {
            if (error) {
                [self.delegate assetLibraryWriteFailedWithError:error];
            } else {
                [self generateThumbnailForVideoAtURL:videoURL];
            }
        }];
    }
}

- (void)generateThumbnailForVideoAtURL:(NSURL *)videoURL {
    // Listing 6.15
    dispatch_async(self.videoQueue, ^{
        AVAsset * asset = [AVAsset assetWithURL:videoURL];
        AVAssetImageGenerator * imageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:asset];
        imageGenerator.maximumSize = CGSizeMake(100, 0);
        // 捕捉获取缩略图方向
        imageGenerator.appliesPreferredTrackTransform = YES;
        
        CGImageRef imageRef = [imageGenerator copyCGImageAtTime:kCMTimeZero actualTime:NULL error:nil];
        UIImage *image = [UIImage imageWithCGImage:imageRef];
        CGImageRelease(imageRef);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self postThumbnailNotifification:image];
        });
    });
}
@end

    
