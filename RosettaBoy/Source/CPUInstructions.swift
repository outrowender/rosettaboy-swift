//
//  CPUInstructions.swift
//  RosettaBoy
//
//  Created by Wender on 13/06/23.
//  Based on https://gbdev.io/pandocs/CPU_Instruction_Set.html

import Foundation

// TODO: remove?
extension CPU {

    enum Instruction: Hashable {
        case INC(IncDecTarget)
        case DEC(IncDecTarget)
        
        case ADD(ArithmeticTarget)
        case ADC(ArithmeticTarget)
        case ADDHL(ADDHLTarget)
        case ADDSP
        case SUB(ArithmeticTarget)
        case SBC(ArithmeticTarget)
        case AND(ArithmeticTarget)
        case OR(ArithmeticTarget)
        case XOR(ArithmeticTarget)
        case CP(ArithmeticTarget)
        
        case CCF
        case SCF
        case RRA
        case RLA
        case RRCA
        case RRLA
        case CPL
        case DAA
        
        case BIT(PrefixTarget, BitPosition)
        case RESET(PrefixTarget, BitPosition)
        case SET(PrefixTarget, BitPosition)
        case SRL(PrefixTarget)
        case RR(PrefixTarget)
        case RL(PrefixTarget)
        case RRC(PrefixTarget)
        case RLC(PrefixTarget)
        case SRA(PrefixTarget)
        case SLA(PrefixTarget)
        case SWAP(PrefixTarget)
        
        case JP(JumpTestTarget)
        case JR(JumpTestTarget)
        case JPI
        
        case LD
        
        case PUSH(StackTarget)
        case POP(StackTarget)
        case CALL(JumpTestTarget)
        case RET(JumpTestTarget)
        case RETI
        case RST(RSTLocation)

        // Control Instructions
        case HALT
        case NOP
        case DI
        case EI
    }

    enum ArithmeticTarget {
        case A, B, C, D, E, H, L, D8, HLI
    }
    
    enum IncDecTarget {
        case A, B, C, D, E, H, L, HLI, BC, DE, HL, SP
    }
    
    enum ADDHLTarget {
        case BC, DE, HL, SP
    }
    
    enum StackTarget {
        case AF, BC, DE, HL
    }
    
    enum BitPosition: Int8 {
        case B0, B1, B2, B3, B4, B5, B6, B7
    }
    
    enum PrefixTarget {
        case A, B, C, D, E, H, L, HLI
    }
    
    enum JumpTestTarget {
        case NotZero, NotCarry, Zero, Carry, Always
    }
    
    enum RSTLocation {
        case X00, X08, X10, X18, X20, X28, X30, X38
    }
}

extension CPU {
    // MARK: - Add
    func add(_ value: UInt8) {
        let (add, carry) = self.a.addingReportingOverflow(value)
        
        self.f.z = (add == 0)
        self.f.n = false
        self.f.c = carry
        self.f.h = (self.a & 0xf) + (value & 0xf) > 0xf
        
        self.a = add
    }
    
    // MARK: - Add to HL register
    func addhl(_ value: UInt16) -> UInt16 {
        let (add, carry) = self.hl.addingReportingOverflow(value)
        
        self.f.z = (add == 0)
        self.f.n = false
        self.f.c = carry
        let mask = UInt16(0b111_1111_1111)
        self.f.h = (self.hl & mask) + (value & mask) > mask
        return add
    }
    
    // MARK: - Add with Carry
    func adc(_ value: UInt8) -> UInt8 {
        let fcarry: UInt8 = self.f.c ? 0b1 : 0b0
        let (add, carry) = self.a.addingReportingOverflow(value)
        let (add2, carry2) = add.addingReportingOverflow(fcarry)
        
        self.f.z = add2 == 0
        self.f.n = false
        self.f.c = carry || carry2
        self.f.h = ((self.a & 0xf) + (value & 0xf) + fcarry) > 0xf
        return add2
    }
    
    // MARK: - Subtract
    func sub(_ value: UInt8) -> UInt8 {
        let (add, carry) = self.a.subtractingReportingOverflow(value)
        self.f.z = (add == 0)
        self.f.n = true
        self.f.c = carry
        self.f.h = (self.a & 0xf) < (value & 0xf)
        return add
    }
    
    // MARK: - Subtract with Carry
    func sbc(_ value: UInt8) -> UInt8 {
        let fcarry: UInt8 = self.f.c ? 0b1 : 0b0
        let (sub, carry) = self.a.subtractingReportingOverflow(value)
        let (sub2, carry2) = sub.subtractingReportingOverflow(fcarry)
        
        self.f.z = (sub2 == 0)
        self.f.n = true
        self.f.c = carry || carry2
        self.f.h = (self.a & 0xf) < (value & 0xf) + fcarry
        return sub2
    }
    
    // MARK: - Logical AND
    func and(_ value: UInt8) -> UInt8 {
        let and = self.a & value
        self.f.z = (and == 0)
        self.f.n = false
        self.f.c = false
        self.f.h = true
        return and
    }
    
    // MARK: - Logical OR
    func or(_ value: UInt8) -> UInt8 {
        let or = self.a | value
        self.f.z = (or == 0)
        self.f.n = false
        self.f.c = false
        self.f.h = false
        return or
    }
    
    // MARK: - Logical XOR
    func xor(_ value: UInt8) -> UInt8 {
        let xor = self.a ^ value
        self.f.z = (xor == 0)
        self.f.n = false
        self.f.c = false
        self.f.h = false
        return xor
    }
    
