//
//  UInt64+Extensions.swift
//  LSKit
//
//  Created by David Walter on 23.07.24.
//

import Foundation

extension UInt64 {
    mutating func move<T>(by _: T.Type) {
        self += UInt64(MemoryLayout<T>.size)
    }
    
    func moved<T>(by _: T.Type) -> UInt64 {
        self + UInt64(MemoryLayout<T>.size)
    }
    
    mutating func move<T>(by value: T) {
        self += UInt64(MemoryLayout<T>.size)
    }
    
    func moved<T>(by value: T) -> UInt64 {
        self + UInt64(MemoryLayout<T>.size)
    }
    
    mutating func move<T>(by value: T) where T: RawRepresentable {
        self += UInt64(MemoryLayout<T.RawValue>.size)
    }
    
    func moved<T>(by value: T) -> UInt64 where T: RawRepresentable {
        self + UInt64(MemoryLayout<T.RawValue>.size)
    }
    
    mutating func move(by value: Data) {
        self += UInt64(value.count)
    }
    
    func moved(by value: Data) -> UInt64 {
        self + UInt64(value.count)
    }
}
