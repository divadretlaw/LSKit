//
//  LSPKError.swift
//  LSKit
//
//  Created by David Walter on 24.07.24.
//

import Foundation

public enum LSPKError: Swift.Error {
    case invalidFile(String)
    case versionNotSupported
    case decompressionFailed(String)
}
