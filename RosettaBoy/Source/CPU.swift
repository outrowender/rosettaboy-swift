//
//  CPU.swift
//  RosettaBoy
//
//  Created by Wender on 28/04/23.
//

import Foundation

struct CPU {
    // MARK: - 8-bit Registers
    
    var a: UInt8 = 0b0000_0000
    var b: UInt8 = 0b0000_0000
    var c: UInt8 = 0b0000_0000
    var d: UInt8 = 0b0000_0000
    var e: UInt8 = 0b0000_0000
    var f: FRegister = FRegister(0b0000_0000)
    var h: UInt8 = 0b0000_0000
    var l: UInt8 = 0b0000_0000
    
    // MARK: - Virtual 16-bit Registers

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
    
    var hl: UInt16 {
        get { UInt16(UInt16(h) << 8 + UInt16(l)) }
        
        set {
            self.h = UInt8(newValue >> 8 & 0x00ff)
            self.l = UInt8(newValue & 0x00ff)
        }
    }
    
    init() { }
}

extension CPU {
    
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
                UInt8(zero ? 128 : 0)     | //1000_0000
                UInt8(subtract ? 64 : 0)  | //0100_0000
                UInt8(halfCarry ? 32 : 0) | //0010_0000
                UInt8(carry ? 16 : 0)       //0001_0000
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
        case ADDHL(ArithmeticTarget)
    }

    enum ArithmeticTarget {
        case A, B, C, D, E, H, L
    }
}

// MARK: - CPU Execute logic

extension CPU {
    mutating func execute(_ instruction: Instruction) {
        switch instruction {
        case .ADD(let target):
            switch target {
            case .A:
                print("A")
            case .B:
                print("B")
            case .C:
                let newValue = self.add(self.c)
                self.a = newValue
            case .D:
                print("D")
            case .E:
                print("E")
            case .H:
                print("H")
            case .L:
                print("L")
            }
        case .ADDHL(let target):
            switch target {
            case .A:
                print("TODO")
            case .B:
                print("TODO")
            case .C:
                print("TODO")
            case .D:
                print("TODO")
            case .E:
                print("TODO")
            case .H:
                print("TODO")
            case .L:
                print("TODO")
            }
        }
    }
    
    // MARK: - ADD
    mutating func add(_ value: UInt8) -> UInt8 {
        let (partialValue, overflow) = self.a.addingReportingOverflow(value)
        self.f.zero = partialValue == 0
        self.f.subtract = false
        self.f.carry = overflow
        self.f.halfCarry = (self.a & 0xf) + (value & 0xf) > 0xf
        return partialValue
    }
    
    // MARK: - ADDHL
    mutating func addhl(_ value: UInt8) -> UInt8 {
        let (partialValue, overflow) = self.a.addingReportingOverflow(value)
        self.f.zero = partialValue == 0
        self.f.subtract = false
        self.f.carry = overflow
        self.f.halfCarry = (self.a & 0xf) + (value & 0xf) > 0xf
        return partialValue
        
        return value
    }
}


