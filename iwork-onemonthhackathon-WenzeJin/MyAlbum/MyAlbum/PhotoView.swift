//
//  PhotoView.swift
//  MyAlbum
//
//  Created by nju on 2022/12/14.
//

import Vision
import UIKit

class ImageLabel {
    var label: String
    var marked = false
    var confident = 0.0
    init(){
        self.label = ""
    }
}

class PhotoView: UIViewController {

    @IBOutlet weak var resultLabel: UILabel!
    static var allLabels = [UIImage:ImageLabel]()
    static var allImages = [UIImage]()
    static var classify: [String: [UIImage]] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = image
        if let label = PhotoView.allLabels[image!]{
            if label.marked{
                if label.label != "Not Sure"{
                    resultLabel.text! = String(format: "%@ %.1f%%", label.label, label.confident * 100)
                }else{
                    resultLabel.text! = "Not Sure"
                }
            }
            else{
                classify(image: image!)
            }
        }
    }
    
    var image: UIImage? = nil
    @IBOutlet weak var imageView: UIImageView!
    
    lazy var classifyRequest :VNCoreMLRequest = {
        do{
            let snackeClassify = try SnackClassify(configuration: MLModelConfiguration())
            let model = try VNCoreMLModel(for: snackeClassify.model)
            
            let request = VNCoreMLRequest(model: model, completionHandler: {
                [weak self] request, error in
                self?.processObservations(for: request, error: error)
            })
            request.imageCropAndScaleOption = .centerCrop
            return request
        }catch{
            fatalError()
        }
    }()
    
    func classify(image: UIImage) {
        //TODO: use VNImageRequestHandler to perform a classification request
        if let ciImage = CIImage(image: image){
          let orientation = CGImagePropertyOrientation(image.imageOrientation)
          DispatchQueue.global(qos: .userInitiated).async {
            let handle = VNImageRequestHandler(ciImage: ciImage, orientation: orientation)
            do{
                try handle.perform([self.classifyRequest])
            } catch{
                fatalError()
            }
          }
        }
    }
    
    func processObservations(for request: VNRequest, error: Error?)
    {
       
        DispatchQueue.main.async {
            let label = PhotoView.allLabels[self.image!]
            label?.marked = true
            if let results = request.results as? [VNClassificationObservation]{
                if results.isEmpty{
                    self.resultLabel!.text = "Nothing Found"
                    label?.label = "Nothing Found"
                }else if results[0].confidence < 0.75{
                    self.resultLabel!.text = "Not Sure"
                    label?.label = "Not Sure"
                    if PhotoView.classify["Not Sure"] != nil{
                        PhotoView.classify["Not Sure"]?.append(self.image!)
                    }else{
                        PhotoView.classify.updateValue([self.image!], forKey: "Not Sure")
                        print("creat")
                    }
                }else{
                    self.resultLabel!.text = String(format: "%@ %.1f%%", results[0].identifier, results[0].confidence * 100)
                    label?.label = results[0].identifier
                    label?.confident = Double(results[0].confidence)
                    if PhotoView.classify[results[0].identifier] != nil {
                        PhotoView.classify[results[0].identifier]?.append(self.image!)
                    }else{
                        PhotoView.classify.updateValue([self.image!], forKey: results[0].identifier)
                    }
                }
            }else{
                self.resultLabel!.text = "Error in MLModel"
            }
        }
    }

}


