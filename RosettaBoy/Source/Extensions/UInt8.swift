//
//  File.swift
//  RosettaBoy
//
//  Created by Wender on 22/05/24.
//

import Foundation

extension UInt8 {
    
    /// Initializes a 8-bit integer from a boolean value
    /// - Parameter bool: true = 1, false = 0
    init(_ bool: Bool) {
        self = bool ? 1 : 0
    }
}
