//
//  AudioViewController.m
//  FFmpegDemo
//
//  Created by mac on 2018/8/14.
//  Copyright © 2018年 mac. All rights reserved.
//  音频解码

#import "AudioDecodeViewController.h"

//核心库
#include "libavcodec/avcodec.h"
//封装格式处理库
#include "libavformat/avformat.h"
//工具库
#include "libavutil/imgutils.h"
//视频像素数据格式库
#include "libswscale/swscale.h"
//音频采样数据格式库
#include "libswresample/swresample.h"

@interface AudioDecodeViewController ()

@end



@implementation AudioDecodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    [self audioDecode];
    
}

// 音频解码
- (void)audioDecode {
    NSString * inPath = [[NSBundle mainBundle] pathForResource:@"Test" ofType:@"mov"];
    NSString * documentPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject;
    NSString * outPath = [NSString stringWithFormat:@"%@/text.pcm", documentPath];
    NSLog(@"outPath = %@", outPath);
    
    /*
     音频解码步骤
     第一步：组册组件
     av_register_all();
     
     第二步：打开封装格式->打开文件
     avformat_open_input();
     
     第三步：查找音频流->拿到音频信息
     avformat_find_stream_info();
     
     第四步：查找音频解码器
     avcodec_find_decoder();
     
     第五步：打开音频解码器
     avcodec_open2();
     
     第六步：读取音频压缩数据->循环读取
     
     第七步：音频解码
     
     第八步：释放内存资源，关闭音频解码器

     */
    
    // 第一步、注册组件
    avformat_network_init();
    
    // 第二步、打开封装格式->打开文件
    AVFormatContext * avformat_context = avformat_alloc_context();
    const char *url = inPath.UTF8String;
    int avformat_open_input_result = avformat_open_input(&avformat_context, url, NULL, NULL);
    if (avformat_open_input_result != 0) {
        NSLog(@"打开文件失败");
        return;
    }
    NSLog(@"打开文件成功");
    
    // 第三步、查找音频流。获取音频信息
    int avformat_find_stream_info_result = avformat_find_stream_info(avformat_context, NULL);
    if (avformat_find_stream_info_result < 0) {
        NSLog(@"查找音频流失败");
        return;
    }
    NSLog(@"查找音频流成功");
    
    // 第四步、查找音频流解码器
    int av_strman_index = -1;
    // 4.1 查找音频流索引位置
    for (int i = 0; i < avformat_context->nb_streams;  ++i) {
        // 判断是否是音频流
        if (avformat_context->streams[i]->codec->codec_type == AVMEDIA_TYPE_AUDIO) {
            av_strman_index = i;
            break;
        }
    }
    // 4.2 获取音频解码器上下文
    AVCodecContext * avcodec_context = avformat_context->streams[av_strman_index]->codec;
    // 4.3 获取音频解码器
    AVCodec * avcodec = avcodec_find_decoder(avcodec_context->codec_id);
    if (avcodec == NULL) {
        NSLog(@"获取音频解码器失败");
        return;
    }
    NSLog(@"获取音频解码器成功");
    
    // 第五步 打开音频解码器
    int avcodec_open2_result = avcodec_open2(avcodec_context, avcodec, NULL);
    if (avcodec_open2_result != 0) {
        NSLog(@"打开音频解码器失败");
        return;
    }
    NSLog(@"打开音频解码器成功");
    
    // 第六步：读取音频压缩数据->循环读取
    
    // 创建音频压缩数据帧
    // 音频压缩数据 aac mp3
    AVPacket * packet = (AVPacket *)av_malloc(sizeof(AVPacket));
    // 创建音频采样数据帧
    AVFrame * avframe = av_frame_alloc();
    
    // 音频采样上下文-》开辟了一块内存空间->pcm格式
    // 音频采样上下文
    struct SwrContext * swr_context = swr_alloc();
    // 输出声道类型： AV_CH_LAYOUT_STEREO 立体声
    int64_t out_ch_layout = AV_CH_LAYOUT_STEREO;
    // 输出采样精度
//    enum AVSampleFormat out_sample_fmt = avcodec_context->sample_fmt;
    int out_sample_fmt = AV_SAMPLE_FMT_S16;
    // 输出采样率 44100
    int out_sample_rate = avcodec_context->sample_rate;
    // 输入声道布局类型
    int64_t in_ch_layout = av_get_default_channel_layout(avcodec_context->channels);
    // 输入采样精度
    enum AVSampleFormat in_sample_fmt = avcodec_context->sample_fmt;
    // 输入采样率
    int in_sample_rate = avcodec_context->sample_rate;
    // log日志 从哪里开始统计
    int log_offset = 0;
    swr_alloc_set_opts(swr_context,
                       out_ch_layout,
                       out_sample_fmt,
                       out_sample_rate,
                       in_ch_layout,
                       in_sample_fmt,
                       in_sample_rate,
                       log_offset,
                       NULL);
    
    // 初始化音频采样数据上下文
    swr_init(swr_context);
    
    // 输出音频采样数据
    // 缓存区大小 = 采样率(44100HZ) * 采样精度（16位 = 2字节）
    int MAX_AUDIO_SIZE = 44100 * 2;
    uint8_t * out_buffer = (uint8_t *)av_malloc(MAX_AUDIO_SIZE);
    // 输出声道数量
    int out_nb_channels = av_get_channel_layout_nb_channels(out_ch_layout);
    
    int audio_decode_result = 0;
    
    // 打开文件
    FILE * out_file_pcm = fopen(outPath.UTF8String, "wb");
    if (out_file_pcm == NULL) {
        NSLog(@"打开音频输出文件失败呢");
        return;
    }
    
    int current_index = 1;
    
    while (av_read_frame(avformat_context, packet) >= 0) {
        // 读取一帧音频压缩数据成功
        // 判断是否是音频流
        if (packet->stream_index == av_strman_index) {
            // 第七步、音频解码
            // 7.1 发送一帧音频压缩数据
            avcodec_send_packet(avcodec_context, packet);
            // 7.2 解压一帧音频压缩数据包->获得一帧音频采样数据->音频采样数据帧
            audio_decode_result = avcodec_receive_frame(avcodec_context, avframe);
            if (audio_decode_result == 0) {
                // 解码成功
                // 7.3 类型转换 -> 输出pcm格式
                swr_convert(swr_context,
                            &out_buffer,
                            MAX_AUDIO_SIZE,
                            (const uint8_t **)avframe->data,
                            avframe->nb_samples);
                // 7.4 获取缓冲区实际存储大小
                // 输入大小
                int nb_samples = avframe->nb_samples;
                // out_nb_channels 输出声道数量
                // nb_samples 输入大小
                // out_sample_fmt 输出音频采样数据格式
                // 1 字节对齐方式
                int out_buffer_size = av_samples_get_buffer_size(NULL, out_nb_channels, nb_samples, out_sample_fmt, 1);
                // 7.5 写入文件
                fwrite(out_buffer, 1, out_buffer_size, out_file_pcm);
                
                NSLog(@"当前音视频解码第%d帧", current_index);
                
                current_index ++;
            }
        }
    }
    
    // 第八步、释放内存资源，关闭音频解码器
    fclose(out_file_pcm);
    av_packet_free(&packet);
    swr_free(&swr_context);
    av_free(out_buffer);
    av_frame_free(&avframe);
    avcodec_close(avcodec_context);
    avformat_close_input(&avformat_context);
}
@end
