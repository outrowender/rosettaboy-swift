//
//  CPU.swift
//  RosettaBoy
//
//  Created by Wender on 28/04/23.
//

import Foundation

struct CPU {
    
    // MARK: - CPU Registers
    var a: UInt8 = 0b00000000
    var b: UInt8 = 0b00000000
    var c: UInt8 = 0b00000000
    var d: UInt8 = 0b00000000
    var e: UInt8 = 0b00000000
    var f: UInt8 = 0b00000000
    var g: UInt8 = 0b00000000
    var h: UInt8 = 0b00000000
    var i: UInt8 = 0b00000000
    
    init() { }
}

// MARK: - Virtual 16-bit Registers

extension CPU {
    
    var af: UInt16 {
        get { UInt16(UInt16(a) << 8 + UInt16(f)) }
        
        set {
            self.a = UInt8(newValue >> 8 & 0x00ff)
            self.f = UInt8(newValue & 0x00ff)
        }
    }
    
    var bc: UInt16 {
        get {  UInt16(UInt16(b) << 8 + UInt16(c)) }
        
        set {
            self.b = UInt8(newValue >> 8 & 0x00ff)
            self.c = UInt8(newValue & 0x00ff)
        }
    }
    
    var de: UInt16 {
        get { UInt16(UInt16(d) << 8 + UInt16(e)) }
        
        set {
            self.d = UInt8(newValue >> 8 & 0x00ff)
            self.e = UInt8(newValue & 0x00ff)
        }
    }
    
    var hi: UInt16 {
        get { UInt16(UInt16(h) << 8 + UInt16(i)) }
        
        set {
            self.h = UInt8(newValue >> 8 & 0x00ff)
            self.i = UInt8(newValue & 0x00ff)
        }
    }
}
