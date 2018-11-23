//
//  H264EncoderViewController.m
//  FFmpegDemo
//
//  Created by mac on 2018/11/7.
//  Copyright © 2018 mac. All rights reserved.
//

#import "H264EncoderViewController.h"
#import <AVFoundation/AVFoundation.h>

//核心库
#include "libavcodec/avcodec.h"
//封装格式处理库
#include "libavformat/avformat.h"
//工具库
#include "libavutil/imgutils.h"
//视频像素数据格式库
#include "libswscale/swscale.h"


@interface H264EncoderViewController ()<AVCaptureVideoDataOutputSampleBufferDelegate>
{
    AVFormatContext * avformat_context;
    AVCodecContext * avcodec_context;
    AVFrame * av_frame;
    uint8_t * out_buffer;
    AVPacket * av_packet;
    AVStream * av_video_stream;
    int y_size;
    int i;
    int result;
    int current_frame_index;
}
/** 捕捉会话*/
@property (nonatomic, weak) AVCaptureSession *captureSession;

/** 预览图层 */
@property (nonatomic, weak) AVCaptureVideoPreviewLayer *previewLayer;

/** 捕捉画面执行的线程队列 */
@property (nonatomic, strong) dispatch_queue_t captureQueue;
@end

int flush_encoder3(AVFormatContext * fmt_ctx, unsigned int stream_index) {
    int ret;
    int got_frame;
    AVPacket enc_pkt;
    if (!(fmt_ctx->streams[stream_index]->codec->codec->capabilities & AV_CODEC_CAP_DELAY)) {
        return 0;
    }
    while (true) {
        enc_pkt.data = NULL;
        enc_pkt.size = 0;
        av_init_packet(&enc_pkt);
        ret = avcodec_encode_video2(fmt_ctx->streams[stream_index]->codec
                                    , &enc_pkt,
                                    NULL, &got_frame);
        av_frame_free(NULL);
        if (ret < 0) {
            break;
        }
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

@implementation H264EncoderViewController


- (instancetype)init
{
    self = [super init];
    if (self) {
        [self initFFmpeg];
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // 1.创建捕捉会话
    AVCaptureSession *session = [[AVCaptureSession alloc] init];
    session.sessionPreset = AVCaptureSessionPreset640x480;
    self.captureSession = session;
    
    // 2.设置输入设备
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    NSError *error = nil;
    AVCaptureDeviceInput *input = [[AVCaptureDeviceInput alloc] initWithDevice:device error:&error];
    [session addInput:input];
    
    
    // 4.添加预览图层
    AVCaptureVideoPreviewLayer *previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:session];
    previewLayer.frame = CGRectMake(0, 130, self.view.bounds.size.width, 480);
    [self.view.layer insertSublayer:previewLayer atIndex:0];
    self.previewLayer = previewLayer;
    
    // 3.添加输出设备
    AVCaptureVideoDataOutput *output = [[AVCaptureVideoDataOutput alloc] init];
    self.captureQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    [output setSampleBufferDelegate:self queue:self.captureQueue];
    NSDictionary *settings = [[NSDictionary alloc] initWithObjectsAndKeys:
                              [NSNumber numberWithUnsignedInt:kCVPixelFormatType_420YpCbCr8BiPlanarFullRange],
                              kCVPixelBufferPixelFormatTypeKey,
                              nil];
    
    output.videoSettings = settings;
    output.alwaysDiscardsLateVideoFrames = YES;
    // 设置录制视频的方向
    [session addOutput:output];
    
    AVCaptureConnection *connection = [output connectionWithMediaType:AVMediaTypeVideo];
    connection.videoOrientation = AVCaptureVideoOrientationPortrait;
    
    [connection setVideoOrientation:previewLayer.connection.videoOrientation];

}

#pragma mark - 获取到数据
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    [self encoderToH264:sampleBuffer];
}

- (IBAction)startRecoder:(UIButton *)sender {
    [self.captureSession startRunning];
}

- (IBAction)stopRecoder:(UIButton *)sender {
    [self.captureSession stopRunning];
    // 写入剩余数据->可能没有
    flush_encoder3(avformat_context, 0);
    
    // 写入文件尾部信息
    av_write_trailer(avformat_context);
    
    // 释放内存
    avcodec_close(avcodec_context);
    av_free(av_frame);
    av_free(out_buffer);
    av_packet_free(&av_packet);
    avio_close(avformat_context->pb);
    avformat_free_context(avformat_context);
    //    fclose(in_file);
}



#pragma mark - encoderToH264
- (void)encoderToH264:(CMSampleBufferRef)sampleBuffer {
    // 1.通过CMSampleBufferRef对象获取CVPixelBufferRef对象
    CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    
    // 2.锁定imageBuffer内存地址开始进行编码
    if (CVPixelBufferLockBaseAddress(pixelBuffer, 0) == kCVReturnSuccess) {
//         3.从CVPixelBufferRef读取YUV的值
//         NV12和NV21属于YUV格式，是一种two-plane模式，即Y和UV分为两个Plane，但是UV（CbCr）为交错存储，而不是分为三个plane
        // 3.1.获取Y分量的地址
//        uint8_t * bufferPtr = (uint8_t *)CVPixelBufferGetBaseAddressOfPlane(imageBuffer,0);
//        // 3.2.获取UV分量的地址
//        uint8_t *bufferPtr1 = (uint8_t *)CVPixelBufferGetBaseAddressOfPlane(imageBuffer,1);
//
//        // 3.3.根据像素获取图片的真实宽度&高度
//        size_t width = CVPixelBufferGetWidth(imageBuffer);
//        size_t height = CVPixelBufferGetHeight(imageBuffer);
//        // 获取Y分量长度
//        size_t bytesrow0 = CVPixelBufferGetBytesPerRowOfPlane(imageBuffer,0);
//        size_t bytesrow1  = CVPixelBufferGetBytesPerRowOfPlane(imageBuffer,1);
//        uint8_t * yuv420_data = (uint8_t *)malloc(width * height *3/2);
//
//        /* convert NV12 data to YUV420*/
//        // 3.4.将NV12数据转成YUV420数据
//        uint8_t *pY = bufferPtr ;
//        uint8_t *pUV = bufferPtr1;
//        uint8_t *pU = yuv420_data + width * height;
//        uint8_t *pV = pU + width*height / 4;
//        for(int i =0;i<height;i++)
//        {
//            memcpy(yuv420_data+i*width,pY+i*bytesrow0,width);
//        }
//        for(int j = 0;j<height/2;j++)
//        {
//            for(int i =0;i<width/2;i++)
//            {
//                *(pU++) = pUV[i<<1];
//                *(pV++) = pUV[(i<<1) + 1];
//            }
//            pUV+=bytesrow1;
//        }

        size_t pixelWidth = CVPixelBufferGetWidth(pixelBuffer);
        //图像高度（像素）
        size_t pixelHeight = CVPixelBufferGetHeight(pixelBuffer);
        //yuv中的y所占字节数
        size_t y_size = pixelWidth * pixelHeight;
        
        // 2. yuv中的u和v分别所占的字节数
        size_t uv_size = y_size / 4;
        
        uint8_t *yuv_frame = malloc(uv_size * 2 + y_size);
        
        //获取CVImageBufferRef中的y数据
        uint8_t *y_frame = CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 0);
        memcpy(yuv_frame, y_frame, y_size);
        
        //获取CMVImageBufferRef中的uv数据
        uint8_t *uv_frame = CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 1);
        memcpy(yuv_frame + y_size, uv_frame, uv_size * 2);
        
        
        // 3.5.分别读取YUV的数据
        av_frame->data[0] = y_frame;              // Y
        av_frame->data[1] = y_frame + y_size;      // U
        av_frame->data[2] = y_frame + y_size * 5 / 4;  // V
        
        // 4.设置当前帧
        av_frame->pts = i;
        
        // 视频编码处理
        // 发起一帧视频像素数据
        avcodec_send_frame(avcodec_context, av_frame);
        // 接收一帧视频像素数据->编码为视频压缩数据格式
        result = avcodec_receive_packet(avcodec_context, av_packet);
        if (result == 0) {
            // 编码成功
            // 将视频压缩数据->写入到输出文件中
            av_packet->stream_index = av_video_stream->index;
            result = av_write_frame(avformat_context, av_packet);
            NSLog(@"当前是第%d帧", current_frame_index);
            current_frame_index++;
            if (result < 0) {
                NSLog(@"输出一帧数据失败");
                return;
            }
        }
        
       
        // 7.释放yuv数据
//        free(yuv420_data);
    }
    
    CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
}

