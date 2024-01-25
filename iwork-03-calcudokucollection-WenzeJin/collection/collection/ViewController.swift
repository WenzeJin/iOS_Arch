//
//  ViewController.swift
//  collection
//
//  Created by 金文泽 on 2023/11/9.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func aboutClick(_ sender: UIButton) {
        let alertController = UIAlertController(title: "致谢", message: "题库来源：\nhttps://files.krazydad.com/inkies", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "好的", style: .default, handler: nil)
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
    }
    


}

