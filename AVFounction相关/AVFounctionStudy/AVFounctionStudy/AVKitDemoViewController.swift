//
//  AVKitDemoViewController.swift
//  AVFounctionStudy
//
//  Created by mac on 2018/9/18.
//  Copyright © 2018年 mac. All rights reserved.
//

import UIKit
import AVKit
import MediaPlayer

class AVKitDemoViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        
        let avplayer = AVPlayerViewController()
        // 是否显示底部播放控制条
        avplayer.showsPlaybackControls = false
        let url = Bundle.main.url(forResource: "Test", withExtension: "mov")
        avplayer.player = AVPlayer(url: url!)
        avplayer.view.frame = UIScreen.main.bounds
        view.addSubview(avplayer.view)
        avplayer.player?.play()
    }
}
