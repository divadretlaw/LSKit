//
//  LSPK.swift
//  LSKit
//
//  Created by David Walter on 27.07.24.
//

import Foundation

public protocol LSPK: Hashable, Equatable, Sendable {
    var signature: UInt32 { get }
    var version: LSPKVersion { get }
    
    var header: LSPKHeader { get }
    var entries: [LSPKFileEntry] { get }
    
    init?(url: URL) throws
    
    func contentsOf(entry: LSPKFileEntry) throws -> Data?
    func unpack(url: URL) throws
}
