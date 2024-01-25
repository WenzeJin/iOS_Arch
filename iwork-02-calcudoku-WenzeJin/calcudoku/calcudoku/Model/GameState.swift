//
//  GameState.swift
//  calcudoku
//
//  Created by 金文泽 on 2023/10/24.
//

import UIKit

enum Operation {
    case ADD, SUB, MUL, DIV, CONST, NOP
}

struct Position {
    var x: Int
    var y: Int
    
    init(_ xx:Int, _ yy:Int) {
        x = xx
        y = yy
    }
}

struct GameRule {
    var opt: Operation
    var target:Int
    var members: [Position]
    
    func testRule(_ map6x6: [[Block]]) -> Int {
        switch opt {
        case .ADD:
            var temp = 0
            for each in members {
                if map6x6[each.x][each.y].invalid == true {
                    return 2
                }
                temp += map6x6[each.x][each.y].value
            }
            return temp == target ? 1 : 0
        case .SUB:
            if map6x6[members[0].x][members[0].y].invalid == true {
                return 2
            }
            var temp = map6x6[members[0].x][members[0].y].value
            for i in 1..<members.count {
                let each = members[i]
                if map6x6[each.x][each.y].invalid == true {
                    return 2
                }
                temp -= map6x6[each.x][each.y].value
            }
            return (temp == target || temp == -target) ? 1 : 0
        case .MUL:
            var temp = 1
            for each in members {
                if map6x6[each.x][each.y].invalid == true {
                    return 2
                }
                temp *= map6x6[each.x][each.y].value
            }
            return temp == target ? 1 : 0
        case .DIV:
            if map6x6[members[0].x][members[0].y].invalid == true {
                return 2
            }
            var temp = map6x6[members[0].x][members[0].y].value
            var tempre = map6x6[members[members.count - 1].x][members[members.count - 1].y].value
            for i in 1..<members.count {
                let each = members[i]
                let eachre = members[members.count - 1 - i]
                if map6x6[each.x][each.y].invalid == true {
                    return 2
                }
                temp /= map6x6[each.x][each.y].value
                tempre /= map6x6[eachre.x][eachre.y].value
            }
            return (temp == target || tempre == target) ? 1 : 0
        case .CONST:
            if map6x6[members[0].x][members[0].y].invalid == true {
                return 2
            }
            let temp = map6x6[members[0].x][members[0].y].value
            return temp == target ? 1 : 0
        case .NOP:
            for each in members {
                if map6x6[each.x][each.y].invalid == true {
                    return 2
                }
            }
            return 1
        }
    }
}

struct Block {
    var invalid: Bool
    var value: Int
    var rError: Bool
    var cError: Bool
    var ruError: Bool
    
    init(invalid: Bool, value: Int) {
        self.invalid = invalid
        self.value = value
        rError = false
        cError = false
        ruError = false
    }
}

class GameState: NSObject {
    var map6x6 = [[Block]]()
    var rules = [GameRule]()
    var ruleSize = 0
    var rowState = [Bool]()
    var colState = [Bool]()
    var ruleState = [Bool]()
    
    override init() {
        for _ in 0...5 {
            var row = [Block]()
            for _ in 0...5 {
                row.append(Block(invalid: true, value: 0))
            }
            map6x6.append(row)
        }
        for _ in 0...5 {
            rowState.append(false)
            colState.append(false)
        }
    }
    
    func addRule(_ op: Operation, _ target:Int, _ member: [Position]) {
        let tempRule = GameRule(opt:op, target:target, members:member)
        rules.append(tempRule)
        ruleState.append(false)
        ruleSize += 1
    }
    
    /*
     Check whether rules of this map has been set correctly.
     */
    func checkRule() -> Bool {
        var checkTable = [[Bool]]()
        for _ in 0...5 {
            var row = [Bool]()
            for _ in 0...5 {
                row.append(false)
            }
            checkTable.append(row)
        }
        for rule in rules {
            for member in rule.members {
                if checkTable[member.x][member.y] {
                    return false
                }
                checkTable[member.x][member.y] = true
            }
        }
        for rows in checkTable {
            for i in rows {
                if !i {
                    return false
                }
            }
        }
        return true
    }
    
