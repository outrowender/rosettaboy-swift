//
//  CPUTests.swift
//  RosettaBoyTests
//
//  Created by Wender on 28/04/23.
//

import XCTest
@testable import RosettaBoy

final class CPUTests: XCTestCase {
    
    // MARK: - Simple register operation
    func testVRegistersShouldDoAF() throws {
        // given
        let cpu = CPU()
        
        // when
        cpu.af = UInt16(0b1000_0011_0010_0000)
        
        // then
        XCTAssertEqual(cpu.a, UInt8(0b1000_0011))
        XCTAssertEqual(cpu.f.u8, UInt8(0b0010_0000))
        XCTAssertEqual(cpu.af, UInt16(0b1000_0011_0010_0000))
    }
    
    func testVRegistersShouldDoBC() throws {
        // given
        let cpu = CPU()
        
        // when
        cpu.bc = UInt16(0b1000_0011_0000_1010)
        
        // then
        XCTAssertEqual(cpu.b, UInt8(0b1000_0011))
        XCTAssertEqual(cpu.c, UInt8(0b0000_1010))
        XCTAssertEqual(cpu.bc, UInt16(0b1000_0011_0000_1010))
    }
    
    func testVRegistersShouldDoDE() throws {
        // given
        let cpu = CPU()
        
        // when
        cpu.de = UInt16(0b1000_0011_0000_1010)
        
        // then
        XCTAssertEqual(cpu.d, UInt8(0b1000_0011))
        XCTAssertEqual(cpu.e, UInt8(0b0000_1010))
        XCTAssertEqual(cpu.de, UInt16(0b1000_0011_0000_1010))
    }
    
    func testVRegistersShouldDoHI() throws {
        // given
        let cpu = CPU()
        
        // when
        cpu.hl = UInt16(0b1000_0011_0000_1010)
        
        // then
        XCTAssertEqual(cpu.h, UInt8(0b1000_0011))
        XCTAssertEqual(cpu.l, UInt8(0b0000_1010))
        XCTAssertEqual(cpu.hl, UInt16(0b1000_0011_0000_1010))
    }
    
    // MARK: - Flags register logic
    func testFlagsInitializersShouldProduceSameResult() throws {
        // when
        let flags = CPU.Flags(0b1000_0000)
        let flags2 = CPU.Flags(z: true, n: false, h: false, c: false)
        
        // then
        XCTAssertEqual(flags, flags2)
    }
    
    func testFlagsShouldInitializeWithBit() throws {
        // when
        let flags = CPU.Flags(z: true, n: false, h: false, c: true)
        
        // then
        XCTAssertTrue(flags.z && flags.c)
        XCTAssertEqual(flags.u8, 0b1001_0000)
    }
 
    func testFlagsShouldAlwaysClearFirst4bits() throws {
        // given
        let flags = CPU.Flags(0b0100_1111)
        
        // then
        XCTAssertTrue(flags.n)
        XCTAssertFalse(flags.z || flags.h || flags.c)
        XCTAssertEqual(flags.u8, 0b0100_0000)
    }
    
    // MARK: - Execution
    func testCarryFlagsShouldBeSetIf8bitAddIsHigherThanFF() throws {
        // given
        let cpu = CPU()
        
        // when
        cpu.a = 0b0000_0001
        cpu.b = 0b1111_1111
        cpu.add(cpu.b)
        
        // then
        XCTAssertEqual(cpu.a, 0b0000_0000)
        XCTAssertTrue(cpu.f.z)
        XCTAssertFalse(cpu.f.n)
        XCTAssertTrue(cpu.f.c)
        XCTAssertTrue(cpu.f.h)
    }
    
    func testHalfCarryFlagShouldBeSetIfHalfCarry() throws {
        // given
        let cpu = CPU()
        
        // when
        cpu.a = 0b1000_1111
        cpu.b = 0b0000_0001
        cpu.add(cpu.b)
        
        // then
        XCTAssertEqual(cpu.a, 0b1001_0000)
        XCTAssertFalse(cpu.f.z)
        XCTAssertFalse(cpu.f.n)
        XCTAssertFalse(cpu.f.c)
        XCTAssertTrue(cpu.f.h)
    }
    
    func testHalfCarryFlagsShouldBeSetIfCarryAndHalfCarry() throws {
        // given
        let cpu = CPU()
        
        // when
        cpu.a = 0b1000_1111 // 143
        cpu.b = 0b1000_0001 // 129
        cpu.add(cpu.b)
        
        // then
        XCTAssertEqual(cpu.a, 0b0001_0000)
        XCTAssertFalse(cpu.f.z)
        XCTAssertFalse(cpu.f.n)
        XCTAssertTrue(cpu.f.c)
        XCTAssertTrue(cpu.f.h)
    }
    
