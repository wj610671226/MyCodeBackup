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

#import "THCameraController.h"
#import <AVFoundation/AVFoundation.h>
#import "THMovieWriter.h"
#import <AssetsLibrary/AssetsLibrary.h>

@interface THCameraController () <AVCaptureVideoDataOutputSampleBufferDelegate,
                                  AVCaptureAudioDataOutputSampleBufferDelegate,THMovieWriterDelegate>

@property (strong, nonatomic) AVCaptureVideoDataOutput *videoDataOutput;
@property (strong, nonatomic) AVCaptureAudioDataOutput *audioDataOutput;

// Listing 8.17
@property (nonatomic, strong) THMovieWriter * movieWriter;
@end

@implementation THCameraController

- (BOOL)setupSessionOutputs:(NSError **)error {

    // Listing 8.10
    self.videoDataOutput = [[AVCaptureVideoDataOutput alloc] init];
    // 结合OpenGL ES和CoreImage 这个格式比较合适
    NSDictionary * outputSettings = @{(id)kCVPixelBufferPixelFormatTypeKey : @(kCVPixelFormatType_32BGRA)};
    self.videoDataOutput.videoSettings = outputSettings;

    self.videoDataOutput.alwaysDiscardsLateVideoFrames = NO;
    [self.videoDataOutput setSampleBufferDelegate:self queue:self.dispatchQueue];
    
    if ([self.captureSession canAddOutput:self.videoDataOutput]) {
        [self.captureSession addOutput:self.videoDataOutput];
    } else {
        return NO;
    }
    
    self.audioDataOutput = [[AVCaptureAudioDataOutput alloc] init];
    [self.audioDataOutput setSampleBufferDelegate:self queue:self.dispatchQueue];
    if ([self.captureSession canAddOutput:self.audioDataOutput]) {
        [self.captureSession addOutput:self.audioDataOutput];
    } else {
        return NO;
    }
    // Listing 8.17
    
    NSString * fileType = AVFileTypeQuickTimeMovie;
    NSDictionary * videoSettings = [self.videoDataOutput recommendedVideoSettingsForAssetWriterWithOutputFileType:fileType];
    NSDictionary * audioSettings = [self.audioDataOutput recommendedAudioSettingsForAssetWriterWithOutputFileType:fileType];
    
    self.movieWriter = [[THMovieWriter alloc] initWithVideoSettings:videoSettings audioSettings:audioSettings dispatchQueue:self.dispatchQueue];
    self.movieWriter.delegate = self;
    return YES;
}

- (NSString *)sessionPreset {

    // Listing 8.10

    return AVCaptureSessionPresetMedium;
}

- (void)startRecording {

    // Listing 8.17
    [self.movieWriter startWriting];
    self.recording = YES;
}

- (void)stopRecording {

    // Listing 8.17
    [self.movieWriter stopWriting];
    self.recording = NO;
}


#pragma mark - Delegate methods

- (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection *)connection {

    [self.movieWriter processSampleBuffer:sampleBuffer];
    // Listing 8.11
    if (captureOutput == self.videoDataOutput) {
        // 处理视频数据
        CVPixelBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
        CIImage * sourceImage = [CIImage imageWithCVImageBuffer:imageBuffer];
        [self.imageTarget setImage:sourceImage];
    }
    // Listing 8.17
}

- (void)didWriteMovieAtURL:(NSURL *)outputURL {

    // Listing 8.17
    ALAssetsLibrary * library = [[ALAssetsLibrary alloc] init];
    if ([library videoAtPathIsCompatibleWithSavedPhotosAlbum:outputURL]) {
        [library writeVideoAtPathToSavedPhotosAlbum:outputURL completionBlock:^(NSURL *assetURL, NSError *error) {
            if (error) {
                [self.delegate assetLibraryWriteFailedWithError:error];
            }
        }];
    }
}

@end
