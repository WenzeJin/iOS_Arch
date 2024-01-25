//
//  GameViewController.swift
//  calcudoku
//
//  Created by 金文泽 on 2023/10/24.
//

import UIKit

fileprivate class JsonRule: Decodable {
    let op: String
    let target: Int
    let blocks: [[Int]]

    enum CodingKeys: String, CodingKey {
        case op
        case target
        case blocks
    }

    init() {
        fatalError("Only make one of these from JSON through the Codable interface.")
    }
}


fileprivate struct RulesEnvelope: Decodable {
  let rules: [JsonRule]
}


class GameViewController: UIViewController {
    
    @IBOutlet weak var question_image: UIImageView!
    var currBlock:UIButton?
    var jsonName:String = "res"
    var imgName:String = "res"
    var game:GameState?
    
    @IBOutlet weak var b00: UIButton!
    @IBOutlet weak var b01: UIButton!
    @IBOutlet weak var b02: UIButton!
    @IBOutlet weak var b03: UIButton!
    
    @IBOutlet weak var b10: UIButton!
    @IBOutlet weak var b11: UIButton!
    @IBOutlet weak var b12: UIButton!
    @IBOutlet weak var b13: UIButton!
    
    @IBOutlet weak var b20: UIButton!
    
    @IBOutlet weak var b21: UIButton!
    @IBOutlet weak var b22: UIButton!
    @IBOutlet weak var b23: UIButton!
    
    @IBOutlet weak var b30: UIButton!
    @IBOutlet weak var b31: UIButton!
    @IBOutlet weak var b32: UIButton!
    @IBOutlet weak var b33: UIButton!
    
    var bts = [[UIButton]]()
    
    func loadGame() {
        let path = Bundle.main.path(forResource: imgName, ofType: "jpg")
        question_image.image = UIImage(contentsOfFile: path ?? "")
        
        guard let url = Bundle.main.url(forResource: jsonName, withExtension: "json") else {
            fatalError("No Such Json File")
        }
        let data = try! Data(contentsOf: url)
        let rules = try! JSONDecoder().decode(RulesEnvelope.self, from: data)
        
        game = GameState()
        
        for rule in rules.rules {
            var buff = [Position]()
            for pos in rule.blocks {
                buff.append(Position(pos[0], pos[1]))
            }
            var op = Operation.NOP
            
            switch rule.op {
            case "+":
                op = Operation.ADD
            case "-":
                op = Operation.SUB
            case "X":
                op = Operation.MUL
            case "x":
                op = Operation.MUL
            case "*":
                op = Operation.MUL
            case "/":
                op = Operation.DIV
            case "imm":
                op = Operation.CONST
            default:
                op = Operation.NOP
            }
            
            game!.addRule(op, rule.target, buff)
        }
        
        print(game!.checkRule())
        
        
        bts = [
            [b00, b01, b02, b03],
            [b10, b11, b12, b13],
            [b20, b21, b22, b23],
            [b30, b31, b32, b33]
        ]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        if !game!.checkRule() {
            let alertController = UIAlertController(title: "抱歉", message: "由于技术原因，该题目未正常读取，请更换一道题试试吧！", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "我已知晓", style: .default, handler: nil)
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)
            return
        }
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
        if !game!.checkRule() {
            let alertController = UIAlertController(title: "抱歉", message: "由于技术原因，该题目未正常读取，请更换一道题试试吧！", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "我已知晓", style: .default, handler: nil)
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)
            return
        }
        currBlock?.setTitle(sender.titleLabel?.text, for: .normal)
        if currBlock != nil {
            var ii = 0
            var jj = 0
            for i in 0...3 {
                var found = false
                for j in 0...3 {
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
            
            for i in 0...3 {
                for j in 0...3 {
                    let blc = game!.getBlockAt(i, j)
                    if blc.rError || blc.cError || blc.ruError {
                        bts[i][j].setTitleColor( UIColor(red:1, green:0, blue:0, alpha: 1), for: .normal)
                    } else {
                        bts[i][j].setTitleColor( UIColor(red:0, green:0, blue:0, alpha: 1), for: .normal)
                    }
                }
            }
            
            if game!.gameEnd() {
                let alertController = UIAlertController(title: "游戏结束", message: "🎉您已经成功完成了一组4x4的聪明格，恭喜！🎉", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "好的", style: .default, handler: nil)
                    alertController.addAction(okAction)
                    self.present(alertController, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func clrClick(_ sender: UIButton) {
        if !game!.checkRule() {
            let alertController = UIAlertController(title: "抱歉", message: "由于技术原因，该题目未正常读取，请更换一道题试试吧！", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "我已知晓", style: .default, handler: nil)
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)
            return
        }
        currBlock?.setTitle("", for: .normal)
        if currBlock != nil {
            var ii = 0
            var jj = 0
            for i in 0...3 {
                var found = false
                for j in 0...3 {
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
            
            for i in 0...3 {
                for j in 0...3 {
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
        if !game!.checkRule() {
            let alertController = UIAlertController(title: "抱歉", message: "由于技术原因，该题目未正常读取，请更换一道题试试吧！", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "我已知晓", style: .default, handler: nil)
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)
            return
        }
        game!.clearAll()
        for i in 0...3 {
            for j in 0...3 {
                bts[i][j].setTitleColor( UIColor(red:0, green:0, blue:0, alpha: 1), for: .normal)
                bts[i][j].setTitle("", for: .normal)
            }
        }
    }
    
}
