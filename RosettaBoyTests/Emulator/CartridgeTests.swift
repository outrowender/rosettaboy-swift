//
//  CartridgeTests.swift
//  RosettaBoyTests
//
//  Created by Wender on 23/05/24.
//

import XCTest
@testable import RosettaBoy

final class CartridgeTests: XCTestCase {

    let fs = FileSystem()
    
    func testInitCartridgeShouldFillCorrectData() throws {
        let rom = fs.readBundleItem(named: "cpu_instrs.gb")!
        
        let cart = try Cartridge(at: URL(string: rom)!)
        
        XCTAssertEqual(cart.mbcType, .mbc1)
        XCTAssertEqual(cart.ramSize, 8192)
        XCTAssertEqual(cart.romBanks, 4)
        XCTAssertEqual(cart.name, "cpu_instrs.gb")
    }
    
    func testInitCartridge2ShouldFillCorrectData() throws {
        let rom = fs.readBundleItem(named: "tetris.gb")!
        
        let cart = try Cartridge(at: URL(string: rom)!)
        
        XCTAssertEqual(cart.mbcType, .rom_only)
        XCTAssertEqual(cart.ramSize, 8192)
        XCTAssertEqual(cart.romBanks, 2)
        XCTAssertTrue(cart.name.contains("TETRIS"))
    }

}