    func testExecuteShouldRunOperations() throws {
        let cpu = CPU()
        
        cpu.b = 0b1
        
        cpu.execute(.ADD(.B))
        
        XCTAssertEqual(cpu.a, 0b1)
    }
    
//    func testReadByteFromRom() throws {
//        let fs = FileSystem()
//        
//        let data = fs.readRom()
//        
//        let f = data[0x0147]
//        
//        print(f)
//        
//    }
//
//    func testExecuteAddShouldDoFalseForOverflowwhenItsNot() throws {
//        // given
//        var cpu = CPU()
//        cpu.a = 0b0
//        cpu.c = 0b0000_0001
//        
//        // when
//        cpu.execute(.ADD(.C))
//    
//        // then
//        XCTAssertEqual(cpu.a, 0b0000_0001)
//        XCTAssertFalse(cpu.f.zero)
//        XCTAssertFalse(cpu.f.subtract)
//        XCTAssertFalse(cpu.f.halfCarry)
//        XCTAssertFalse(cpu.f.carry)
//    }
//    
//    func testExecuteAddShouldDealWithOverflow() throws {
//        // given
//        var cpu = CPU()
//        cpu.a = 0b0000_1111
//        cpu.c = 0b0000_0001
//        
//        // when
//        cpu.execute(.ADD(.C))
//
//        // then
//        XCTAssertEqual(cpu.a, 0b0001_0000)
//        XCTAssertFalse(cpu.f.zero)
//        XCTAssertFalse(cpu.f.subtract)
//        XCTAssertTrue(cpu.f.halfCarry)
//        XCTAssertFalse(cpu.f.carry)
//    }
//    
//    func testExecuteAddShouldDealWithFullOverflow() throws {
//        // given
//        var cpu = CPU()
//        cpu.a = 0b1111_1111
//        cpu.c = 0b0000_0001
//        
//        // when
//        cpu.execute(.ADD(.C))
//
//        // then
//        XCTAssertEqual(cpu.a, 0b0)
//        XCTAssertTrue(cpu.f.zero)
//        XCTAssertFalse(cpu.f.subtract)
//        XCTAssertTrue(cpu.f.halfCarry)
//        XCTAssertTrue(cpu.f.carry)
//    }
//    
//    func testExecuteAddHLShouldDealWithOverflow() throws {
//        // given
//        var cpu = CPU()
//        
//        cpu.bc = 0b0000_0001_0000_0001
//        cpu.hl = 0b0001_0001_0001_0011
//        
//        // when
//        cpu.execute(.ADDHL(.BC))
//    
//        // then
//        XCTAssertEqual(cpu.hl, 0b0001_0010_0001_0100)
//        XCTAssertFalse(cpu.f.zero)
//        XCTAssertFalse(cpu.f.subtract)
//        XCTAssertFalse(cpu.f.halfCarry)
//        XCTAssertFalse(cpu.f.carry)
//    }
//    
//    func testExecuteAddHLShouldDealWithOverflowWithHalfCarry() throws {
//        // given
//        var cpu = CPU()
//        
//        cpu.bc = 0b0000_0111_1111_1111
//        cpu.hl = 0b1
//        
//        // when
//        cpu.execute(.ADDHL(.BC))
//    
//        // then
//        XCTAssertEqual(cpu.hl, 0b0000_1000_0000_0000)
//        XCTAssertFalse(cpu.f.zero)
//        XCTAssertFalse(cpu.f.subtract)
//        XCTAssertTrue(cpu.f.halfCarry)
//        XCTAssertFalse(cpu.f.carry)
//    }
//    
//    func testExecuteAddHLShouldDealWithOverflowWithOverflow() throws {
//        // given
//        var cpu = CPU()
//        
//        cpu.bc = 0b1111_1111_1111_1111
//        cpu.hl = 0b1
//        
//        // when
//        cpu.execute(.ADDHL(.BC))
//    
//        // then
//        XCTAssertEqual(cpu.hl, 0b0)
//        XCTAssertTrue(cpu.f.zero)
//        XCTAssertFalse(cpu.f.subtract)
//        XCTAssertTrue(cpu.f.halfCarry)
//        XCTAssertTrue(cpu.f.carry)
//    }
//    
//    func testExecuteAddHLShouldDealWithOverflowWithFullOverflow() throws {
//        // given
//        var cpu = CPU()
//        
//        cpu.bc = 0b1111_1111_1111_1111
//        cpu.hl = 0b0000_0000_0000_0010
//        
//        // when
//        cpu.execute(.ADDHL(.BC))
//    
//        // then
//        XCTAssertEqual(cpu.hl, 0b1)
//        XCTAssertFalse(cpu.f.zero)
//        XCTAssertFalse(cpu.f.subtract)
//        XCTAssertTrue(cpu.f.halfCarry)
//        XCTAssertTrue(cpu.f.carry)
//    }
}