#pragma mark - init ffmpeg
- (void)initFFmpeg {
    NSString * documentPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject;
    NSString * outFilePath = [NSString stringWithFormat:@"%@/test.h264", documentPath];
//    NSString * inFilePath = [[NSBundle mainBundle] pathForResource:@"Test" ofType:@"yuv"];
    
    // 第一步：注册组件->编码器、解码器等等…
    avformat_network_init();
    
    // 第二步：初始化封装格式上下文
    avformat_context = avformat_alloc_context();
    // 获取视频压缩数据格式类型（h264、h265）
    AVOutputFormat * avoutput_format = av_guess_format(NULL, outFilePath.UTF8String, NULL);
    // 指定类型
    avformat_context->oformat = avoutput_format;
    
    // 第三步：打开输入文件
    if (avio_open(&avformat_context->pb, outFilePath.UTF8String, AVIO_FLAG_WRITE) < 0) {
        NSLog(@"打开输入文件失败");
        return;
    }
    
    // 第四步：创建输出码流->创建一块内存空间->设置为视频流
    av_video_stream = avformat_new_stream(avformat_context, NULL);
    
    // 第五步、查找视频编码器
    // 5.1 获取编码器上下文
    avcodec_context = av_video_stream->codec;
    // 5.2 设置编码器上下文参数  上下文种类：视频解码器、视频编码器、音频解码器、音频编码器
    // 设置编码器id
    avcodec_context->codec_id = avoutput_format->video_codec;
    //  设置为视频编码器
    avcodec_context->codec_type = AVMEDIA_TYPE_VIDEO;
    // 5.3 设置读取像素数据格式->编码的是像素数据格式->视频像素数据格式->YUV420P(YUV422P、YUV444P等等...)
    // 这个类型是根据解码的时候指定的解码视频像素数据格式类型
    avcodec_context->pix_fmt = AV_PIX_FMT_YUV420P;
    // 5.4 设置视频宽高->视频尺寸
    avcodec_context->width = 640;
    avcodec_context->height = 352;
    // 5.5 设置帧率  每秒25帧
    avcodec_context->time_base.num = 1;
    avcodec_context->time_base.den = 25;
    // 5.6 设置码率
    // 码率：每秒传送的比特(bit)数单位为 bps(Bit Per Second)，比特率越高，传送数据速度越快 --单位：bps，"b"表示数据量，"ps"表示每秒
    // 视频码率： 视频码率就是数据传输时单位时间传送的数据位数，一般我们用的单位是kbps即千位每秒
    // 视频码率计算方法：【码率】(kbps)=【视频大小 - 音频大小】(bit位) /【时间】(秒)
    //视频大小 = 1.34MB（文件占比：77%） = 1.34MB * 1024 * 1024 * 8 = 字节大小 = 468365字节 = 468Kbps
    //音频大小 = 376KB（文件占比：21%）
    //计算出来值->码率 : 468Kbps->表示1000，b表示位(bit->位)
    //总结：码率越大，视频越大
    avcodec_context->bit_rate = 468000;
    // 5.7 设置GOP -> 影响视频质量问题
    // MPEG格式画面类型：3种类型->分为->I帧、P帧、B帧
    // I帧->内部编码帧->原始帧(原始视频数据)
    //    完整画面->关键帧(必需的有，如果没有I，那么你无法进行编码，解码)
    //    视频第1帧->视频序列中的第一个帧始终都是I帧，因为它是关键帧
    // P帧->向前预测帧->预测前面的一帧类型，处理数据(前面->I帧、B帧)
    //    P帧数据->根据前面的一帧数据->进行处理->得到了P帧
    // B帧->前后预测帧(双向预测帧)->前面一帧和后面一帧
    //    B帧压缩率高，但是对解码性能要求较高。
    // 总结：I只需要考虑自己 = 1帧，P帧考虑自己+前面一帧 = 2帧，B帧考虑自己+前后帧 = 3帧
    //    说白了->P帧和B帧是对I帧压缩
    // 每250帧，插入1个I帧，I帧越少，视频越小->默认值->视频不一样
    avcodec_context->gop_size = 250;
    // 5.8 设置量化参数，量化参数越小。视频越是清晰
    // 一般情况下是默认值最小量化系数默认是10，最大量化参数默认是51
    avcodec_context->qmin = 10;
    avcodec_context->qmax = 51;
    // 5.9 设置b帧最大值->设置不需要B帧
    avcodec_context->max_b_frames = 0;
    
    // 设置可选参数
    AVDictionary * param = 0;
    if (avcodec_context->codec_id == AV_CODEC_ID_H264) {
        //需要查看x264源码->x264.c文件
        //第一个值：预备参数
        //key: preset
        //value: slow->慢
        //value: superfast->超快
        av_dict_set(&param, "preset", "slow", 0);
        //第二个值：调优
        //key: tune->调优
        //value: zerolatency->零延迟
        av_dict_set(&param, "tune", "zerolatency", 0);
    }
    
    // 查找h264编码器
    AVCodec * avcodec = avcodec_find_encoder(avcodec_context->codec_id);
    if (avcodec == NULL) {
        NSLog(@"没有找到编码器");
    }
    NSLog(@"找到编码器name = %s", avcodec->name);
    
    // 第六步、打开视频编码器
    int avcodec_open2_result = avcodec_open2(avcodec_context, avcodec, &param);
    if (avcodec_open2_result < 0) {
        NSLog(@"打开编码器失败");
        return;
    }
    
    NSLog(@"打开编码器成功");
    
    
    // 第七步、写入文件头信息
    int avformat_write_header_header = avformat_write_header(avformat_context, NULL);
    NSLog(@"写入头文件 = %d", avformat_write_header_header);
    
    // 第八步、循环编码yuv文件->视频像素数据(yuv格式)->编码->h264格式
    // 8.1定义一个缓冲区 缓存一帧视频像素数据
    // 获取缓冲区大小
    int buffer_size = av_image_get_buffer_size(avcodec_context->pix_fmt,
                                               avcodec_context->width,
                                               avcodec_context->height,
                                               1);
    // 创建一个缓冲区
    y_size = avcodec_context->width * avcodec_context->height;
    out_buffer = (uint8_t *)av_malloc(buffer_size);
    
//    // 打开输入文件
//    FILE * in_file = fopen(inFilePath.UTF8String, "rb");
//    if (in_file == NULL) {
//        NSLog(@"文件不存在");
//        return;
//    }
//    NSLog(@"打开文件成功");
    
    // 8.2 开辟一块内存空间  av_frame_alloc
    // 开辟了一块内存空间
    av_frame = av_frame_alloc();
    // 设置缓存区和AVframe类型保持一致 填充数据
    av_image_fill_arrays(av_frame->data,
                         av_frame->linesize,
                         out_buffer,
                         avcodec_context->pix_fmt,
                         avcodec_context->width,
                         avcodec_context->height,
                         1);
    // 接收一帧视频像素数据->编码为->视频压缩数据格式
    av_packet = (AVPacket *)av_malloc(buffer_size);
    
    i = 0;
    result = 0;
    current_frame_index = 1;
}
@end
