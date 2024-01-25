# iOS assignment 2: Calcudoku App.

## 项目要求
聪明格(Calcudoku)是一种数字游戏，又被称作升级版的数独。它在数学上的要求比数独要高得多。聪明格把数独规则与加减乘除四则运算相结合，使大脑在各种谜题中来回穿梭。

按照聪明格解题要求，参考[聪明格在线](https://www.calcudoku.org)实现iOS版的聪明格解题游戏。出一道6*6难度的题供用户解题：
1. 功能正确。
2. 界面UI风格不限，颜色不限
3. 用Markdown编写简单项目文档，并展示运行录屏(录屏需上传方便后续浏览)
    - 建议录屏上传方式(二选一)
        - 上传b站，将链接放置/视频嵌入README中
        - 上传自己的Github仓库，视频嵌入README中

## 项目展示视频链接

[https://www.bilibili.com/video/BV12z4y1A7Ey](https://www.bilibili.com/video/BV12z4y1A7Ey)

## 项目结构

本项目采用了MVC的设计模式，主要有三个部分：(Model) GameState等，(View) UI，(Controller) GameViewController & StartViewController。项目的结构如下：

```text
--
|—— Calcudoku
    |—— Calcudoku
        |—— AppDelegate.swift       // 应用程序委托
        |—— SceneDelegate.swift     // 场景委托
        |-- Controller
         |—— StartViewController.swift // 开始界面视图控制器
         |—— GameViewController.swift  // 游戏界面视图控制器
        |-- View
         |—— GameState.swift          // 游戏状态类
        |—— Info.plist
        |—— Base.Iproj
            |—— Main.storyboard
            |—— LaunchScreen.storyboard
```

## UI展示

开始界面

![1](./images/1.png)

游戏界面

![2](./images/2.png)

游戏结束提示

![3](./images/3.png)

## 功能介绍

点击开始即可开始一局聪明格游戏，目前游戏包含一道6*6难度的题供用户解题。

进入游戏之后，点击相应的格子可以使得该格子处于选中的状态，在UI上体现为高亮，接着用户可以点击下方的数字区域按钮，为该格子输入一个数字，或者是清除该格子目前的数字。

在用户每一次输入完或清除完该格子的数字之后，游戏会进行一次合法性检查，确保该行，该列以及在同一个区域中的格子输入符合规则要求。如果不符合要求，那么该格子的数字会呈现为红色以提示用户修改其输入的值。若用户通过各种方式（包括但不限于：修改错误位置格子的值，修改与错误位置在同一行或同一列或同一区域某个格子的值，清除某个格子的输入）使得该错误被消除，那么该格子的数字的颜色会恢复为黑色。

如果用户输入已经满足游戏结束的要求，那么会弹出一个对话框，提示用户游戏结束，此时可以返回刚才的做题界面，也可以直接关闭做题界面。

## 项目仍存在的问题

1. 游戏界面的UI设计仍然有待改进，目前的UI设计仍然比较简陋，采用的是以题目图片作为背景的方式进行的。后续可以做的更加灵活一些
2. 游戏的题目仍然是写死在代码中的，后续可以考虑从网络上获取题目，或者是从本地文件中读取题目