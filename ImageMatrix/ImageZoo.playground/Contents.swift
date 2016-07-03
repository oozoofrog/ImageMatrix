//: Playground - noun: a place where people can play

import UIKit

import Accelerate

func memDump<T>(v temp: T) {
    var v = temp
    let bytesPtr = withUnsafePointer(&v, { UnsafePointer<UInt8>($0) })
    print(
        /* type    */ "(\(String(v.dynamicType)))" +
            /* value   */ " \(v)"
    )
    
    let HEX = Array("0123456789abcdef".characters)
    let bytesPerGroup = 8
    let groupsPerLine = 2
    
    var hexStr = ""
    for i in 0 ..< strideof(T) {
        
        hexStr += "\(HEX[Int((bytesPtr[i] >> 4) & 0xf)])\(HEX[Int((bytesPtr[i]) & 0xf)])"
        
        if (i + 1) == strideof(T) || (i + 1) % (bytesPerGroup * groupsPerLine) == 0 {
            hexStr += "\n"
        }
        else if (i + 1) % bytesPerGroup == 0 {
            hexStr += " "
        }
    }
    
    print(hexStr)
}

struct Test<A, B> {
    let a: A
    let b: B
}

let a = Test(a: "T", b: 1.0)
let b = Test(a: 1.0, b: "T")

memDump(v: a)
memDump(v: b)
