//
//  ModLSPK.swift
//  LSKit
//
//  Created by David Walter on 28.07.24.
//

import Foundation
import BinaryUtils

public struct ModLSPK: LSPKProtocol {
    private let base: LSPK
    public let meta: LSX.Config

    public var url: URL {
        base.url
    }

    public var signature: UInt32 {
        base.signature
    }

    public var version: LSPKVersion {
        base.version
    }

    public var header: LSPKHeader {
        base.header
    }

    public var entries: [LSPKFileEntry] {
        base.entries
    }

    public init(url: URL) throws {
        let base = try LSPK(url: url)
        self.base = base

        guard let entry = base.entries.first(where: { $0.name.hasSuffix("meta.lsx") }) else {
            throw LSPKError.invalidFile("PAK does not contain 'meta.lsx'")
        }
        guard let metaLsx = try base.contentsOf(entry: entry) else {
            throw LSPKError.invalidFile("'meta.lsx' is empty")
        }
        guard let meta = LSX(data: metaLsx), let config = LSX.Config(lsx: meta) else {
            throw LSPKError.invalidFile("'meta.lsx' is not in the correct format")
        }
        self.meta = config
    }

    public func contentsOf(entry: LSPKFileEntry) throws -> Data? {
        try base.contentsOf(entry: entry)
    }

    public func unpack(url: URL) throws {
        try base.unpack(url: url)
    }
}
