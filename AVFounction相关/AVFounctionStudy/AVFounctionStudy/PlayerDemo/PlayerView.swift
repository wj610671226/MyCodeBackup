//
//  PlayerView.swift
//  AVFounctionStudy
//
//  Created by mac on 2018/9/17.
//  Copyright © 2018年 mac. All rights reserved.
//

import UIKit
import AVFoundation

class PlayerView: UIView {
    
    
    var avPlayerLayer:AVPlayerLayer!
    
    init(_ frame: CGRect, _ player: AVPlayer) {
        super.init(frame: frame)
        
        avPlayerLayer = AVPlayerLayer(player: player)
        avPlayerLayer.frame = CGRect(x: 0, y: 88, width: UIScreen.main.bounds.width, height: 200)
        avPlayerLayer.backgroundColor = UIColor.green.cgColor
        self.layer.addSublayer(avPlayerLayer)
        
//        let btn = UIButton(frame: CGRect(x: 10, y: 88, width: 100, height: 25))
//        btn.backgroundColor = UIColor.red
//        self.backgroundColor = UIColor.clear
//        self.addSubview(btn)
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name.UIDeviceOrientationDidChange, object: nil, queue: OperationQueue.main) { (notification ) in
            print(notification.userInfo)
        }
    }

    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
