//
//  Calculator.swift
//  calculator
//
//  Created by 金文泽 on 2023/10/1.
//

import UIKit

extension Double {
    func toDeg() -> Double {
        return (self / .pi) * 180
    }
    
    func toRad() -> Double {
        return (self / 180) * .pi
    }
}

class Calculator: NSObject {
    enum Mode: Int {
        case DEG
        case RAD
    }
    
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
    
    enum ControlOp {
        case AllClear
        case DRTransfer
    }
    
    struct BinaryWait {
        var op1: Double
        var operation: ((Double, Double) -> Double)
        var checkOp: String
    }
    
    func ValidTest(op1:Double, op2:Double = 0.0, operation:String) -> Bool{
        switch operation {
        case "/":
            return op2 != 0
        case "x!":
            return op1 >= 0
        default:
            return true
        }
    }
    
    func CompleteWait(op2:Double) -> Double {
        if isWaiting {
            isWaiting = false
            //valid test for op2 if needed
            if waitBuffer.checkOp != "" {
                if !ValidTest(op1: waitBuffer.op1, op2: op2,operation: waitBuffer.checkOp) {
                    error = true //Enable ERROR mode
                    return 0.0
                }
            }
            return waitBuffer.operation(waitBuffer.op1, op2)
        } else {
            print("Tried to complete a binary operation but there haven't been one.")
            return 0.0
        }
    }
    
    var stack = Stack<BinaryWait>()
    var mode:Mode = .DEG    //current mode of D/R
    var mem:Double = 0.0    //current memory number
    var error = false  //current error status
    var isWaiting = false   //if there is a uncomplete BinaryOp waiting
    var clear = true
    var waitBuffer = BinaryWait(op1:0.0, operation: {(o1, o2) in  return o1}, checkOp: "")
    var res = 0.0
    var display = 0.0
    var inBuffer = 0.0
    
    var checkOps = ["/", "!", "tanx"]
    
