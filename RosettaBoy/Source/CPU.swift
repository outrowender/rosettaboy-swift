//
//  CPU.swift
//  RosettaBoy
//
//  Created by Wender on 28/04/23.
//

import Foundation

// MARK: - 8-bit CPU architecture

struct CPU {
    
    var a: UInt8 = 0b00000000
    var b: UInt8 = 0b00000000
    var c: UInt8 = 0b00000000
    var d: UInt8 = 0b00000000
    var e: UInt8 = 0b00000000
    var f: FRegister = FRegister(0b00000000)
    var h: UInt8 = 0b00000000
    var i: UInt8 = 0b00000000
    
    init() { }
}

// MARK: - Virtual 16-bit Registers

extension CPU {
    
    var af: UInt16 {
        get { UInt16(UInt16(a) << 8 + UInt16(f.asUint8)) }
        
        set {
            self.a = UInt8(newValue >> 8 & 0x00ff)
            self.f = FRegister(UInt8(newValue & 0x00ff))
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

// MARK: - CPU Execute

extension CPU {
    func execute(_ instruction: Instruction){
        switch instruction {
        case .ADD(let target):
            switch target {
            case .A:
                print("A")
            case .B:
                print("B")
            case .C:
                print("C")
            case .D:
                print("D")
            case .E:
                print("E")
            case .H:
                print("H")
            case .L:
                print("L")
            }
            
        }
    }
}

// MARK: - Custom Flags register

struct FRegister {
    var zero: Bool = false      // 7
    var subtract: Bool = false  // 6
    var halfCarry: Bool = false // 5
    var carry: Bool = false     // 4
    
    init(zero: Bool, subtract: Bool, halfCarry: Bool, carry: Bool) {
        self.zero = zero
        self.subtract = subtract
        self.halfCarry = halfCarry
        self.carry = carry
    }
    
    init(_ u8: UInt8) {
        asUint8 = u8
    }
    
    var asUint8: UInt8 {
        get {
            UInt8(zero ? 128 : 0)     | //1000 0000
            UInt8(subtract ? 64 : 0)  | //0100 0000
            UInt8(halfCarry ? 32 : 0) | //0010 0000
            UInt8(carry ? 16 : 0)       //0001 0000
        }
        
        set {
            self.zero = (newValue >> 7) == 1
            self.subtract = (newValue >> 6) == 1
            self.halfCarry = (newValue >> 5) == 1
            self.carry = (newValue >> 4) == 1
        }
    }
}

enum Instruction {
  case ADD(ArithmeticTarget)
}

enum ArithmeticTarget {
    case A, B, C, D, E, H, L
}
