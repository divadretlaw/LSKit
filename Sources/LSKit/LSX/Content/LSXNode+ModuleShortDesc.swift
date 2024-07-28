//
//  LSXNode+ModuleShortDesc.swift
//  LSKit
//
//  Created by David Walter on 28.07.24.
//

import Foundation

extension LSXNode {
    public struct ModuleShortDesc: Hashable, Equatable, Sendable {
        public let uuid: String?
        public let name: String?
        public let folder: String?
        public let md5: String?
        public let version64: String?

        public let raw: LSXNode

        init?(node: LSXNode?) {
            guard let node else { return nil }
            self.raw = node

            self.uuid = node.attributes.first { $0.id == "UUID" }?.value
            self.name = node.attributes.first { $0.id == "Name" }?.value
            self.folder = node.attributes.first { $0.id == "Folder" }?.value
            self.md5 = node.attributes.first { $0.id == "MD5" }?.value
            self.version64 = node.attributes.first { $0.id == "Version64" }?.value
        }
    }
}
