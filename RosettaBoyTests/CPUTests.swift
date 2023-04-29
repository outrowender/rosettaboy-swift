//
//  CPUTests.swift
//  RosettaBoyTests
//
//  Created by Wender on 28/04/23.
//

import Foundation
@testable import RosettaBoy
import XCTest


final class CPUTests: XCTestCase {
    
    func testVirtualRegistersMustDoAF() throws {
        
        // GIVEN
        var cpu = CPU()
        
        // WHEN
        cpu.af = UInt16(0b1000001100100000)
        
        // THEN
        
        XCTAssertEqual(cpu.a, UInt8(0b10000011))
        XCTAssertEqual(cpu.f.asUint8, UInt8(0b00100000))
        XCTAssertEqual(cpu.af, UInt16(0b1000001100100000))
    }
    
    func testVirtualRegistersMustDoBC() throws {
        
        // GIVEN
        var cpu = CPU()
        
        // WHEN
        cpu.bc = UInt16(0b1000001100001010)
        
        // THEN
        
        XCTAssertEqual(cpu.b, UInt8(0b10000011))
        XCTAssertEqual(cpu.c, UInt8(0b00001010))
        XCTAssertEqual(cpu.bc, UInt16(0b1000001100001010))
    }
    
    func testVirtualRegistersMustDoDE() throws {
        
        // GIVEN
        var cpu = CPU()
        
        // WHEN
        cpu.de = UInt16(0b1000001100001010)
        
        // THEN
        
        XCTAssertEqual(cpu.d, UInt8(0b10000011))
        XCTAssertEqual(cpu.e, UInt8(0b00001010))
        XCTAssertEqual(cpu.de, UInt16(0b1000001100001010))
    }
    
    func testVirtualRegistersMustDoHI() throws {
        
        // GIVEN
        var cpu = CPU()
        
        // WHEN
        cpu.hi = UInt16(0b1000001100001010)
        
        // THEN
        
        XCTAssertEqual(cpu.h, UInt8(0b10000011))
        XCTAssertEqual(cpu.i, UInt8(0b00001010))
        XCTAssertEqual(cpu.hi, UInt16(0b1000001100001010))
    }
    
    func testFlagsShouldConvertToBoolAndBackCorrectly() throws {
        // GIVEN
        let cpu = FRegister(0b01000000)
        
        // THEN
        XCTAssertTrue(cpu.subtract)
        XCTAssertFalse(cpu.zero || cpu.halfCarry || cpu.carry)
        XCTAssertEqual(cpu.asUint8, 0b01000000)
    }
    
    func testFlagsShouldInitializeWithBit() throws {
        // GIVEN
        let cpu = FRegister(
            zero: true,
            subtract: false,
            halfCarry: false,
            carry: true)
        
        // THEN
        XCTAssertTrue(cpu.zero && cpu.carry)
        XCTAssertEqual(cpu.asUint8, 0b10010000)
    }
    
    func testFlagsShouldAlwaysClearFirst4bits() throws {
        // GIVEN
        let cpu = FRegister(0b01001111)
        
        // THEN
        XCTAssertTrue(cpu.subtract)
        XCTAssertFalse(cpu.zero || cpu.halfCarry || cpu.carry)
        XCTAssertEqual(cpu.asUint8, 0b01000000)
    }
}
