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
        cpu.af = UInt16(0b1000_0011_0010_0000)
        
        // THEN
        
        XCTAssertEqual(cpu.a, UInt8(0b1000_0011))
        XCTAssertEqual(cpu.f.asUint8, UInt8(0b0010_0000))
        XCTAssertEqual(cpu.af, UInt16(0b1000_0011_0010_0000))
    }
    
    func testVirtualRegistersMustDoBC() throws {
        
        // GIVEN
        var cpu = CPU()
        
        // WHEN
        cpu.bc = UInt16(0b1000_0011_0000_1010)
        
        // THEN
        
        XCTAssertEqual(cpu.b, UInt8(0b1000_0011))
        XCTAssertEqual(cpu.c, UInt8(0b0000_1010))
        XCTAssertEqual(cpu.bc, UInt16(0b1000_0011_0000_1010))
    }
    
    func testVirtualRegistersMustDoDE() throws {
        
        // GIVEN
        var cpu = CPU()
        
        // WHEN
        cpu.de = UInt16(0b1000_0011_0000_1010)
        
        // THEN
        
        XCTAssertEqual(cpu.d, UInt8(0b1000_0011))
        XCTAssertEqual(cpu.e, UInt8(0b0000_1010))
        XCTAssertEqual(cpu.de, UInt16(0b1000_0011_0000_1010))
    }
    
    func testVirtualRegistersMustDoHI() throws {
        
        // GIVEN
        var cpu = CPU()
        
        // WHEN
        cpu.hl = UInt16(0b1000_0011_0000_1010)
        
        // THEN
        
        XCTAssertEqual(cpu.h, UInt8(0b1000_0011))
        XCTAssertEqual(cpu.l, UInt8(0b0000_1010))
        XCTAssertEqual(cpu.hl, UInt16(0b1000_0011_0000_1010))
    }
    
    func testFlagsShouldConvertToBoolAndBackCorrectly() throws {
        // GIVEN
        let cpu = CPU.FRegister(0b0100_0000)
        
        // THEN
        XCTAssertTrue(cpu.subtract)
        XCTAssertFalse(cpu.zero || cpu.halfCarry || cpu.carry)
        XCTAssertEqual(cpu.asUint8, 0b0100_0000)
    }
    
    func testFlagsShouldInitializeWithBit() throws {
        // GIVEN
        let cpu = CPU.FRegister(
            zero: true,
            subtract: false,
            halfCarry: false,
            carry: true)
        
        // THEN
        XCTAssertTrue(cpu.zero && cpu.carry)
        XCTAssertEqual(cpu.asUint8, 0b1001_0000)
    }
    
    func testFlagsShouldAlwaysClearFirst4bits() throws {
        // GIVEN
        let cpu = CPU.FRegister(0b0100_1111)
        
        // THEN
        XCTAssertTrue(cpu.subtract)
        XCTAssertFalse(cpu.zero || cpu.halfCarry || cpu.carry)
        XCTAssertEqual(cpu.asUint8, 0b0100_0000)
    }
    
    func testExecuteAddShouldDoFalseForOverflowWhenItsNot() throws {
        // GIVEN
        var cpu = CPU()
        cpu.c = 0b0000_0001
        
        // WHEN
        cpu.execute(.ADD(.C))
    
        // THEN
        XCTAssertEqual(cpu.a, 0b0000_0001)
        XCTAssertFalse(cpu.f.zero)
        XCTAssertFalse(cpu.f.subtract)
        XCTAssertFalse(cpu.f.halfCarry)
        XCTAssertFalse(cpu.f.carry)
    }
    
    func testExecuteAddShouldDealWithOverflow() throws {
        // GIVEN
        var cpu = CPU()
        cpu.a = 0b0000_1111
        cpu.c = 0b0000_0001
        
        // WHEN
        cpu.execute(.ADD(.C))

        // THEN
        XCTAssertEqual(cpu.a, 0b0001_0000)
        XCTAssertFalse(cpu.f.zero)
        XCTAssertFalse(cpu.f.subtract)
        XCTAssertTrue(cpu.f.halfCarry)
        XCTAssertFalse(cpu.f.carry)
    }
    
    func testExecuteAddShouldDealWithFullOverflow() throws {
        // GIVEN
        var cpu = CPU()
        cpu.a = 0b1111_1111
        cpu.c = 0b0000_0001
        
        // WHEN
        cpu.execute(.ADD(.C))

        // THEN
        XCTAssertEqual(cpu.a, 0b0)
        XCTAssertTrue(cpu.f.zero)
        XCTAssertFalse(cpu.f.subtract)
        XCTAssertTrue(cpu.f.halfCarry)
        XCTAssertTrue(cpu.f.carry)
    }
    
}
