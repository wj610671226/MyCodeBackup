//
//  H264Encoder.h
//  AVFounctionStudy
//
//  Created by mac on 2018/11/1.
//  Copyright © 2018 mac. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>

@interface H264Encoder : NSObject

- (void)encodeH264:(CMSampleBufferRef)sampleBuffer;

- (void)stopEncode;

@end
