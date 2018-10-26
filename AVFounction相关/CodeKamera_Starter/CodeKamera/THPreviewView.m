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

@interface THPreviewView ()

// Listing 7.18
@property (nonatomic, strong) NSMutableDictionary * codeLayers;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer * previewLayer;
@end

@implementation THPreviewView

+ (Class)layerClass {

    // Listing 7.18

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

    // Listing 7.18
    // 保存一组识别编码的几何信息图层
    _codeLayers = [NSMutableDictionary dictionary];
    self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspect;
}

- (AVCaptureSession*)session {

    // Listing 7.18

    return self.previewLayer.session;
}

- (void)setSession:(AVCaptureSession *)session {

    // Listing 7.18
    // 建立AVCaptureSession 和 AVCaptureVideoPreviewLayer的联系
    self.previewLayer.session = session;
}

- (AVCaptureVideoPreviewLayer *)previewLayer {

    // Listing 7.18

    return (AVCaptureVideoPreviewLayer *)self.layer;
}

- (void)didDetectCodes:(NSArray *)codes {
    // Listing 7.19
    // 保存转换完成的元数据,转换坐标
    /*
     转换之前
     <AVMetadataMachineReadableCodeObject: 0x17003a400, type=\"org.iso.QRCode\", bounds={ 0.4,0.3 0.1x0.1 }>corners { 0.4,0.4 0.5,0.4 0.5,0.3 0.4,0.3 }, time 294730537644416, stringValue \"AV Foundation\""
     
     转换后
     "<AVMetadataMachineReadableCodeObject: 0x1740347e0, type=\"org.iso.QRCode\", bounds={ 253.0,319.5 42.8x42.4 }>corners { 255.4,319.5 253.0,359.3 293.7,361.9 295.8,321.8 }, time 294854235311458, stringValue \"AV Foundation\""
     */
    NSArray * transformedCodes = [self transformedCodesFromCodes:codes];

    // Listing 7.20
    // 创建视图层
    NSMutableArray * lostCodes = [self.codeLayers.allKeys mutableCopy];
    
    for (AVMetadataMachineReadableCodeObject * code in transformedCodes) {
        NSString * stringValue = code.stringValue;
        if (stringValue) {
            [lostCodes removeObject:stringValue];
        } else {
            continue;
        }
        
        // 查找是否有该图层
        NSArray * layers = self.codeLayers[stringValue];
        if (!layers) {
            // 没有就创建
            layers = @[[self makeBoundsLayer], [self makeCornersLayer]];
            self.codeLayers[stringValue] = layers;
            [self.previewLayer addSublayer:layers.firstObject];
            [self.previewLayer addSublayer:layers.lastObject];
        }
        
        CAShapeLayer * boundesLayer = layers.firstObject;
        boundesLayer.path = [self bezierPathForBounds:code.bounds].CGPath;
        
        CAShapeLayer * cornersLayer = layers.lastObject;
        cornersLayer.path = [self bezierPathForCorners:code.corners].CGPath;
        NSLog(@"string: %@", stringValue);
    }
    
    // 移除图层
    for (NSString * stringValue in lostCodes) {
        for (CALayer * layer in self.codeLayers[stringValue]) {
            [layer removeFromSuperlayer];
        }
        [self.codeLayers removeObjectForKey:stringValue];
    }
    // Listing 7.21
}

- (NSArray *)transformedCodesFromCodes:(NSArray *)codes {

    // Listing 7.19
    // 将设备坐标空间元数据对象转换为视图坐标空间对象
    NSMutableArray * transformedCodes = [NSMutableArray array];
    for (AVMetadataObject * code in codes) {
        AVMetadataObject * transformedCode = [self.previewLayer transformedMetadataObjectForMetadataObject:code];
        [transformedCodes addObject:transformedCode];
    }
    return transformedCodes;
}

- (UIBezierPath *)bezierPathForBounds:(CGRect)bounds {

    // Listing 7.20

    return [UIBezierPath bezierPathWithRect:bounds];
}

- (CAShapeLayer *)makeBoundsLayer {

    // Listing 7.20
    CAShapeLayer * shapelayer = [CAShapeLayer layer];
    shapelayer.strokeColor = [UIColor colorWithRed:0.95 green:0.75 blue:0.06 alpha:1].CGColor;
    shapelayer.fillColor = nil;
    shapelayer.lineWidth = 4.0f;
    return shapelayer;
}

- (CAShapeLayer *)makeCornersLayer {

    // Listing 7.20
    CAShapeLayer * cornerslayer = [CAShapeLayer layer];
    cornerslayer.lineWidth = 2.0f;
    cornerslayer.strokeColor = [UIColor colorWithRed:0.172 green:0.671 blue:0.428 alpha:1].CGColor;
    cornerslayer.fillColor = [UIColor colorWithRed:0.190 green:0.753 blue:0.489 alpha:1].CGColor;
    return cornerslayer;
}

- (UIBezierPath *)bezierPathForCorners:(NSArray *)corners {

    // Listing 7.21
    UIBezierPath * path = [UIBezierPath bezierPath];
    for (int i = 0; i < corners.count; i ++) {
        CGPoint point = [self pointForCorner:corners[i]];
        if (i == 0) {
            [path moveToPoint:point];
        } else {
            [path addLineToPoint:point];
        }
    }
    [path closePath];
    return path;
}

- (CGPoint)pointForCorner:(NSDictionary *)corner {

    // Listing 7.21
    CGPoint point;
    CGPointMakeWithDictionaryRepresentation((CFDictionaryRef)corner, &point);
    return point;
}

@end
