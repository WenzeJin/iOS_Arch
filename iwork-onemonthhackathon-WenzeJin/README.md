[![Review Assignment Due Date](https://classroom.github.com/assets/deadline-readme-button-24ddc0f5d75046c5622901739e7c5dd533143b0c8e959d652212380cedb1ea36.svg)](https://classroom.github.com/a/t6RI1hiZ)
# oneMonthHackathon Smart Album

## 项目要求

运用所学知识，构建一个自己的相册App：MyAlbum
  -  可通过1)摄像头拍照, 2)加载iOS原生相册App照片的方式将照片添加至MyAlbum App
  -  加入照片时，利用提供的snacks模型(snacks数据集20分类)进行类型识别，并做**标识**
  -  可浏览图片(Collection View/Table View选1即可)
  -  按**标识**的类别自动分类照片，用TableView展示类别信息，点击类别，跳转到下一个view，浏览该类别下的所有图片
  -  点击图片，跳转到下一个页面，显示单张图片及其信息

## 展示视频

[展示视频](https://www.bilibili.com/video/BV1iG411B7aQ/)

## 项目介绍

本次我制作了一个可以对图片进行snacks20分类的智能相册，相册主体部分是一个TabView，包含三个不同功能的Tab

1. 添加图片
   在这个Tab当中，有从本地相册加载图片和拍照的两个选项，选择任意一个选项均可以实现图片的加载，每加载一张图片，都会跳转到`PhotoView`进行识别并给这个图片打上标记，用于后面的按分类浏览。在`PhotoView`当中，会显示当前识别的类型以及置信度。如果后面在其他界面点击图片，也会跳转到这个`PhotoView`进行展示，但是会直接读取图片的标识信息，不会再次进行识别了。
2. 浏览图片
   在这个Tab中，利用`CollectionView`展示了所有的图片。同时利用`NavigationView`组织页面，跳转到`PhotoView`之后仍然可以返回到相册界面中。
3. 按分类浏览
   在这个Tab中，利用`TableView`对20分类进行了展示，点击某一个项目，便会调用`identifier = "classifyToAlbum"`的`segue`跳转到上述相册的`CollectionView`，并根据惦记的内容过滤并准备相应的图片以供展示。`CollectionView`通过不同的`segue`跳转展示不同的内容，实现了代码的复用。

## 一点遗憾

在完成这一项目的过程中，我曾经尝试使用`Photo`与`PhotoUI`库实现对系统相册的访问与管理，这样可以更好的与系统相册交互，在系统相册中开辟独立的“smart album”相册，将相册中的图片保存于其中，每次打开app时使用里面的图片初始化程序的内容，这样不仅可以实现相册图片的本地保存，还可以实现在不启动程序的情况下批量导入图片。但是最终由于真机权限相关的一些“bug”，在进行到从系统相册初始化程序内容这一步的时候无法解决问题，遂放弃了这一想法。