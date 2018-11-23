//
//  AudioEncodeViewController.m
//  FFmpegDemo
//
//  Created by mac on 2018/8/21.
//  Copyright © 2018年 mac. All rights reserved.
//  音频解码

#import "AudioEncodeViewController.h"

//核心库
#include "libavcodec/avcodec.h"
//封装格式处理库
#include "libavformat/avformat.h"
//工具库
#include "libavutil/imgutils.h"
//视频像素数据格式库
#include "libswscale/swscale.h"
#include "libswresample/swresample.h"

@interface AudioEncodeViewController ()

@end

@implementation AudioEncodeViewController

int flush_encoder1(AVFormatContext *fmt_ctx, unsigned int stream_index) {
    int ret;
    int got_frame;
    AVPacket enc_pkt;
    if (!(fmt_ctx->streams[stream_index]->codec->codec->capabilities & AV_CODEC_CAP_DELAY))
        return 0;
    while (1) {
        enc_pkt.data = NULL;
        enc_pkt.size = 0;
        av_init_packet(&enc_pkt);
        ret = avcodec_encode_video2(fmt_ctx->streams[stream_index]->codec, &enc_pkt,
                                    NULL, &got_frame);
        av_frame_free(NULL);
        if (ret < 0)
            break;
        if (!got_frame) {
            ret = 0;
            break;
        }

        NSLog(@"Flush Encoder: Succeed to encode 1 frame!\tsize:%5d\n", enc_pkt.size);
        ret = av_write_frame(fmt_ctx, &enc_pkt);
        if (ret < 0)
            break;
    }
    return ret;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    NSString * documentPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject;
    NSString * outFilePath = [NSString stringWithFormat:@"%@/test.aac", documentPath];
    NSString * inFilePath = [[NSBundle mainBundle] pathForResource:@"text" ofType:@"pcm"];
    
    // 第一步、注册组件
    avformat_network_init();
    // 第二步、初始化封装格式
    AVFormatContext * avformat_context = avformat_alloc_context();
    // 注意事项：FFmepg程序推测输出文件类型->音频压缩数据格式类型->aac格式
    // 获取音频压缩数据格式
    AVOutputFormat * avoutput_format = av_guess_format(NULL, outFilePath.UTF8String, NULL);
    // 指定类型
    avformat_context->oformat = avoutput_format;
    
    // 第三步、打开输出文件
    if (avio_open(&avformat_context->pb, outFilePath.UTF8String, AVIO_FLAG_WRITE) < 0) {
        NSLog(@"打开输出文件失败");
        return;
    }
    NSLog(@"打开输出文件成功");
    
    // 第四步、创建输出码流 创建一块内存空间
    AVStream * av_audio_stream = avformat_new_stream(avformat_context, NULL);
    
    // 第五步、查找音频编码器
    // 5.1 获取编码器上下文
    AVCodecContext * avcode_context = av_audio_stream->codec;
    // 5.2 设置编码器上下文参数
    // 设置编码器id
    avcode_context->codec_id = avoutput_format->audio_codec;
    // 设置音频编码器
    avcode_context->codec_type = AVMEDIA_TYPE_AUDIO;
    // 设置读取音频采样数据格式->编码的是音频采样数据格式->音频采样数据格式->pcm格式
    // 这个类型是根据你解码的时候指定的解码的音频采样数据格式类型
    avcode_context->sample_fmt = AV_SAMPLE_FMT_S16;
    // 设置采样率
    avcode_context->sample_rate = 44100;
    // 立体声
    avcode_context->channel_layout = AV_CH_LAYOUT_STEREO;
    // 设置声道数量
    int channels = av_get_channel_layout_nb_channels(avcode_context->channel_layout);
    avcode_context->channels = channels;
    // 设置码率
    avcode_context->bit_rate = 128000;
    
    // 查找音频编码器aac
    AVCodec * avcodec = avcodec_find_encoder(avcode_context->codec_id);
    if (avcodec == NULL) {
        NSLog(@"找不到音频编码器");
        return;
    }
    
    NSLog(@"音频编码器name = %s", avcodec->name);
    
    // 打开aac编码器
    if (avcodec_open2(avcode_context, avcodec, NULL) < 0) {
        NSLog(@"打开音频编码器失败");
        return;
    }
    
    NSLog(@"打开音频编码器成功");
    
    // 第七步、写入文件头信息
    int avformat_write_header_result = avformat_write_header(avformat_context, NULL);
    NSLog(@"写入文件头信息 result = %d", avformat_write_header_result);
    
 
    // 打开输入文件
    FILE * in_file = fopen(inFilePath.UTF8String, "rb");
    if (in_file == NULL) {
        NSLog(@"文件不存在");
        return;
    }
    
    // 初始化音频采样数据帧缓冲区
    AVFrame * av_frame = av_frame_alloc();
    av_frame->nb_samples = avcode_context->frame_size;
    av_frame->format = avcode_context->sample_fmt;
    
    // 获取音频采样数据缓冲区
    int buffer_size = av_samples_get_buffer_size(NULL,
                                                 avcode_context->channels,
                                                 avcode_context->frame_size,
                                                 avcode_context->sample_fmt,
                                                 1);
    // 创建缓冲区->存储音频采样数据->一帧数据
    uint8_t * out_buffer = (uint8_t *)av_malloc(buffer_size);
    avcodec_fill_audio_frame(av_frame,
                             avcode_context->channels,
                             avcode_context->sample_fmt,
                             (const uint8_t *)out_buffer,
                             buffer_size,
                             1);
    
    // 创建音频压缩数据->帧缓存空间
    AVPacket * av_packet = (AVPacket *)av_malloc(buffer_size);
    
    // 循环读取数据
    int frame_current = 1;
    int i = 0;
    int result = 0;
    
    // 接收一帧数据 编码
    while (true) {
        if (fread(out_buffer, 1, buffer_size, in_file) <= 0) {
            NSLog(@"读取失败");
            break;
        } else if(feof(in_file)) {
            break;
        }
        
        // 设置音频采样数据格式
        av_frame->data[0] = out_buffer;
        av_frame->pts = i;
        i++;
        

        // 发送一帧音频像素数据
        result = avcodec_send_frame(avcode_context, av_frame);
        if (result != 0) {
            NSLog(@"发送数据失败");
            return;
        }
        
        // 编码一帧音频采样数据
        result = avcodec_receive_packet(avcode_context, av_packet);
        if (result == 0) {
            // 将视频数据写入输出文件中
            av_packet->stream_index = av_audio_stream->index;
            result = av_write_frame(avformat_context, av_packet);
            NSLog(@"当前是第%d帧", frame_current);
            frame_current ++;
            if (result < 0) {
                NSLog(@"输出一帧失败");
                return;
            }
        }
    }
    
    // 写入剩余帧
    flush_encoder1(avformat_context, 0);
    
    // 写入文件尾部信息
    av_write_trailer(avformat_context);
    
    // 释放内存
    avcodec_close(avcode_context);
    av_free(av_frame);
    av_free(out_buffer);
    av_packet_free(&av_packet);
    avio_close(avformat_context->pb);
    avformat_free_context(avformat_context);
    fclose(in_file);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