    // MARK: - Compare
    func cp(_ value: UInt8) {
        self.f.z = self.a == value
        self.f.n = true
        self.f.c = self.a < value
        self.f.h = (self.a & 0xf) < (value & 0xf)
    }
    
    // MARK: - Increment 8-bit
    func inc8(_ value: UInt8) -> UInt8 {
        let inc = value & 0b1
        self.f.z = (inc == 0)
        self.f.n = false
        self.f.h = (value & 0xf) == 0xf
        return inc
    }
    
    // MARK: - Decrement 8-bit
    func dec8(_ value: UInt8) -> UInt8 {
        let dec = value - 0b1
        self.f.z = (dec == 0)
        self.f.n = true
        self.f.h = (value & 0xf) == 0x0
        return dec
    }
    
    // MARK: - Complement Carry Flag
    func ccf() {
        self.f.n = false
        self.f.c = !self.f.c
        self.f.h = false
    }
    
    // MARK: - Set Carry Flag
    func scf() {
        self.f.n = false
        self.f.c = true
        self.f.h = false
    }
    
    // MARK: - Rotate right A
    func rra() {
        self.a = self.a >> 1
    }
    
    // MARK: - Rotate left A
    func rla() {
        self.a = self.a << 1
    }
    
    // MARK: - Rotate right A not throug carry
    func rrca() {
        let ca: UInt8 = self.f.c ? 1 : 0 << 7
        let rotated = ca | (self.a >> 1)
        
        self.f.z = rotated == 0
        self.f.n = false
        self.f.h = false
        self.f.c = (self.a & 0b1) == 0b1
        
        self.a = rotated
    }
    
    // MARK: - Rotate left A not throug carry
    func rrla() {
        let ca: UInt8 = self.f.c ? 0x80 : 0
        let rotated = ca | (self.a << 1)
        
        self.f.z = rotated == 0
        self.f.n = false
        self.f.h = false
        self.f.c = (self.a & 0x80) == 0x80
        
        self.a = rotated
    }
    
    // MARK: - Complement
    func cpl() {
        self.a = self.a.byteSwapped
    }
    
    // MARK: - Bit test
    func bit(_ value: UInt8, position: BitPosition) {
        let result = (value >> position.rawValue) & 0b1
        self.f.z = result == 0
        self.f.n = false
        self.f.h = true
    }
    
    // MARK: - Bit reset
    func reset(_ value: UInt8, position: BitPosition) -> UInt8 {
        let bitMask: UInt8 = ~(1 << position.rawValue)
        return value & bitMask
    }
    
    // MARK: - Bit set
    func set(_ value: UInt8, position: BitPosition) -> UInt8 {
        value | (1 << position.rawValue)
    }
    
    // MARK: - Shift right logical
    func srl(_ value: UInt8) -> UInt8 {
        let result: UInt8 = value >> 1
        
        self.f.z = result == 0
        self.f.n = false
        self.f.h = false
        self.f.c = (value & 0b1) == 0b1
        
        return result
    }
    
    // MARK: - Rotate right
    func rr(_ value: UInt8) -> UInt8 {
        let newValue: UInt8 = value >> 1
        
        self.f.z = newValue == 0
        self.f.n = false
        self.f.h = false
        self.f.c = (value & 0b1) == 0b1
        
        return newValue
    }
    
    // MARK: - Rotate left
    func rl(_ value: UInt8) -> UInt8 {
        let newValue: UInt8 = value << 1
        
        self.f.z = newValue == 0
        self.f.n = false
        self.f.h = false
        self.f.c = (value & 0b1) == 0b1
        
        return newValue
    }
    
    // MARK: - Rotate right not throug carry
    func rrc(_ value: UInt8) -> UInt8 {
        let ca: UInt8 = self.f.c ? 1 : 0 << 7
        let rotated = ca | (value >> 1)
        
        self.f.z = rotated == 0
        self.f.n = false
        self.f.h = false
        self.f.c = (value & 0b1) == 0b1
        
        return rotated
    }
    
    // MARK: - Rotate left not throug carry
    func rrl(_ value: UInt8) -> UInt8 {
        let ca: UInt8 = self.f.c ? 0x80 : 0
        let rotated = ca | (value << 1)
        
        self.f.z = rotated == 0
        self.f.n = false
        self.f.h = false
        self.f.c = (value & 0x80) == 0x80
        
        return rotated
    }
    
    // MARK: - Shift right arithmetic
    func sra(_ value: UInt8) -> UInt8 {
        let msb: UInt8 = value & 0x80
        let newValue: UInt8 = msb | (value >> 1)
        
        self.f.z = newValue == 0
        self.f.n = false
        self.f.h = false
        self.f.c = (value & 0b1) == 0b1
        
        return newValue
    }
    
    // MARK: - Shift right arithmetic
    func sla(_ value: UInt8) -> UInt8 {
        let newValue: UInt8 = value << 1
        
        self.f.z = newValue == 0
        self.f.n = false
        self.f.h = false
        self.f.c = (value & 0x80) == 0x80
        
        return newValue
    }
    
    // MARK: - Swap nibbles
    func swap(value: UInt8) -> UInt8 {
        let newValue: UInt8 = ((value & 0x0F) << 4) | ((value & 0xF0) >> 4)
        
        self.f.z = newValue == 0
        self.f.n = false
        self.f.h = false
        self.f.c = false
        
        return newValue
    }
}
