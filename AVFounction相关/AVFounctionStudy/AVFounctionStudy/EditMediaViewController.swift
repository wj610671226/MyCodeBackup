//
//  EditMediaViewController.swift
//  AVFounctionStudy
//
//  Created by mac on 2018/10/29.
//  Copyright © 2018 mac. All rights reserved.
//  媒体的组合

import UIKit
import AVFoundation

class EditMediaViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let videoMov = Bundle.main.url(forResource: "Test", withExtension: "mov")
        let videoMovAsset = AVURLAsset.init(url: videoMov!)
        
        let audioMp3 = Bundle.main.url(forResource: "test", withExtension: "mp3")
        let audioMp3Asset = AVURLAsset.init(url: audioMp3!)
        
        let composition = AVMutableComposition()
        
        // video
        let videoTrack = composition.addMutableTrack(withMediaType: AVMediaType.video, preferredTrackID: kCMPersistentTrackID_Invalid)
        
        // audio
        let audioTrack = composition.addMutableTrack(withMediaType: AVMediaType.audio, preferredTrackID: kCMPersistentTrackID_Invalid)
        
        // 视频
        let cursorTime = kCMTimeZero
        let videoDurtion = CMTimeMake(10, 1)
        let videoTimeRange = CMTimeRangeMake(kCMTimeZero, videoDurtion)
        var assetTrack = videoMovAsset.tracks(withMediaType: AVMediaType.video).first
        do {
            try videoTrack?.insertTimeRange(videoTimeRange, of: assetTrack!, at: cursorTime)
        } catch let error {
            print(" video error = \(error.localizedDescription)")
        }
        
        // 音频
        let audioDurtion = CMTimeMake(10, 1)
        let range = CMTimeRangeMake(kCMTimeZero, audioDurtion)
        assetTrack = audioMp3Asset.tracks(withMediaType: AVMediaType.audio).first
        do {
            try audioTrack?.insertTimeRange(range, of: assetTrack!, at: cursorTime)
        } catch let error {
            print("audio error = \(error.localizedDescription)")
        }
        
        let outputUrl = URL(fileURLWithPath: "/Users/mac/Documents/iOSProject/AVFounctionStudy/AVFounctionStudy/edit.mp4")
        let session = AVAssetExportSession(asset: composition, presetName: AVAssetExportPreset640x480)
        session?.outputFileType = AVFileType.mp4
        session?.outputURL = outputUrl
        session?.exportAsynchronously(completionHandler: {
            if AVAssetExportSessionStatus.completed == session?.status {
                print("导出成功")
            } else {
                print("导出失败 = \(session?.error?.localizedDescription ?? "nil")")
            }
        })
        
    }

}
