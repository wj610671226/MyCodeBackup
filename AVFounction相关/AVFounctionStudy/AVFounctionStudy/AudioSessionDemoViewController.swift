//
//  AudioSessionDemoViewController.swift
//  AVFounctionStudy
//
//  Created by mac on 2018/9/13.
//  Copyright © 2018年 mac. All rights reserved.
//

import UIKit
import AVFoundation

class AudioSessionDemoViewController: UIViewController {

    private var player: AVAudioPlayer?
    private var recoder: AVAudioRecorder?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        settingSession()
        
        audioPlayer()
        
        audioRecorderDemo()

        
    }

    private func settingSession() {
        // 配置音频会话
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSessionCategoryPlayback)
            try audioSession.setActive(true)
        } catch let error {
            print("error = \(error)")
        }
        // 配置音频后台播放
        // 在info.plist 中添加  Required background modes  item = App plays audio or streams audio/video using AirPlay
    }
    
    
    // MARK: - AVAudioRecorder
    private func audioRecorderDemo() {
        // 需要在info.list中配置麦克风权限
        let path = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.allDomainsMask, true).last! + "/voice.caf"
        let url = URL(fileURLWithPath: path)
        do {
            /*
             AVAudioRecorder 支持无限时长的录制，支持录制一段时间后暂停，再从这个点开始继续录制
             AVFormatIDKey 音频格式 这个格式要和url地址提供的一致
             AVSampleRateKey 采样率
             AVNumberOfChannelsKey 声道数
             */
            recoder = try AVAudioRecorder.init(url: url, settings: [AVFormatIDKey : kAudioFormatAppleIMA4, AVSampleRateKey: 44100.0, AVNumberOfChannelsKey: 1, AVEncoderBitDepthHintKey: 16, AVEncoderAudioQualityKey: AVAudioQuality.medium])
            recoder?.prepareToRecord()
            recoder?.delegate = self
            // 开启音频数据测量
//            recoder?.isMeteringEnabled = true
            // 获取音频平均分贝值的大小 0 ~ -160db
//            recoder?.averagePower(forChannel: <#T##Int#>)
            // 获取音频峰值分贝数据大小
//            recoder?.peakPower(forChannel: <#T##Int#>)
        } catch let error {
            print("error = \(error)")
        }
    }
    
    @IBAction func clickRecoder(_ sender: Any) {
        print("开始录制")
        recoder?.record()
    }
    
    
    @IBAction func pauseRecoder(_ sender: Any) {
        recoder?.pause()
        print("暂停录制")
    }
    
    @IBAction func stopRecoder(_ sender: Any) {
        recoder?.stop()
        print("结束录制")
    }
    
    // MARK: - AVAudioPlayer
    private func audioPlayer() {
        // AVAudioPlayer 播放音频
        let url = Bundle.main.url(forResource: "test", withExtension: "mp3")
        do {
            player = try AVAudioPlayer.init(contentsOf: url!)
            player?.numberOfLoops = -1
            // 制造和处理中断事件  例如： 当有电话呼入的时候
            NotificationCenter.default.addObserver(self, selector: #selector(handleNotification(_:)), name: .AVAudioSessionInterruption, object: nil)
            // 音频线路改变的通知 例如插入耳机
            NotificationCenter.default.addObserver(self, selector: #selector(handleRouteNotification(_:)), name: .AVAudioSessionRouteChange, object: nil)
            player?.prepareToPlay()
        } catch let error {
            print("error = \(error)")
        }
    }
    
    @IBAction func clickPlayMp3(_ sender: Any) {
        player?.play()
    }
    
    @objc func handleNotification(_ sender: Notification) {
        let info = sender.userInfo!
        let type = info["AVAudioSessionInterruptionTypeKey"] as! UInt
        if type == AVAudioSessionInterruptionType.began.rawValue {
            print("开始")
            player?.pause()
        } else {
            print("结束")
            player?.play()
        }
    }
    
    @objc func handleRouteNotification(_ sender: Notification) {
        let info = sender.userInfo!
        let reasonKey = info["AVAudioSessionRouteChangeReasonKey"] as! UInt
        if AVAudioSessionRouteChangeReason.oldDeviceUnavailable.rawValue == reasonKey  {
            print("耳机取出, 暂停播放")
            player?.pause()
        }
    }
}



extension AudioSessionDemoViewController: AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        print("录制音频 停止 对录制的音频做处理，保存？删除？ audioRecorderDidFinishRecording")
    }
}
