//
//  ViewController.swift
//  HealthySnacks
//
//  Created by CuiZihan on 2020/9/26.
//

import UIKit
import CoreMedia
import CoreML
import Vision

class ViewController: UIViewController {

    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet weak var confidenceLabel: UILabel!
    
    // for video capturing
    var videoCapturer: VideoCapture!
    let semphore = DispatchSemaphore(value: ViewController.maxInflightBuffer)
    var inflightBuffer = 0
    static let maxInflightBuffer = 2
    
    lazy var classificationRequest: VNCoreMLRequest = {
        do{
            let classifier = try HealthySnacks(configuration: MLModelConfiguration())
            
            let model = try VNCoreMLModel(for: classifier.model)
            let request = VNCoreMLRequest(model: model, completionHandler: {
                [weak self] request,error in
                self?.processObservations(for: request, error: error)
            })
            request.imageCropAndScaleOption = .centerCrop
            return request
            
            
        } catch {
            fatalError("Failed to create request")
        }
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.setUpCamera()
    }
    
    func setUpCamera() {
        self.videoCapturer = VideoCapture()
        self.videoCapturer.delegate = self
        
        videoCapturer.frameInterval = 1
        videoCapturer.setUp(sessionPreset: .high, completion: {
            success in
            if success {
                if let previewLayer = self.videoCapturer.previewLayer {
                    self.videoView.layer.addSublayer(previewLayer)
                    self.videoCapturer.previewLayer?.frame = self.videoView.bounds
                    self.videoCapturer.start()
                }
            }
            else {
                print("Video capturer set up failed")
            }
        })
    }
    
    


}

extension ViewController: VideoCaptureDelegate {
    func videoCapture(capture: VideoCapture, didCaptureVideoFrame sampleBuffer: CMSampleBuffer) {
        self.classify(sampleBuffer: sampleBuffer)
    }
}


extension ViewController {
    func classify(sampleBuffer: CMSampleBuffer) {
        if let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) {
            semphore.wait()
            inflightBuffer += 1
            if inflightBuffer >= ViewController.maxInflightBuffer {
                inflightBuffer = 0
            }
            DispatchQueue.main.async {
                let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer)
                do {
                    try handler.perform([self.classificationRequest])
                } catch {
                    print("Failed to perform classification: \(error)")
                }
                self.semphore.signal()
            }
            
        } else {
            print("Create pixel buffer failed")
        }
    }
}

extension ViewController {
    func processObservations(for request: VNRequest, error: Error?) {
        if let results = request.results as? [VNClassificationObservation] {
            if results.isEmpty {
                self.resultLabel.text = "Nothing found"
            } else {
                let result = results[0].identifier
                let confidence = results[0].confidence
                self.resultLabel.text = result
                self.confidenceLabel.text = String(format: "%.1f%%", confidence * 100)
                print(result)
            }
        } else if let error = error {
            self.resultLabel.text = "Error: \(error.localizedDescription)"
        } else {
            self.resultLabel.text = "???"
        }
    }
}
