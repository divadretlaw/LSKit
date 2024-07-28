//
//  LSPK+Version.swift
//  LSKit
//
//  Created by David Walter on 24.07.24.
//

import Foundation

public enum LSPKVersion: UInt32, Codable, Sendable {
    case v10 = 10
    case v15 = 15
    case v16 = 16
    case v18 = 18
    
    var hasCompressedFileEntryList: Bool {
        rawValue > 13
    }
    
    var fileEntryType: LSPKFileEntryRepresentable.Type {
        switch self {
        case .v10:
            LSPKFileEntry10.self
        case .v15:
            LSPKFileEntry15.self
        case .v16:
            LSPKFileEntry18.self
        case .v18:
            LSPKFileEntry18.self
        }
    }
}
