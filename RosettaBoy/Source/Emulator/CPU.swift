//
//  CPU.swift
//  RosettaBoy
//
//  Created by Wender on 28/04/23.
//  Based on https://gbdev.io/pandocs/CPU_Registers_and_Flags.html
//  More https://www.pastraiser.com/cpu/gameboy/gameboy_opcodes.html
//  https://archive.org/details/GameBoyProgManVer1.1/page/n85/mode/2up

import Foundation

// MARK: - CPU bit Architecture
class CPU {
    
    init() { }
    
    // 8-bit Registers
    var a: UInt8 = 0b0000_0000
    var b: UInt8 = 0b0000_0000
    var c: UInt8 = 0b0000_0000
    var d: UInt8 = 0b0000_0000
    var e: UInt8 = 0b0000_0000
    var f: Flags = .init(0b0000_0000)
    var h: UInt8 = 0b0000_0000
    var l: UInt8 = 0b0000_0000
    
    // Virtual 16-bit Registers
    var af: UInt16 {
        get { UInt16(UInt16(a) << 8 + UInt16(f.u8)) }
        
        set {
            self.a = UInt8(newValue >> 8 & 0x00ff)
            self.f = .init(UInt8(newValue & 0x00ff))
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
    
    // Program counter and Stack pointer
    var pc: UInt16 = 0
    var sp: UInt16 = 0

    struct Flags: Equatable {
        var z: Bool = false // 7 zero
        var n: Bool = false // 6 subtract
        var h: Bool = false // 5 half-carry
        var c: Bool = false // 4 carry
        
        init(z: Bool, n: Bool, h: Bool, c: Bool) {
            self.z = z
            self.n = n
            self.h = h
            self.c = c
        }
        
        init(_ u8: UInt8) {
            self.u8 = u8
        }
        
        var u8: UInt8 {
            get {
                UInt8(z ? 128 : 0) | UInt8(n ? 64 : 0) | UInt8(h ? 32 : 0) | UInt8(c ? 16 : 0)
            }
            
            set {
                self.z = (newValue >> 7) == 1
                self.n = (newValue >> 6) == 1
                self.h = (newValue >> 5) == 1
                self.c = (newValue >> 4) == 1
            }
        }
    }
    
    struct OpArg {
        var u8: UInt8 // B
        var i8: Int8 // b
        var u16: UInt16 // H
    }
}

// MARK: - CPU logic

extension CPU {
    
    func execute(_ instruction: CPU.Instruction) {
        
        let instructionMap: [CPU.Instruction: () -> ()] = [
            .ADD(.B): { self.add(self.b) },
            .ADD(.C): { self.add(self.c) },
            .ADD(.D): { self.add(self.d) }
        ]
        
        guard let executable = instructionMap[instruction] else {
            fatalError("\(instruction) not implemented")
        }

        executable()
    }
    
    func tick() {
        // TODO: impl
    }
    
    func tickInstructions() {
        // TODO: impl
    }
    
    func tickMain(ram: inout RAM, op: UInt8, arg: OpArg) {
        switch op {
        case 0x01:
            self.bc = arg.u16
        case 0x02:
            ram.set(self.bc, self.a)
        case 0x03:
            self.bc = self.bc &+ 1
        case 0x08:
            ram.set(arg.u16 &+ 1, UInt8(truncatingIfNeeded: (self.sp >> 8) & 0xFF))
            ram.set(arg.u16, UInt8(truncatingIfNeeded: self.sp & 0xFF))
        case 0x0A:
            self.a = ram.get(self.bc)
        case 0x0B:
            self.bc = self.bc &- 1
            // TODO: continue
        default:
            print("TODO: unexpected")
        }
    }
}
