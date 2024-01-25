[![Review Assignment Due Date](https://classroom.github.com/assets/deadline-readme-button-24ddc0f5d75046c5622901739e7c5dd533143b0c8e959d652212380cedb1ea36.svg)](https://classroom.github.com/a/RLgklK9f)
# iwork-03
iOS assignment 3: Calcudoku Collection App.

# 展示视频

[展示视频](https://www.bilibili.com/video/BV12M411o7Ht/)

# 项目简介

运行后，会进入主菜单。主菜单中有两个按钮，分别是进入和致谢。点击进入按钮，会进入到题库浏览界面。浏览界面是一个Tab View，分为4x4/5x5/6x6三种，同时每一种难度都是一个Navigation View，通过三级菜单：难度，卷号，书号找到对应的题目。点击最终一级table view的书号，即可进入WKWebView，显示题目。

# 关于链接获取

仓库中的`collect.py`可以用于获取链接，并输出到`result`文件夹当中，保存为`txt`格式。不过，由于在生成pdf的过程中，会访问相当多的网页，所以可能会被网站拦截，同时获取链接的速度受限于网络访问速度，也比较慢，导致无法高效获取链接。

最终我采用的方式是在运行过程中根据用户的选项和krazydad中链接的规则生成访问的链接。这样的方式可以保证获取链接的速度，但是需要手动更新链接命名规则，不够方便。