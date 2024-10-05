//
//  LSPK+Unpack.swift
//  LSKit
//
//  Created by David Walter on 25.08.24.
//

import Foundation

import BinaryUtils
import libzstd

extension LSPK {
    public func unpack(url: URL, progress: ((Double) -> Void)? = nil) async throws {
        try Task.checkCancellation()

        try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)

        let total = Double(entries.count)

        for (index, entry) in entries.enumerated() {
            try Task.checkCancellation()
            progress?(Double(index) / total)
            await Task.yield()

            guard let content = try contentsOf(entry: entry) else { continue }
            let file = url.appendingPathComponent(entry.name)
            try? FileManager.default.createDirectory(at: file.deletingLastPathComponent(), withIntermediateDirectories: true)
            try content.write(to: file)
        }

        progress?(1)
    }
}
