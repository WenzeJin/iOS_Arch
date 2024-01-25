//
//  BooksView4.swift
//  collection
//
//  Created by 金文泽 on 2023/11/28.
//

import UIKit
import WebKit

class BooksView4: UITableViewController, WKUIDelegate{
    
    var difficulty:String!
    var vol:Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 50
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text="Book \(indexPath.section + 1)"

        // Configure the cell...

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var web_view: WKWebView!
        var myURL:URL!
        var difficulty:String
        switch(self.difficulty) {
        case "Beginner":
            difficulty = "KX"
        case "Easy":
            difficulty = "E"
        case "Med":
            difficulty = "M"
        case "Hard":
            difficulty = "H"
        case "Mixed":
            difficulty = "X"
        case "No_op":
            difficulty = "NOP"
        default:
            difficulty = ""
        }
        let num = NSNumber(value: indexPath.section + 1)
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .none
        numberFormatter.formatWidth = 3
        numberFormatter.paddingCharacter = "0"
        numberFormatter.paddingPosition = .beforePrefix
        numberFormatter.string(from: num)
        if(self.vol == 1){
            myURL=URL(string: String(format: "https://krazydad.com/inkies/sfiles/INKY_4%@_b%@_4pp.pdf", difficulty, numberFormatter.string(from: num)!))
            print(String(format: "https://krazydad.com/inkies/sfiles/INKY_4%@_b%@_4pp.pdf", difficulty, numberFormatter.string(from: num)!))
        } else {
            myURL=URL(string: String(format: "https://krazydad.com/inkies/sfiles/INKY_v%d_4%@_b%@_4pp.pdf", self.vol, difficulty, numberFormatter.string(from: num)!))
            print(String(format: "https://krazydad.com/inkies/sfiles/INKY_v%d_4%@_b%@_4pp.pdf", self.vol, difficulty, numberFormatter.string(from: num)!))
        }
        let vc = UIViewController()
        let webConfiguration = WKWebViewConfiguration()
        web_view = WKWebView(frame: .zero, configuration: webConfiguration)
        web_view.uiDelegate = vc as? any WKUIDelegate
        let myRequest = URLRequest(url: myURL!)
        web_view.load(myRequest)
        vc.view = web_view
        vc.title = "Book\(indexPath.section + 1)"
        navigationController?.show(vc, sender: "Vol. \(indexPath.section + 1)")
    }
}

class VolsView4: UITableViewController{
    
    var difficulty:String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 10
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text="Volumn \(indexPath.section + 1)"

        // Configure the cell...

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let book_view = BooksView4()
        book_view.difficulty = self.difficulty
        book_view.vol = indexPath.section + 1
        book_view.title = "Volumn \(indexPath.section + 1)"
        navigationController?.show(book_view, sender: "Vol. \(indexPath.section + 1)")
    }
}

class DiffsView4: UITableViewController{
    
    var difficulty = ["Beginner", "Easy", "Med", "Hard", "Mixed", "No_op"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 6
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text=difficulty[indexPath.section]

        // Configure the cell...

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vol_view = VolsView4()
        vol_view.difficulty = difficulty[indexPath.section]
        vol_view.title = difficulty[indexPath.section]
        navigationController?.show(vol_view, sender: "root")
    }
}
