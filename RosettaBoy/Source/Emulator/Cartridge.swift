//
//  Cartridge.swift
//  RosettaBoy
//
//  Created by Wender on 23/05/24.
//

import Foundation

class Cartridge {
    private let fs = FileSystem()
    
    let path: URL
    
    private(set) var mbcType: MBC = .rom_only
    private(set) var romBanks: UInt = 0
    private(set) var ramSize: UInt = 0
    private(set) var name: String = ""
    
    // MARK: - Initialization
    init(at path: URL) throws {
        self.path = path
        
        let data = fs.readItem(at: path)
        
        try testMBC(data)
        try testRomBanks(data)
        try testRamSize(data)
        try testName(data)
    }
    
    // MARK: - Cartridge Tests
    private func testMBC(_ bundle: Data) throws {
        guard let mbc = MBC(rawValue: bundle[0x0147]) else {
            throw CartridgeError.invalidMBC
        }
        
        self.mbcType = mbc
    }
    
    private func testRomBanks(_ bundle: Data) throws {
        let romBankCountArray: [UInt8: UInt] = [
            0x00: 2,
            0x01: 4,
            0x02: 8,
            0x03: 16,
            0x04: 32,
            0x05: 64,
            0x06: 128,
            0x07: 256,
            0x08: 512
        ]
        
        guard let bankCount = romBankCountArray[bundle[0x0148]] else {
            throw CartridgeError.invalidBankCount
        }
        
        self.romBanks = bankCount
    }
    
    private func testRamSize(_ bundle: Data) throws {
        let ramSizeArray: [UInt8: UInt] = [
            0x00: 8192,
            0x01: 8192,
            0x02: 8192,
            0x03: 8192 * 4,
            0x04: 8192 * 16,
            0x05: 8192 * 8
        ]
        
        guard let ramSize = ramSizeArray[bundle[0x0149]] else {
            throw CartridgeError.invalidRamSize
        }
        
        self.ramSize = ramSize
    }
    
    private func testName(_ bundle: Data) throws {
        // TODO: review this logic
        let bytes = (0x0134...0x0143).map { bundle[$0] }
        
        guard let str = String(bytes: bytes, encoding: .ascii) else {
            name = path.lastPathComponent
            return
        }
        
        self.name = str
    }
}

// MARK: Data
extension Cartridge {
    
    enum MBC: UInt8 {
        case rom_only = 0x00
        case mbc1 = 0x01
        case mbc1_ram = 0x02
        case mbc1_ram_battery = 0x03
        case mbc2 = 0x05
        case mbc2_battery = 0x06
        case rom_ram = 0x08
        case rom_ram_battery = 0x09
        case mmm01 = 0x0B
        case mmm01_ram = 0x0C
        case mmm01_ram_battery = 0x0D
        case mbc3_timer_battery = 0x0F
        case mbc3_timer_ram_battery = 0x10
        case mbc3 = 0x11
        case mbc3_ram = 0x12
        case mbc3_ram_battery = 0x13
        case mbc5 = 0x19
        case mbc5_ram = 0x1A
        case mbc5_ram_battery = 0x1B
        case mbc5_rumble = 0x1C
        case mbc5_rumble_ram = 0x1D
        case mbc5_rumble_ram_battery = 0x1E
        case mbc6 = 0x20
        case mbc7_sensor_rumble_ram_battery = 0x22
        case pocket_camera = 0xFC
        case bandai_tama5 = 0xFD
        case huC3 = 0xFE
        case huC1_ram_battery = 0xFF
    }
    
    enum CartridgeError: Error {
        case invalidMBC
        case invalidBankCount
        case invalidRamSize
    }
}