    func getBlockAt(_ x: Int, _ y: Int) -> Block {
        return map6x6[x][y]
    }
    
    
    func checkInvalidAt(_ x: Int, _ y: Int) -> Bool {
        //If a new error has been made after change this block, set errorCausedByThisBlock to true
        var errorCausedByThisBlock = false
        let blc = map6x6[x][y]
        let testPos = Position(x, y)
        if blc.invalid {
            rowState[x] = false
            colState[y] = false
            var index = 0
            for rule in rules {
                if rule.members.contains(where: {(pos:Position) in return pos.x == testPos.x && pos.y == testPos.y}) {
                    ruleState[index] = false
                }
                index += 1
            }
        }
        
        var check6:[Bool]
        var checkFlag:Bool
        var allFlag:Bool

        
        //Check Row
        check6 = [Bool](repeating: false, count: 7)
        checkFlag = true
        allFlag = true
        for j in 0...5 {
            let cb = map6x6[x][j]
            if cb.invalid {
                allFlag = false
            } else if check6[cb.value] {
                checkFlag = false
                if cb.value == map6x6[x][y].value {
                    errorCausedByThisBlock = true
                    map6x6[x][y].rError = true
                }
            } else {
                check6[cb.value] = true
            }
        }
        rowState[x] = checkFlag && allFlag
        //clear error
        if checkFlag {
            for j in 0...5 {
                map6x6[x][j].rError = false
            }
        }
        
        //Check Column
        check6 = [Bool](repeating: false, count: 7)
        checkFlag = true
        allFlag = true
        for i in 0...5 {
            let cb = map6x6[i][y]
            if cb.invalid {
                allFlag = false
            } else if check6[cb.value] {
                checkFlag = false
                if cb.value == map6x6[x][y].value {
                    errorCausedByThisBlock = true
                    map6x6[x][y].cError = true
                }
            } else {
                check6[cb.value] = true
            }
        }
        colState[y] = checkFlag && allFlag
        //clear error
        if checkFlag {
            for i in 0...5 {
                map6x6[i][y].cError = false
            }
        }
        
        //Check Rule
        //Find Rule
        var index = 0
        for rule in rules {
            if rule.members.contains(where: {(pos:Position) in return pos.x == testPos.x && pos.y == testPos.y}) {
                break
            }
            index += 1
        }
        let res = rules[index].testRule(map6x6)
        if res == 0 {
            ruleState[index] = false
            errorCausedByThisBlock = true
            map6x6[x][y].ruError = true
        } else if res == 1 {
            ruleState[index] = true
        } else if res == 2 {
            ruleState[index] = false
        }
        if ruleState[index] {
            for each in rules[index].members {
                map6x6[each.x][each.y].ruError = false
            }
        }
        
        return errorCausedByThisBlock
    }
    
    
    func checkFinish() -> Bool{
        for each in rowState {
            if !each {
                return false
            }
        }
        
        for each in colState {
            if !each {
                return false
            }
        }
        
        for each in ruleState {
            if !each {
                return false
            }
        }
        
        return true
    }
    
    func setBlockAt(_ x: Int, _ y: Int, _ newB: Block) {
        map6x6[x][y] = newB
    }
    
    func clearAll() {
        map6x6.removeAll()
        for _ in 0...5 {
            var row = [Block]()
            for _ in 0...5 {
                row.append(Block(invalid: true, value: 0))
            }
            map6x6.append(row)
        }
        rowState.removeAll()
        colState.removeAll()
        for _ in 0...5 {
            rowState.append(false)
            colState.append(false)
        }
        for i in 0..<ruleSize {
            ruleState[i] = false
        }
    }
    
    func findMembers(_ x:Int, _ y:Int) -> [Position] {
        let testPos = Position(x, y)
        var index = 0
        for rule in rules {
            if rule.members.contains(where: {(pos:Position) in return pos.x == testPos.x && pos.y == testPos.y}) {
                break
            }
            index += 1
        }
        return rules[index].members
    }
    
    func gameEnd() -> Bool {
        for each in rowState {
            if !each {
                return false
            }
        }
        for each in colState {
            if !each {
                return false
            }
        }
        for each in ruleState {
            if !each {
                return false
            }
        }
        return true
    }
}
