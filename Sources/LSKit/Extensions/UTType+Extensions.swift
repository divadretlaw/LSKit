//
//  UTType+Extensions.swift
//  LSKit
//
//  Created by David Walter on 28.07.24.
//

import Foundation
import UniformTypeIdentifiers

public extension UTType {
    static var lspk: UTType {
        UTType(filenameExtension: "pak", conformingTo: .data) ?? .data
    }
    
    static var lsx: UTType {
        UTType(filenameExtension: "lsx", conformingTo: .xml) ?? .xml
    }
}
