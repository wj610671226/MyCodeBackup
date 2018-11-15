//
//  AACEncoder.h
//  AVFounctionStudy
//
//  Created by mac on 2018/11/1.
//  Copyright © 2018 mac. All rights reserved.
//


#import <AVFoundation/AVFoundation.h>
#import <Foundation/Foundation.h>

@interface AACEncoder : NSObject

- (void)encodeAudioSampleBuffer:(CMSampleBufferRef)sampleBuffer;

- (void)stopEncodeAudio;

@end
