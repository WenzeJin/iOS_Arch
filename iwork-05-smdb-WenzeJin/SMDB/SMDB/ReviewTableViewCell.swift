/// Copyright (c) 2020 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// This project and source code may use libraries or frameworks that are
/// released under various Open-Source licenses. Use of those libraries and
/// frameworks are governed by their own individual licenses.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import UIKit

fileprivate let sentimentMapping = [
  2: "😅",      //when mlmodel result conflicts with NLKit result
  1: "😍",
  0: "😞"
]

class ReviewTableViewCell: UITableViewCell {

  @IBOutlet weak var bodyTextLabel: UILabel!
  @IBOutlet weak var sentimentLabel: UILabel!
  @IBOutlet weak var titleLabel: UILabel!

    func setSentiment(sentiment: Int?, score: Double?) {
        guard let sentiment = sentiment else {
            sentimentLabel.text = ""
            return
        }
        if sentiment == 1 {
            if score! >= 0 {
                sentimentLabel.text = ""
                let time = Int(4 * score!)
                for _ in 0...time {
                    sentimentLabel.text! += sentimentMapping[sentiment] ?? ""
                }
            } else {
                sentimentLabel.text = sentimentMapping[2]
            }
        } else if sentiment == 0 {
            if score! <= 0 {
                sentimentLabel.text = ""
                let time = Int(4 * (0 - score!))
                for _ in 0...time {
                    sentimentLabel.text! += sentimentMapping[sentiment] ?? ""
                }
            } else {
                sentimentLabel.text = sentimentMapping[2]
            }
        }
    }
}