    var tfunctionIn = ["sinx", "cosx", "tanx", "sinhx", "coshx", "tanhx"]
    var tfunctionOut = ["asinx", "acosx", "atanx", "asinhx", "acoshx", "atanhx"]
    
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
        "%": Operation.UnaryOp {
            (op1) in
            return op1 / 100
        },
        "x^y": Operation.BinaryOp {
            (op1, op2) in
            return pow(op1,op2)
        },
        "logxy": Operation.BinaryOp {
            (op1, op2) in
            return log(op2) / log(op1)
        },
        "sqrtx": Operation.UnaryOp {
            (op1) in
            return sqrt(op1)
        },
        "x!": Operation.UnaryOp {
            (op1) in
            var temp = 1
            for i in 1...Int(op1) {
                temp *= i
            }
            return Double(temp)
        },
        "sinx": Operation.UnaryOp {
            (op1) in
            return sin(op1)
        },
        "asinx": Operation.UnaryOp {
            (op1) in
            return asin(op1)
        },
        "cosx": Operation.UnaryOp {
            (op1) in
            return cos(op1)
        },
        "acosx": Operation.UnaryOp {
            (op1) in
            return acos(op1)
        },
        "tanx": Operation.UnaryOp {
            (op1) in
            return tan(op1)
        },
        "atanx": Operation.UnaryOp {
            (op1) in
            return atan(op1)
        },
        "sinhx": Operation.UnaryOp {
            (op1) in
            return sinh(op1)
        },
        "asinhx": Operation.UnaryOp {
            (op1) in
            return asinh(op1)
        },
        "coshx": Operation.UnaryOp {
            (op1) in
            return cosh(op1)
        },
        "acoshx": Operation.UnaryOp {
            (op1) in
            return acosh(op1)
        },
        "tanhx": Operation.UnaryOp {
            (op1) in
            return tanh(op1)
        },
        "atanhx": Operation.UnaryOp {
            (op1) in
            return atanh(op1)
        },
        "(": Operation.LeftBracket,
        ")": Operation.RightBracket,
        "pi": Operation.Constant(Double.pi),
        "e": Operation.Constant(2.71828),
        "mc": Operation.MemClear,
        "m+": Operation.MemAdd,
        "m-": Operation.MemSub,
        "mr": Operation.MemOut
    ]
    
    var controls = [
        "AC": ControlOp.AllClear,
        "D/R": ControlOp.DRTransfer
    ]
    
    func numberInput(_ number:Double) {
        if error {
            return;
        }
        inBuffer = number
    }
    
    func performOperation(_ opr:String) {
        //If the calculator is in ERROR mode, it will do nothing.
        if error {
            return;
        }
        
        if let op = operations[opr] {
            switch op {
            //If op is BinaryOp, if a BinaryOp is already wating, it will be completed and the result of it will be op1 of the new opretor. If there haven't been a BinaryOp, then the number of inBuffer will be op1 of the BinaryOp, and wait for another oprand (op2)
            case .BinaryOp(let function):
                if clear {
                    clear = false
                }
                if isWaiting {
                    res = CompleteWait(op2: inBuffer)
                    isWaiting = true
                    display = res
                    waitBuffer.op1 = res
                    waitBuffer.operation = function
                    if checkOps.contains(opr) {
                        waitBuffer.checkOp = opr
                    } else {
                        waitBuffer.checkOp = ""
                    }
                } else {
                    waitBuffer.op1 = inBuffer
                    waitBuffer.operation = function
                    isWaiting = true
                    display = inBuffer
                    //If opr is in the list of ops that should be checked, then give it a mark to ensure valid check is performed when buffer is calculated
                    if checkOps.contains(opr) {
                        waitBuffer.checkOp = opr
                    } else {
                        waitBuffer.checkOp = ""
                    }
                }
            
            //If opr is a UnaryOp, then it will performed to current inBuffer value
            case .UnaryOp(let function):
                if clear {
                    clear = false
                }
                if mode == .DEG{
                    if tfunctionIn.contains(opr) {
                        res = function(inBuffer.toRad())
                    } else if tfunctionOut.contains(opr) {
                        res = function(inBuffer).toDeg()
                    } else {
                        res = function(inBuffer)
                    }
                } else {
                    res = function(inBuffer)
                }

                display = res
            
            //If opr is a Constant, then it will be displayed and override the number in inBuffer
            case .Constant(let d):
                inBuffer = d
                display = inBuffer
                
            //If opr is Equal, then it will compelete the waiting BinaryOp expression will inBuffer as op2 (if there has a waiting BinaryOp)
            case .Equal:
                if isWaiting {
                    res = CompleteWait(op2: inBuffer)
                    display = res
                } else {
                    res = inBuffer
                    display = res
                }
            //If opr is memop:
            case .MemAdd:
                mem += inBuffer
                display = inBuffer
            case .MemSub:
                mem -= inBuffer
                display = inBuffer
            case .MemOut:
                inBuffer = mem
                display = mem
            case .MemClear:
                mem = 0.0
                display = inBuffer
            default:
                break
            }
        }
    }
    
    func getDisplay() -> String {
        if(error) {
            //ERROR mode can be remove by AC only
            return "错误"
        } else {
            return String(display)
        }
    }
    
    func getDRMode() -> String {
        switch mode {
        case .DEG:
            return "DEG"
        case .RAD:
            return "RAD"
        }
    }
    
    func performControl(_ ctr:String) {
        if let ct = controls[ctr] {
            switch ct {
            case .AllClear:
                stack = Stack<BinaryWait>()
                mem = 0.0    //current memory number
                error = false  //current error status
                isWaiting = false   //if there is a uncomplete BinaryOp waiting
                clear = true
                waitBuffer = BinaryWait(op1:0.0, operation: {(o1, o2) in  return o1}, checkOp: "")
                res = 0.0
                display = 0.0
                inBuffer = 0.0
            case .DRTransfer:
                switch mode {
                case .DEG:
                    mode = .RAD
                case .RAD:
                    mode = .DEG
                }
            }
        }
    }
    
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
    
}
