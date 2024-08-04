//
//  LSPKError.swift
//  LSKit
//
//  Created by David Walter on 24.07.24.
//

import Foundation

public enum LSPKError: Swift.Error, LocalizedError {
    /// The provided file is invalid.
    case invalidFile(String)
    /// The file relies on a feature that is currently not (yet) supported.
    case notSupported(String)

    public var errorDescription: String? {
        switch self {
        case let .invalidFile(description):
            return description
        case let .notSupported(description):
            return description
        }
    }
}
