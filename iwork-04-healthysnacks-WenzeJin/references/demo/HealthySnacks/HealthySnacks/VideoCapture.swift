//
//  VideoCapture.swift
//  HealthySnacks
//
//  Created by CuiZihan on 2020/9/26.
//

import AVFoundation
import CoreVideo
import UIKit

public protocol VideoCaptureDelegate: class {
    func videoCapture(capture: VideoCapture, didCaptureVideoFrame: CMSampleBuffer)
}

public class VideoCapture: NSObject {
    public var previewLayer: AVCaptureVideoPreviewLayer?
    public weak var delegate: VideoCaptureDelegate?
    public var frameInterval = 1
    var seenFrames = 0
    
    let captrueSession = AVCaptureSession()
    let videoOutput = AVCaptureVideoDataOutput()
    let queue = DispatchQueue(label: "cn.edu.nju.czh.camera-queue")
    var lastTime = CMTime()
    
    public func setUp(sessionPreset: AVCaptureSession.Preset = .medium, completion: @escaping (Bool)->Void) {
        queue.async {
            let success = self.setUpCamera(sessionPreset: sessionPreset)
            DispatchQueue.main.async {
                completion(success)
            }
        }
    }
    
    private func setUpCamera(sessionPreset: AVCaptureSession.Preset)->Bool {
        self.captrueSession.beginConfiguration()
        self.captrueSession.sessionPreset = sessionPreset
        
        guard let captureDevice = AVCaptureDevice.default(for: .video) else {
            print("Error: Initialize Device failed")
            return false
        }
        
        guard let videoInput = try? AVCaptureDeviceInput(device: captureDevice) else {
            print("Error: could not create video input ")
            return false
        }
        
        if captrueSession.canAddInput(videoInput) {
            captrueSession.addInput(videoInput)
        }
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: captrueSession)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.connection?.videoOrientation = .portrait
        self.previewLayer = previewLayer
        
        let settings: [String: Any] = [
            kCVPixelBufferPixelFormatTypeKey as String: NSNumber(value: kCVPixelFormatType_32BGRA)
        ]
        
        self.videoOutput.videoSettings = settings
        self.videoOutput.alwaysDiscardsLateVideoFrames = true
        self.videoOutput.setSampleBufferDelegate(self, queue: queue)
        if captrueSession.canAddOutput(self.videoOutput) {
            captrueSession.addOutput(self.videoOutput)
        }
        
        videoOutput.connection(with: .video)?.videoOrientation = .portrait
        
        captrueSession.commitConfiguration()
        return true
    }
    
    public func start() {
        if !captrueSession.isRunning {
            seenFrames = 0
            captrueSession.startRunning()
        }
    }
    
    public func stop() {
        if captrueSession.isRunning {
            captrueSession.stopRunning()
        }
    }
}


extension VideoCapture: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    // Because lowering the capture device's FPS looks ugly in the preview,
    // we capture at full speed but only call the delegate at its desired
    // frame rate. If frameInterval is 1, we run at the full frame rate.
    public func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        seenFrames += 1
        if seenFrames >= frameInterval {
            // print("Delegate do capture")
            seenFrames = 0
            delegate?.videoCapture(capture: self, didCaptureVideoFrame: sampleBuffer)
        }
    }

}
