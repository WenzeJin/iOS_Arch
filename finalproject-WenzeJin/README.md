[![Review Assignment Due Date](https://classroom.github.com/assets/deadline-readme-button-24ddc0f5d75046c5622901739e7c5dd533143b0c8e959d652212380cedb1ea36.svg)](https://classroom.github.com/a/HOmXqksq)
# Final project

## 项目要求

### 运用所学知识，构建聪明格App Pro Max版本：

- 必要功能：
  -  将[聪明格题库](https://krazydad.com/inkies/)题目按你觉得合理的组织形式，以多级目录的方式呈现（TableView...TabView...）
  -  选择一题题目，跳转到解题View，开始解题。
    -  题目数据需从pdf中自动化获取。
      -  可利用如opencv的边缘检测，基于图像分类模型的数字和操作符识别模型(需尝试自行构建)
- 可选功能：
  - 美化界面
  
### 用Markdown编写简单项目文档，并展示运行录屏(录屏需上传，方便后续浏览)
    
  - 建议录屏上传方式(二选一)
    - 上传b站，将链接放置/视频嵌入README中
    - 上传自己的Github仓库，视频嵌入README中

## 展示链接

[展示视频](https://www.bilibili.com/video/BV1Et4y1d7Re/)

## 项目简介

项目包含两个子项目。

首先`GetQuestion`是一个Python项目，它是用来获取聪明格题库的PDF并将题库中的第一个题目进行分割，然后将分割后的图片进行处理，通过opencv边缘检测、ocr文字识别、图上遍历等方式 完成对于题目的识别，并生成相应的JSON中间格式文件。

其次`Collection`是一个iOS应用项目，它由第三次作业和第二次作业综合而来，并且将此前硬编码题目的方式改为了通过JSON文件动态获取题目的方式。通过对题库的浏览，选择相应的题目，可以进入相应的做题界面。完成题目解答之后会有相应的提示。

在本次作业当中，以4x4聪明格为例，`GetQuestion`可以获取题目并生成JSON。在这里我利用Shell脚本批量生成了4x4 Medium难度 Volumn 1 中所有pdf对应的题目，用于功能展示。5x5、6x6聪明格题目的获取与4x4同理，时间原因没有特别地进行实现。

之后，在`Collection`中，我将4x4 Medium难度 Volumn 1 中所有题目的JSON文件进行了整合，用于功能展示。5x5、6x6聪明格题目的与4x4同理，时间原因没有特别地进行实现。点击4x4选项卡，Medium难度，Volumn1，选择任意一道题，就可以进入做题界面。

为了保证程序的鲁棒性，后段生成的题目中间格式文件未必100%准确，我在前端输入题目时增加了检查题目合理性的环节，如果题目不合理，会阻止用户进行任何操作并提示用户更换任意其他题目进行尝试。但实际上在目前已经生成的50题中，没有出现识别错误的情况。

做题界面的描述同作业二，不再赘述。

详细的应用展示可以通过上方的展示链接访问。
