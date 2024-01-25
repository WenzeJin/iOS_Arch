[![Review Assignment Due Date](https://classroom.github.com/assets/deadline-readme-button-24ddc0f5d75046c5622901739e7c5dd533143b0c8e959d652212380cedb1ea36.svg)](https://classroom.github.com/a/QjCrR0Eo)

# iwork-04 Healthy Snacks App

## 作业要求

1. 按照QQ群提供的snacks数据集(snacks.zip)，利用createML进行Healthy/Unhealthy snacks的图像二分类模型训练，生成mlmodel。
2. 对提供的xcode工程进行代码填充，并对**需求解释**的代码段进行解释。
3. 界面UI风格不限，颜色不限。
4. 用Markdown编写简单项目文档，并展示运行录屏(录屏需上传方便后续浏览)
    - 建议录屏上传方式(二选一)
        - 上传b站，将链接放置/视频嵌入README中
        - 上传自己的Github仓库，视频嵌入README中

注：references/object_detection内容供大家参考学习使用(可能会在未来大作业中用到)

## 展示链接

[展示视频](https://www.bilibili.com/video/BV1PN411V7JH/)

## 需求解释的代码

```swift
func processObservations(for request: VNRequest, error: Error?) {
        DispatchQueue.main.async {
    //******Explain the following code in your report******
            if let results = request.results as? [VNClassificationObservation] {
                if results.isEmpty {
                    self.resultsLabel.text = "nothing found"
                } else if results[0].confidence < 0.1 {
                    self.resultsLabel.text = "not sure"
                } else {
                    self.resultsLabel.text = String(format: "%@ %.1f%%", results[0].identifier, results[0].confidence * 100)
                }
            } else if let error = error {
                self.resultsLabel.text = "error: \(error.localizedDescription)"
            } else {
                self.resultsLabel.text = "???"
            }
            self.showResultsView()
        }
    }
```

这段代码从一个`VNRequest`中获取结果，如果结果可以转换为`VNClassificationObservation`类型的数组，那么这个数组的第0个元素即位于最高置信度的分类结果，将其显示在`resultsLabel`中。如果结果为空，那么显示`nothing found`；如果置信度小于0.1，那么显示`not sure`；如果出现错误，那么显示`error: \(error.localizedDescription)`；如果以上情况都不是，那么显示`???`。最后调用`showResultsView()`显示结果。