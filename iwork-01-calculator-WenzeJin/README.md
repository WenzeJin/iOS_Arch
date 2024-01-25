# iOS assignment 1: Calculator App.

## 项目要求

请仿照Apple官方iOS中的计算器编写一个自己的计算器App，要求（利用Autolayout技术）支持竖屏和横屏(不强求科学计算器功能)。
具体要求包括：

1. 计算功能正确。
2. 界面UI风格不限，颜色不限
3. 参考[实践视频](https://www.bilibili.com/video/BV1Yr4y1c7HW)，实现`Calculator`类作为模型，仔细体会MVC模式的优点
4. 用Markdown编写简单项目文档，并展示运行录屏(录屏需上传方便后续浏览)
    - 建议录屏上传方式(二选一)
        - 上传b站，将链接放置/视频嵌入README中
        - 上传自己的Github仓库，视频嵌入README中

## 项目展示视频链接

[https://www.bilibili.com/video/BV1Xw411w76T](https://www.bilibili.com/video/BV1Xw411w76T)

## 项目结构

本项目采用了MVC的设计模式，主要有三个部分：(Model) 计算器类，(View) UI，(Controller) ViewController。项目的结构如下：

```text
--
|—— Calculator
    |—— Calculator
        |—— Calculator.swift        // 计算器模型
        |—— AppDelegate.swift       // 应用程序委托
        |—— SceneDelegate.swift     // 场景委托
        |—— ViewController.swift    // 视图控制器
        |—— Info.plist
        |—— Stack.swift             // 栈
        |—— Base.Iproj
            |—— Main.storyboard
            |—— LaunchScreen.storyboard
```

## UI展示

首先介绍项目的UI设计。计算器有普通计算机与科学计算器两种功能，并在竖屏和横屏下通过调整某些内容的hidden属性，实现界面元素的隐藏与展示。在竖屏模式下，计算器界面如下图所示：

![竖屏模式](./image/UI1.png)

在横屏模式下，科学计算器的界面如下图所示：

![横屏模式](./image/UI3.png)

同时，由于使用了Auto Layout技术，计算器界面可以适配不同尺寸的iPhone设备，如下图所示：

![适配不同尺寸的iPhone设备](./image/UI2.png)

最终，我还利用了UIKit中已经提供的一些配色方案，使得UI简便地适配了夜间模式，如下图所示：

![夜间模式](./image/UI4.png)

## 功能介绍

### 普通计算机

提供了基本的四则运算功能。计算的顺序与计算符的优先级无关，按照键入的顺序进行计算。

如果键入新的二元运算符之前，前一个运算还没有进行，那么会一并显示上一个运算的结果，例如键入`1 + 2 *`，那么会显示`3`，并同时等待乘法的下一个操作数。

如果键入等号前，所有的运算都已经完成并显示，那么等号不会起任何作用。反之，如果键入等号前仍有二元运算符没有被运算完成，那么会完成之并显示在屏幕上。

点击`+/-`按键，会切换当前输入的正负号。

`AC/C`按键会清空当前输入的内容，如果已经清除了当前输入的内容，那么会清空所有的运算历史。

如果出现了运算错误，例如除数为0，那么会在屏幕上显示`错误`，并进入错误状态，只有按`AC/C`键才能清除当前的错误状态。

### 科学计算器

科学计算器提供了更多的功能，包括三角函数，反三角函数，常数，寄存器，角度/弧度切换，括号运算等。

科学运算的运算优先级在无括号影响的情况下与普通计算器相同，但是在有括号的情况下，括号内的运算会优先进行。即当按下右括号时，会立即显示括号内的运算结果，并作为先前（左括号）的运算符的第二个操作数，等待下一步运算。

所有的一元运算符，包括三角函数，都是对屏幕上目前显示的内容进行运算，比如，如果需要运算下列表达式

$$ 1 + \sin(90 + 45) $$

按键的顺序应当为 `1` `+` `(` `9` `0` `+` `4` `5` `)` `sin` (`=`)。

要注意的是，上述表达式中最终是否按下等号对结果无影响。

## 项目亮点

### 1. 代码结构清晰

将所有的按键操作都按照按键的种类，分类绑定到不同的方法上，通过统一向`Calculator`发送消息，让消息的辨别与处理都在`Calculator`中进行，从而使得代码结构清晰，易于维护。在`Calculator`中，不同操作符的功能利用`lambda`表达式，与`enum Operator`中某一种运算符的形式进行绑定，实现了运算符与运算功能的解耦。部分代码如下：

```swift
class Calculator: NSObject {
    // ...
    enum Operation {
        case UnaryOp((Double) -> Double)
        case BinaryOp((Double, Double) -> Double)
        case Equal
        case Constant(Double)
        case LeftBracket
        case RightBracket
        case MemClear
        case MemAdd
        case MemSub
        case MemOut
    }
    // ...
    var operations = [
        "+": Operation.BinaryOp {
            (op1, op2) in
            return op1 + op2
        },
        "-": Operation.BinaryOp {
            (op1, op2) in
            return op1 - op2
        },
        "X": Operation.BinaryOp {
            (op1, op2) in
            return op1 * op2
        },
        "/": Operation.BinaryOp {
            (op1, op2) in
            return op1 / op2
        },
        "=": Operation.Equal,
        // ...
        "pi": Operation.Constant(Double.pi),
        "e": Operation.Constant(2.71828),
        "mc": Operation.MemClear,
        "m+": Operation.MemAdd,
        "m-": Operation.MemSub,
        "mr": Operation.MemOut
    ]
    // ...
}
```

### 2. 利用合理的运算栈实现了括号的运算

首先，所有的二元运算符由于需要的等待下一个操作数，都需要一个`BinaryWait`类型的结构体来保存当前的运算状态，这在普通计算模式下就已经实现。在括号运算中，首先利用泛型设计了`Stack`类，再用类型`BinaryWait`实例化了一个用于保存括号外运算状态的栈。

当左括号被按下，当前未进行完的运算进栈。当右括号被按下，栈顶的运算状态出栈，同时将当前的运算结果作为栈顶运算状态的第二个操作数，进行运算。这样，就实现了括号内的运算优先级高于括号外的运算。如果右括号按下的时候栈空，则不会进行任何操作。

一些实现如下：

```swift
class Calculator: NSObject{
    // ...
    func performBracket(_ bracket:String) {
        if error {
            return;
        }
        if let bra = operations[bracket] {
            switch bra {
            case .LeftBracket:
                if isWaiting {
                    stack.push(waitBuffer)
                    isWaiting = false
                } else {
                    waitBuffer.op1 = 0
                    waitBuffer.operation = {
                        (op1, op2) in
                        return op2
                    }
                    waitBuffer.checkOp = ""
                    stack.push(waitBuffer)
                }
            case .RightBracket:
                if isWaiting {
                    res = CompleteWait(op2: inBuffer)
                    display = res
                    inBuffer = res
                }
                if !stack.isEmpty() {
                    waitBuffer = stack.top()!
                    stack.pop()
                    isWaiting = true
                } else {
                    isWaiting = false
                }
            default:
                return
            }
        }
    }
    //...
}

```

## 项目仍存在的问题

1. 某些运算的结果可能会超出屏幕的显示范围，但是由于没有实现滚动条或结果舍入，所以无法显示完整的结果。
2. 某些运算的输入合理性并没有进行检验，可能会计算产生NaN或Inf。例如`tanx`
3. ViewController与Calculator之间的消息传递使用的是按钮内的文字信息，与UI设计本身的耦合度较高。
