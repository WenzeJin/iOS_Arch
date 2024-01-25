//
//  MainView.swift
//  MyAlbum
//
//  Created by nju on 2022/12/14.
//

import UIKit


class MainView: UIViewController {

    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var photoButton: UIButton!
    var photo: UIImage = UIImage()
    override func viewDidLoad() {
        super.viewDidLoad()
        photoButton.layer.cornerRadius = 10
        cameraButton.layer.cornerRadius = 10
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)

        // Do any additional setup after loading the view.
    }
    
    @IBAction func takePicture(_ sender: Any) {
        presentPhotoPicker(sourceType: .camera)
    }
    
    @IBAction func choosePhoto(_ sender: Any) {
        presentPhotoPicker(sourceType: .photoLibrary)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ToPhotoView"{
            let photoView = segue.destination as! PhotoView
            photoView.image = self.photo
            PhotoView.allImages.append(self.photo)
            PhotoView.allLabels.updateValue(ImageLabel(), forKey: self.photo)
        }
    }
    
    func presentPhotoPicker(sourceType: UIImagePickerController.SourceType) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = sourceType
        present(picker, animated: true)
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension MainView: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  func imagePickerController(_ picker:  UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    picker.dismiss(animated: true)

      self.photo = info[.originalImage] as! UIImage
      self.performSegue(withIdentifier: "ToPhotoView", sender: self)
  }
}
