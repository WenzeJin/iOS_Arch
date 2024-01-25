//
//  Stack.swift
//  calculator
//
//  Created by 金文泽 on 2023/10/8.
//

import UIKit

class Stack<T>: NSObject {
    var buffer: [T]
    var _size: Int
    var _top: Int
    
    override init() {
        buffer = []
        _size = 0
        _top = -1
        super.init()
    }
    
    func push(_ obj: T) {
        _size += 1
        _top += 1
        buffer.append(obj)
    }
    
    func pop() -> Bool{
        if _size == 0 {
            return false
        } else {
            buffer.removeLast()
            _size -= 1
            _top -= 1
            return true
        }
    }
    
    func top() -> T? {
        if _size == 0 {
            return nil
        } else {
            return buffer[_top]
        }
    }
    
    func size() -> Int {
        return _size
    }
    
    func clear() {
        _size = 0
        _top = -1
        buffer.removeAll()
    }
    
    func isEmpty() -> Bool{
        return _size == 0
    }
}
