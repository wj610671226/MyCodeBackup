//
//  AVPlayerViewController.swift
//  AVFounctionStudy
//
//  Created by mac on 2018/9/17.
//  Copyright © 2018年 mac. All rights reserved.
//

/*
 
 AVPlayer:是一个用来播放基于时间的视听媒体的控制器对象。它是一个不可见的组件，需要使用AVPlayerLayer才能显示可视化的用户界面
 AVPlayerLayer：用于视频渲染
 
 AVPlayerItem: 用于建立媒体资源动态视角的数据模型并保存AVPlayer在播放资源时呈现的状态。
 */
import UIKit
import AVFoundation

class AVPlayerDemoViewController: UIViewController {

    private var avPlayer: AVPlayer!
    private var playerItem: AVPlayerItem!
    private var asset: AVAsset!
    private var imageGenerator: AVAssetImageGenerator!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let url = Bundle.main.url(forResource: "Test", withExtension: "mov")
        // 网络视频
//        let url = URL.init(string: "http://clips.vorwaerts-gmbh.de/big_buck_bunny.mp4")
        asset = AVAsset(url: url!)
        playerItem = AVPlayerItem(asset: asset)
//        playerItem.addObserver(self, forKeyPath:"status", options: [NSKeyValueObservingOptions.old, NSKeyValueObservingOptions.new] , context: nil)
        avPlayer = AVPlayer(playerItem: playerItem)
        let playerView = PlayerView.init(UIScreen.main.bounds, avPlayer)
        view.addSubview(playerView)
        
//        let avPlayerLayer = AVPlayerLayer(player: avPlayer)
//        avPlayerLayer.frame = CGRect(x: 0, y: 88, width: UIScreen.main.bounds.width, height: 200)
//        self.view.layer.addSublayer(avPlayerLayer)
        
        avPlayer.play()
        
        
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if playerItem.status == .readyToPlay {
            print("readyToPlay")
            // 设置播放监听
            // 监听时间
            addPlayerItemTimeObserver()
            
            // 监听视频播放完成
            addItemEndObserverForPlayerItem()
            
            // 获取视频指定时间点的缩略图
            getGenerateThumbnails()
            
            // 获取字幕信息
            loadMediaOptions()
        }
    }
    
    
    private func loadMediaOptions() {
        // 获取视频包含的字幕信息
        let gropup = asset.mediaSelectionGroup(forMediaCharacteristic: AVMediaCharacteristic.legible)
        if let gropup = gropup {
            var subtitles: [String] = Array()
            for item in gropup.options {
                print("displayName = \(item.displayName)")
                subtitles.append(item.displayName)
            }
        } else {
            print("gropup = nil, 没有字幕信息")
        }
        
    }
    
    private func getGenerateThumbnails() {
        imageGenerator = AVAssetImageGenerator(asset: asset)
        // 设置生成图片的宽高
        imageGenerator.maximumSize = CGSize(width: 200, height: 0)
        
        // 获取20张缩略图
        let duration = asset.duration
        var times: [NSValue] = Array()
        let increment = duration.value / 20
        var currentValue = kCMTimeZero.value
        while currentValue <= duration.value {
            let time = CMTimeMake(currentValue, duration.timescale)
            times.append(NSValue.init(time: time))
            currentValue += increment
        }
        
        var images: [UIImage] = Array()
        imageGenerator.generateCGImagesAsynchronously(forTimes: times) { (requestedTime, cgImage, actualTime, result, error) in
            if result == AVAssetImageGeneratorResult.succeeded {
                let image = UIImage(cgImage: cgImage!)
                images.append(image)
                // 将图片更新到UI组件
            } else {
                print("生成缩略图失败")
            }
        }
    }
    
    private func addItemEndObserverForPlayerItem() {
        NotificationCenter.default.addObserver(forName: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil, queue: OperationQueue.main) { (notification) in
            print("播放完成")
        }
    }
    
    // 监听播放时间
    private func addPlayerItemTimeObserver() {
        /*
         监听时间
         1、定期监听 利用AVPlayer的方法 addPeriodicTimeObserverForInterval:<#(CMTime)#> queue:<#(nullable dispatch_queue_t)#> usingBlock:<#^(CMTime time)block#>
         2、边界时间监听 利用AVPlayer的方法定义边界标记 addBoundaryTimeObserverForTimes:<#(nonnull NSArray<NSValue *> *)#> queue:<#(nullable dispatch_queue_t)#> usingBlock:<#^(void)block#>
         */
        
        // 定义0.5秒时间间隔来更新时间
        let time = CMTimeMakeWithSeconds(0.5, Int32(NSEC_PER_SEC))
        avPlayer.addPeriodicTimeObserver(forInterval: time, queue: DispatchQueue.main) { [weak self] (time) in
            let currentTime = CMTimeGetSeconds(time)
            let duration = CMTimeGetSeconds((self?.playerItem.duration)!)
            print("更新当前播放的时间 = \(currentTime), 视频总时长 = \(duration)")
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
