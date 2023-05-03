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
        case ADDHL(ArithmeticStackTarget)
    }

    enum ArithmeticTarget {
        case A, B, C, D, E, H, L
    }
    
    enum ArithmeticStackTarget {
        case AF, BC, DE, HL
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
            case .AF:
                let newValue = self.addhl(self.af)
                self.hl = newValue
            case .BC:
                let newValue = self.addhl(self.bc)
                self.hl = newValue
            case .DE:
                let newValue = self.addhl(self.de)
                self.hl = newValue
            case .HL:
                // TODO: implement
                print("Not implemented")
            }
        }
    }
    
    // MARK: - Add
    mutating func add(_ value: UInt8) -> UInt8 {
        let (add, carry) = self.a.addingReportingOverflow(value)
        self.f.zero = add == 0
        self.f.subtract = false
        self.f.carry = carry
        self.f.halfCarry = (self.a & 0xf) + (value & 0xf) > 0xf
        return add
    }
    
    // MARK: - Add to HL register
    mutating func addhl(_ value: UInt16) -> UInt16 {
        let (add, carry) = self.hl.addingReportingOverflow(value)
        
        self.f.zero = (add == 0)
        self.f.subtract = false
        self.f.carry = carry
        let mask = UInt16(0b111_1111_1111)
        self.f.halfCarry = (self.hl & mask) + (value & mask) > mask;
        return add
    }
    
    // MARK: - Add with Carry
    mutating func adc(_ value: UInt8) -> UInt8 {
        let fcarry: UInt8 = self.f.carry ? 0b1 : 0b0
        let (add, carry) = self.a.addingReportingOverflow(value)
        let (add2, carry2) = add.addingReportingOverflow(fcarry)
        
        self.f.zero = add2 == 0
        self.f.subtract = false
        self.f.carry = carry || carry2
        self.f.halfCarry = ((self.a & 0xf) + (value & 0xf) + fcarry) > 0xf
        return add2
    }
    
    // MARK: - Subtract
    mutating func sub(_ value: UInt8) -> UInt8 {
        let (add, carry) = self.a.subtractingReportingOverflow(value)
        self.f.zero = (add == 0)
        self.f.subtract = true
        self.f.carry = carry
        self.f.halfCarry = (self.a & 0xf) < (value & 0xf)
        return add
    }
    
    // MARK: - Subtract with Carry
    mutating func sbc(_ value: UInt8) -> UInt8 {
        let fcarry: UInt8 = self.f.carry ? 0b1 : 0b0
        let (sub, carry) = self.a.subtractingReportingOverflow(value)
        let (sub2, carry2) = sub.subtractingReportingOverflow(fcarry)

        self.f.zero = (sub2 == 0)
        self.f.subtract = true
        self.f.carry = carry || carry2
        self.f.halfCarry = (self.a & 0xf) < (value & 0xf) + fcarry
        return sub2
    }
    
    // MARK: - Logical AND
    mutating func and(_ value: UInt8) -> UInt8 {
        let and = self.a & value
        self.f.zero = (and == 0)
        self.f.subtract = false
        self.f.carry = false
        self.f.halfCarry = true
        return and
    }
    
    // MARK: - Logical OR
    mutating func or(_ value: UInt8) -> UInt8 {
        let or = self.a | value
        self.f.zero = (or == 0)
        self.f.subtract = false
        self.f.carry = false
        self.f.halfCarry = false
        return or
    }
    
    // MARK: - Logical XOR
    mutating func xor(_ value: UInt8) -> UInt8 {
        let xor = self.a ^ value
        self.f.zero = (xor == 0)
        self.f.subtract = false
        self.f.carry = false
        self.f.halfCarry = false
        return xor
    }
    
    // MARK: - Compare
    mutating func cp(_ value: UInt8) {
        self.f.zero = self.a == value
        self.f.subtract = true
        self.f.carry = self.a < value
        self.f.halfCarry = (self.a & 0xf) < (value & 0xf)
    }
    
    // MARK: - Increment 8-bit
    mutating func inc8(_ value: UInt8) -> UInt8 {
        let inc = value & 0b1
        self.f.zero = (inc == 0)
        self.f.subtract = false
        self.f.halfCarry = (value & 0xf) == 0xf
        return inc
    }
    
    // MARK: - Decrement 8-bit
    mutating func dec8(_ value: UInt8) -> UInt8 {
        let dec = value - 0b1;
        self.f.zero = (dec == 0);
        self.f.subtract = true;
        self.f.halfCarry = (value & 0xf) == 0x0;
        return dec
    }
    
    // MARK: - Complement Carry Flag
    mutating func ccf() {
        self.f.subtract = false
        self.f.carry = !self.f.carry
        self.f.halfCarry = false
    }
    
    // MARK: - Set Carry Flag
    mutating func scf() {
        self.f.subtract = false
        self.f.carry = true
        self.f.halfCarry = false
    }
    
    // MARK: - Rotate right A
    mutating func rra() {
        self.a = self.a >> 1
    }
    
    // MARK: - Rotate left A
    mutating func rla() {
        self.a = self.a << 1
    }
    
    
    mutating func RRCA() {}
    mutating func RRLA() {}
    
    // MARK: - Complement
    mutating func cpl() {
        self.a = self.a.byteSwapped
    }
    
    // MARK: - Bit test
    mutating func bit() {
        
    }
    
    // MARK: - Bit reset
    mutating func reset(_ target: ArithmeticTarget) {
        
    }
    
    mutating func SET() {}
    mutating func SRL() {}
    mutating func RR() {}
    mutating func RL() {}
    mutating func RRC() {}
    mutating func RLC() {}
    mutating func SRA() {}
    mutating func SLA() {}
    mutating func SWAP() {}
    
}


