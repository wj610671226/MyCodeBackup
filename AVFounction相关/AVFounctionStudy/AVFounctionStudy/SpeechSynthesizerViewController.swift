//
//  SpeechSynthesizerViewController.swift
//  AVFounctionStudy
//
//  Created by mac on 2018/9/13.
//  Copyright © 2018年 mac. All rights reserved.
//  播放文本

import UIKit
import AVFoundation

class SpeechSynthesizerViewController: UIViewController {

    private let speechSynthesizer = AVSpeechSynthesizer()
    private let voices: [AVSpeechSynthesisVoice] = [AVSpeechSynthesisVoice(language: "en-US")!, AVSpeechSynthesisVoice(language: "en-GB")!]
    private let speechString: [String] = ["The forum, which will bring together over 1,000 delegates, will be attended by special guests including the former French Prime Minister Jean-Pierre Raffarin, the 2011 Nobel Prize winner for Economics Thomas J.", "Sargent, and Zhu Yeyu, the vice3 president of the Hong Kong University of Science and Technology.", " Co-hosted by China Media Group and the People's Government of Guangdong Province, the forum will showcase the achievements of Guangdong Province in becoming a major gateway4 linking China with the world.", "The province also provides an example of the benefits of China's policy of Reform and Opening Up, which celebrates its 40th anniversary this year."]

    override func viewDidLoad() {
        super.viewDidLoad()
        // 获取所有声音支持列表
        print(AVSpeechSynthesisVoice.speechVoices())
    }
    
    @IBAction func clickPlay(_ sender: UIButton) {
        for index in 0..<speechString.count {
            let utterance = AVSpeechUtterance(string: speechString[index])
            utterance.voice = voices[index % 2]
            utterance.rate = 0.4
            utterance.pitchMultiplier = 0.8
            utterance.postUtteranceDelay = 0.1
            speechSynthesizer.speak(utterance)
        }
    }
}
