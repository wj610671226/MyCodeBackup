//
//  AudioToolboxDemoViewController.swift
//  AVFounctionStudy
//
//  Created by mac on 2018/10/31.
//  Copyright © 2018 mac. All rights reserved.
//

import UIKit
import AVFoundation

class AudioToolboxDemoViewController: UIViewController {

    
    private let session = AVCaptureSession()
    
    private let videoEncode = H264Encoder()
    private let audioEncode = AACEncoder()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        session.sessionPreset = .vga640x480
        // 创建视频输入
        let devices: [AVCaptureDevice] = AVCaptureDevice.devices(for: .video)
        guard let frontDevices = devices.filter({ return $0.position == .back }).first else {
            print("没有可用的前置摄像头")
            return
        }
        guard let videoInput = try? AVCaptureDeviceInput(device: frontDevices) else { return }
        if session.canAddInput(videoInput) {
            session.addInput(videoInput)
        }
        
        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey : kCVPixelFormatType_420YpCbCr8BiPlanarFullRange] as [String : Any]
        videoOutput.alwaysDiscardsLateVideoFrames = false
        let queue = DispatchQueue.global()
        videoOutput.setSampleBufferDelegate(self, queue: queue)
        if session.canAddOutput(videoOutput) {
            session.addOutput(videoOutput)
        }
        // 设置视频录制方向
        let connection = videoOutput.connection(with: AVMediaType.video)
        connection?.videoOrientation = .portrait
        
        
        // 音频操作
        guard let audioDevide = AVCaptureDevice.default(for: AVMediaType.audio) else {
            print("没有可用的音频设备")
            return
        }
        guard let audioInput = try? AVCaptureDeviceInput.init(device: audioDevide) else { return }
        let audioOutput = AVCaptureAudioDataOutput()
        audioOutput.setSampleBufferDelegate(self, queue: queue)
        
        if session.canAddInput(audioInput) {
            session.addInput(audioInput)
        }
        
        if session.canAddOutput(audioOutput) {
            session.addOutput(audioOutput)
        }
        
        // 添加预览图层
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.frame = view.bounds
        view.layer.addSublayer(previewLayer)
    }
    
    @IBAction func stopRecord(_ sender: UIBarButtonItem) {
        session.stopRunning()
        audioEncode.stopEncodeAudio()
        videoEncode.stopEncode()
    }
    
    @IBAction func startRecord(_ sender: UIBarButtonItem) {
        session.startRunning()
    }
    
    
    deinit {
        print("deinit")
    }
}

extension AudioToolboxDemoViewController : AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureAudioDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        if output.isKind(of: AVCaptureAudioDataOutput.self) {
            audioEncode.encodeAudioSampleBuffer(sampleBuffer)
        } else {
            videoEncode.encodeH264(sampleBuffer)
        }
    }
}

