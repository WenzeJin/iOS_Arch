//
//  ViewController.swift
//  calculator
//
//  Created by 金文泽 on 2023/9/29.
//

import UIKit

// TODO: arc mode

class ViewController: UIViewController {
    
    @IBOutlet weak var arcLabel: UILabel!
    @IBOutlet weak var DRLabel: UILabel!
    @IBOutlet weak var resLabel: UILabel!
    
    var inputNumber: Bool = false     //is a number being input
    var isFloat: Bool = false          //does the number has point now
    var positive: Bool = true         //is number of display positive
    var AC: Bool = false              //AC or C
    var clear = true            //is the calculator cleared
    let cal = Calculator()      //initialize calculator
    
    var arc = false
    var tfunctionIn = ["sinx", "cosx", "tanx", "sinhx", "coshx", "tanhx"]
    var tfunctionOut = ["asinx", "acosx", "atanx", "asinhx", "acoshx", "atanhx"]
    var constNums = ["pi", "e"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        resLabel.text = "0"
        arcLabel.text = ""
    }
    
    @IBAction func numberTouched(_ sender: UIButton) {
        let inputStr = sender.titleLabel!.text!
        if inputNumber {
            //If an non-zero number has been added
            if inputStr == "." {
                if !isFloat {
                    //make sure that there's only one point in the number
                    resLabel.text!.append(inputStr)
                    isFloat = true
                }
            } else {
                resLabel.text!.append(inputStr)
            }
        } else {
            if inputStr != "0" {
                //The first digit should not be "0" but can be "."
                inputNumber = true
                clear = false
                AC = false
                if inputStr == "." {
                    //If inputStr is ".", initial is "0."
                    resLabel.text! = "0."
                    isFloat = true
                } else {
                    //If inputStr is any other digit, "0" will be replaced, but "-" will be kept
                    if positive {
                        resLabel.text! = inputStr
                    } else {
                        resLabel.text! = "-" + inputStr
                    }
                }
            }
        }
    }
    
    @IBAction func controlTouched(_ sender: UIButton) {
        let inputStr = sender.titleLabel!.text!
        if inputStr == "AC/C" && !AC{
            //Clear: reset
            resLabel.text = "0"
            inputNumber = false
            isFloat = false
            positive = true
            AC = true
        } else if inputStr == "AC/C" && AC {
            cal.performControl("AC")
            resLabel.text = "0"
            inputNumber = false
            isFloat = false
            positive = true
            clear = true
            AC = false
        } else if inputStr == "+/-" {
            if positive == true {
                resLabel.text! = "-" + resLabel.text!
            } else {
                resLabel.text!.remove(at: resLabel.text!.startIndex)
            }
            positive = !positive
        } else if inputStr == "D/R" {
            cal.performControl("D/R")
            DRLabel.text = cal.getDRMode()
        }
    }
    
    @IBAction func operatorTouched(_ sender: UIButton) {
        var opr = sender.titleLabel!.text!
        print("Number \(sender.titleLabel!.text!) has been touched.")
        if inputNumber || !clear || constNums.contains(opr){
            //a number has to be input
            if tfunctionIn.contains(opr) || tfunctionOut.contains(opr) {
                if arc {
                    opr = "a" + opr
                }
            }
            if !constNums.contains(opr){
                cal.numberInput(Double(resLabel.text!) ?? 0.0)
                inputNumber = false
            } else {
                inputNumber = true
            }
            cal.performOperation(opr)
            resLabel.text = cal.getDisplay()
            if cal.getDisplay() == "错误" {
                AC = true
            } else {
                positive = Double(resLabel.text!)! >= 0
            }
        }
    }
    
    @IBAction func storageTouched(_ sender: UIButton) {
        let opr = sender.titleLabel!.text!
        if inputNumber || !clear {
            cal.numberInput(Double(resLabel.text!) ?? 0.0)
            cal.performOperation(opr)
            resLabel.text = cal.getDisplay()
            positive = Double(resLabel.text!)! >= 0
            inputNumber = false
        }
    }
    
    @IBAction func bracketTouched(_ sender: UIButton) {
        let bra = sender.titleLabel!.text!
        if inputNumber || !clear {
            cal.numberInput(Double(resLabel.text!) ?? 0.0)
            cal.performBracket(bra)
            resLabel.text = cal.getDisplay()
            positive = Double(resLabel.text!)! >= 0
            inputNumber = false
        }
    }
    
    @IBAction func arcTouched(_ sender: UIButton) {
        if !arc {
            arc = true
            arcLabel.text = "ARC"
        } else {
            arcLabel.text = ""
            arc = false
        }
    }
    
}

