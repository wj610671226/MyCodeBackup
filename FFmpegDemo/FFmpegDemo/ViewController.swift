//
//  ViewController.swift
//  FFmpegDemo
//
//  Created by mac on 2018/8/10.
//  Copyright © 2018年 mac. All rights reserved.
//

import UIKit


class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        testFFmpeg()
    }
    
    
    func audioDecode() {
        /*
         开发步骤
         注册组件
         打开封装文件
         查找视频流
         查找视频流解码器
         打开解码器
         读取视频压缩数据->循环读取
         视频解码->播放视频->得到视频像素数据
         关闭解码器->解码完成
         */
        
        // 注册组件
        // av_register_all() 过期
        avformat_network_init()
        
        // 打开封装格式
        var formatContext = avformat_alloc_context()
        let videoPath = Bundle.main.path(forResource: "Test", ofType: "mov")
        guard let path = videoPath else {
            print("视频不存在")
            return
        }
        
        let url:UnsafePointer<Int8> = (path as NSString).utf8String!
        let result: Int32 = avformat_open_input(&formatContext, url, nil, nil)
        guard result == 0 else {
            print("文件打开失败 result = \(result)")
            return
        }
        print("文件打开成功")
        
        // 查找视频流
        // result ->  >=0 if OK, AVERROR_xxx on error
        let stream_info : Int32 = avformat_find_stream_info(formatContext, nil)
        if stream_info < 0 {
            print("查找视频流失败")
            return
        }
        print("查找视频流成功")
        
        // 查找视频流解码器
//        let stream_index = -1;
        
//        unsigned int nb_streams;
//        AVStream **streams;
        
//        let rawPointer = withUnsafePointer(to: &formatContext, { UnsafeRawPointer($0)})
//        let nb_streams = rawPointer.load(fromByteOffset: 0, as: Int.self)
//        print("nb_streams = \(nb_streams)")
//        withUnsafePointer
//        for i in 0..<formatContext->nb_streams {
//            print("i = \(i)")
//        }
    }

    func testFFmpeg() {
        let filePath = Bundle.main.path(forResource:"Test", ofType: "mov")
        avformat_network_init();
        var avformat_context = avformat_alloc_context()
        let url = (filePath! as NSString).utf8String!
        let result = avformat_open_input(&avformat_context, url, nil, nil)
        guard result == 0 else {
            print("打开文件失败")
            return
        }
        print("打开文件成功")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        print("didReceiveMemoryWarning")
    }


}

