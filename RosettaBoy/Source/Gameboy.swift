//
//  Gameboy.swift
//  RosettaBoy
//
//  Created by Wender on 16/06/23.
//

import Foundation

struct Gameboy {
    
    let cpu = CPU()
    
    func run() {
        while true {
            self.tick()
        }
    }
    
    func tick() {
        self.cpu.tick()
        // TODO: other stuff
    }
}
