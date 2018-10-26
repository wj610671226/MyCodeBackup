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

#import "THPreviewView.h"

// 进行缩放个旋转， m34绕Y轴旋转
static CATransform3D THMakePerspectiveTransform(CGFloat eyePosition) {
    CATransform3D transform = CATransform3DIdentity;
    transform.m34 = -1.0 / eyePosition;
    return transform;
}

@interface THPreviewView ()

    // Listing 7.9
@property (nonatomic, strong) CALayer * overlayLayer;
@property (nonatomic, strong) NSMutableDictionary * faceLayers;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer * previewLayer;
@end

@implementation THPreviewView

+ (Class)layerClass {

    // Listing 7.9

    return [AVCaptureVideoPreviewLayer class];
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupView];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self setupView];
    }
    return self;
}

- (void)setupView {

    // Listing 7.10
    self.faceLayers = [NSMutableDictionary dictionary];
    self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    
    self.overlayLayer = [CALayer layer];
    self.overlayLayer.frame = self.bounds;
    self.overlayLayer.sublayerTransform = THMakePerspectiveTransform(1000);
    [self.previewLayer addSublayer:self.overlayLayer];
}



- (AVCaptureSession*)session {

    // Listing 7.9

    return self.previewLayer.session;
}

- (void)setSession:(AVCaptureSession *)session {

    // Listing 7.10
    self.previewLayer.session = session;
}

- (AVCaptureVideoPreviewLayer *)previewLayer {

    // Listing 7.9

    return (AVCaptureVideoPreviewLayer *)self.layer;
}

- (void)didDetectFaces:(NSArray *)faces {
    // Listing 7.11
    // 保存转化后的人脸数据
    NSArray * transformedFaces = [self transformedFacesFromFaces:faces];
    // Listing 7.12
    NSMutableArray * lostFaces = [self.faceLayers.allKeys mutableCopy];
    for (AVMetadataFaceObject * face in transformedFaces) {
        NSNumber * faceID = @(face.faceID);
        [lostFaces removeObject:faceID];
        
        CALayer * layer = self.faceLayers[faceID];
        if (!layer) {
            layer = [self makeFaceLayer];
            [self.overlayLayer addSublayer:layer];
            self.faceLayers[faceID] = layer;
        }
        layer.transform = CATransform3DIdentity;
        layer.frame = face.bounds;
        
        // 判断人脸对象是否具有倾斜角，有获取对应的值并关联
        if (face.hasRollAngle) {
            CATransform3D t = [self transformForRollAngle:face.rollAngle];
            layer.transform = CATransform3DConcat(layer.transform, t);
        }
        
        // 判断人脸对象是否具有偏转角，有获取对应的值并关联
        if (face.hasYawAngle) {
            CATransform3D t = [self transformForYawAngle:face.yawAngle];
            layer.transform = CATransform3DConcat(layer.transform, t);
        }
    }
    
    for (NSNumber * faceID in lostFaces) {
        CALayer * layer = self.faceLayers[faceID];
        [layer removeFromSuperlayer];
        [self.faceLayers removeObjectForKey:faceID];
    }
    // Listing 7.13
}

- (NSArray *)transformedFacesFromFaces:(NSArray *)faces {

    // Listing 7.11
    NSMutableArray * transformedFaces = [NSMutableArray array];
    for (AVMetadataObject * face in faces ) {
        // 将空间的人脸对象转换为视图空间对象集合
        AVMetadataObject * transformedFace = [self.previewLayer transformedMetadataObjectForMetadataObject:face];
        [transformedFaces addObject:transformedFace];
    }
    return transformedFaces;
}

// 创建一个新的calayer
- (CALayer *)makeFaceLayer {
    // Listing 7.12
    CALayer * layer = [CALayer layer];
    layer.borderWidth = 5.0f;
    layer.borderColor = [UIColor colorWithRed:0.188 green:0.517 blue:0.877 alpha:1].CGColor;
    return layer;
}

// Rotate around Z-axis
- (CATransform3D)transformForRollAngle:(CGFloat)rollAngleInDegrees {

    // Listing 7.13
    CGFloat rollAngleInRadians = THDegreesToRadians(rollAngleInDegrees);
    return CATransform3DMakeRotation(rollAngleInRadians, 0, 0, 1);
}

// Rotate around Y-axis
// 度转换为弧度值
- (CATransform3D)transformForYawAngle:(CGFloat)yawAngleInDegrees {

    // Listing 7.13
    CGFloat yawAngleInRadians = THDegreesToRadians(yawAngleInDegrees);
    CATransform3D yawTransform = CATransform3DMakeRotation(yawAngleInRadians, 0, -1, 0);
    return CATransform3DConcat(yawTransform, [self orientationTransform]);
}

- (CATransform3D)orientationTransform {

    // Listing 7.13
    CGFloat angle = 0.0;
    switch ([UIDevice currentDevice].orientation) {
        case UIDeviceOrientationPortraitUpsideDown:
            angle = M_PI;
            break;
        case UIDeviceOrientationLandscapeRight:
            angle = -M_PI / 2.0f;
            break;
        case UIDeviceOrientationLandscapeLeft:
            angle = M_PI / 2.0f;
            break;
        default: // UIDeviceOrientationPortrait
            angle = 0;
            break;
    }
    return CATransform3DMakeRotation(angle, 0, 0, 1.0);
}

// The clang pragmas can be removed when you're finished with the project.
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused"

static CGFloat THDegreesToRadians(CGFloat degrees) {

    // Listing 7.13

    return degrees * M_PI / 180;
}

static CATransform3D CATransform3DMakePerspective(CGFloat eyePosition) {

    // Listing 7.10

    return CATransform3DIdentity;

}
#pragma clang diagnostic pop

@end
