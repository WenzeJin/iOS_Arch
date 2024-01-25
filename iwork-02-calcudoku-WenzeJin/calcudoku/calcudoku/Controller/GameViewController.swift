//
//  GameViewController.swift
//  calcudoku
//
//  Created by 金文泽 on 2023/10/24.
//

import UIKit


class GameViewController: UIViewController {
    
    var currBlock:UIButton?
    var game:GameState?
    
    
    @IBOutlet weak var b00: UIButton!
    @IBOutlet weak var b01: UIButton!
    @IBOutlet weak var b02: UIButton!
    @IBOutlet weak var b03: UIButton!
    @IBOutlet weak var b04: UIButton!
    @IBOutlet weak var b05: UIButton!
    
    
    @IBOutlet weak var b10: UIButton!
    
    @IBOutlet weak var b11: UIButton!
    
    @IBOutlet weak var b12: UIButton!
    
    @IBOutlet weak var b13: UIButton!
    @IBOutlet weak var b14: UIButton!
    @IBOutlet weak var b15: UIButton!
    
    
    @IBOutlet weak var b20: UIButton!
    @IBOutlet weak var b21: UIButton!
    @IBOutlet weak var b22: UIButton!
    @IBOutlet weak var b23: UIButton!
    @IBOutlet weak var b24: UIButton!
    @IBOutlet weak var b25: UIButton!
    
    @IBOutlet weak var b30: UIButton!
    @IBOutlet weak var b31: UIButton!
    
    @IBOutlet weak var b32: UIButton!
    @IBOutlet weak var b33: UIButton!
    @IBOutlet weak var b34: UIButton!
    @IBOutlet weak var b35: UIButton!
    
    @IBOutlet weak var b40: UIButton!
    @IBOutlet weak var b41: UIButton!
    @IBOutlet weak var b42: UIButton!
    @IBOutlet weak var b43: UIButton!
    @IBOutlet weak var b44: UIButton!
    @IBOutlet weak var b45: UIButton!
    
    @IBOutlet weak var b50: UIButton!
    @IBOutlet weak var b51: UIButton!
    @IBOutlet weak var b52: UIButton!
    @IBOutlet weak var b53: UIButton!
    @IBOutlet weak var b54: UIButton!
    @IBOutlet weak var b55: UIButton!
    
    var bts = [[UIButton]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        game = GameState()
        
        game!.addRule(.DIV, 2, [Position(0,0), Position(0,1)])
        game!.addRule(.ADD, 14, [Position(0,2), Position(0,3), Position(1,3)])
        game!.addRule(.SUB, 3, [Position(0,5), Position(1,5)])
        game!.addRule(.MUL, 90, [Position(1,0), Position(1,1), Position(2,1)])
        game!.addRule(.MUL, 10, [Position(0,4), Position(1,4)])
        game!.addRule(.MUL, 6, [Position(1,2), Position(2,2)])
        game!.addRule(.ADD, 5, [Position(2,0), Position(3,0)])
        game!.addRule(.MUL, 8, [Position(2,3), Position(3,2), Position(3,3)])
        game!.addRule(.SUB, 3, [Position(3,1), Position(4,1)])
        game!.addRule(.DIV, 3, [Position(2,4), Position(2,5)])
        game!.addRule(.SUB, 1, [Position(3,4), Position(3,5)])
        game!.addRule(.SUB, 4, [Position(4,0), Position(5,0)])
        game!.addRule(.ADD, 15, [Position(4,2), Position(5,1), Position(5,2)])
        game!.addRule(.SUB, 1, [Position(4,3), Position(4,4)])
        game!.addRule(.ADD, 7, [Position(5,3), Position(5,4)])
        game!.addRule(.DIV, 3, [Position(4,5), Position(5,5)])
        assert(game!.checkRule())
        
        bts = [
            [b00, b01, b02, b03, b04, b05],
            [b10, b11, b12, b13, b14, b15],
            [b20, b21, b22, b23, b24, b25],
            [b30, b31, b32, b33, b34, b35],
            [b40, b41, b42, b43, b44, b45],
            [b50, b51, b52, b53, b54, b55]
        ]
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    @IBAction func mapClick(_ sender: UIButton) {
        if(currBlock != sender) {
            currBlock?.backgroundColor = UIColor(red:0, green:0, blue:0, alpha: 0)
            currBlock = sender
            currBlock!.backgroundColor = UIColor(red:0.9, green:0.5, blue:0.3, alpha: 0.5)
        } else {
            currBlock!.backgroundColor = UIColor(red:0, green:0, blue:0, alpha: 0)
            currBlock = nil
        }
    }
    
    @IBAction func numClick(_ sender: UIButton) {
        currBlock?.setTitle(sender.titleLabel?.text, for: .normal)
        if currBlock != nil {
            var ii = 0
            var jj = 0
            for i in 0...5 {
                var found = false
                for j in 0...5 {
                    if(currBlock == bts[i][j]){
                        ii = i
                        jj = j
                        found = true
                        break
                    }
                }
                if found {
                    break
                }
            }
            
            let val = Int(sender.titleLabel!.text!)
            let tb = Block(invalid: false, value: val!)
            game!.setBlockAt(ii, jj, tb)
            
            game!.checkInvalidAt(ii, jj)
            
            for i in 0...5 {
                for j in 0...5 {
                    let blc = game!.getBlockAt(i, j)
                    if blc.rError || blc.cError || blc.ruError {
                        bts[i][j].setTitleColor( UIColor(red:1, green:0, blue:0, alpha: 1), for: .normal)
                    } else {
                        bts[i][j].setTitleColor( UIColor(red:0, green:0, blue:0, alpha: 1), for: .normal)
                    }
                }
            }
            
            if game!.gameEnd() {
                let alertController = UIAlertController(title: "游戏结束", message: "🎉您已经成功完成了一组6x6的聪明格，恭喜！🎉", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "好的", style: .default, handler: nil)
                    alertController.addAction(okAction)
                    self.present(alertController, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func clrClick(_ sender: UIButton) {
        currBlock?.setTitle("", for: .normal)
        if currBlock != nil {
            var ii = 0
            var jj = 0
            for i in 0...5 {
                var found = false
                for j in 0...5 {
                    if(currBlock == bts[i][j]){
                        ii = i
                        jj = j
                        found = true
                        break
                    }
                }
                if found {
                    break
                }
            }
            
            let tb = Block(invalid: true, value: 0)
            game!.setBlockAt(ii, jj, tb)
            
            game!.checkInvalidAt(ii, jj)
            
            for i in 0...5 {
                for j in 0...5 {
                    let blc = game!.getBlockAt(i, j)
                    if blc.rError || blc.cError || blc.ruError {
                        bts[i][j].setTitleColor( UIColor(red:1, green:0, blue:0, alpha: 1), for: .normal)
                    } else {
                        bts[i][j].setTitleColor( UIColor(red:0, green:0, blue:0, alpha: 1), for: .normal)
                    }
                }
            }
        }
    }
    
    
    @IBAction func acClick(_ sender: UIButton) {
        game!.clearAll()
        for i in 0...5 {
            for j in 0...5 {
                bts[i][j].setTitleColor( UIColor(red:0, green:0, blue:0, alpha: 1), for: .normal)
                bts[i][j].setTitle("", for: .normal)
            }
        }
    }
    
}
