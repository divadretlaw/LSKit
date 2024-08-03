//
//  LSXNode+PublishVersion.swift
//  LSKit
//
//  Created by David Walter on 28.07.24.
//

import Foundation

extension LSXNode {
    /// The publish version information of a mod
    public struct PublishVersion: Hashable, Equatable, Sendable {
        /// The UUID of the mod
        public let uuid: String?
        /// The MD5 hash of the mod
        public let md5: String?
        /// The name of the mod
        public let name: String?
        /// The description of the mod
        public let description: String?
        /// The folder of the mod
        public let folder: String?
        /// The author of the mod
        public let author: String?
        /// The version of the mod
        public let version: String?

        /// The raw representation of the node
        public let raw: LSXNode

        init?(node: LSXNode?) {
            guard let node else { return nil }

            self.raw = node

            self.uuid = node.attributes.first { $0.id == "UUID" }?.value
            self.md5 = node.attributes.first { $0.id == "MD5" }?.value
            self.name = node.attributes.first { $0.id == "Name" }?.value
            self.description = node.attributes.first { $0.id == "Description" }?.value
            self.folder = node.attributes.first { $0.id == "Folder" }?.value

            self.author = node.attributes.first { $0.id == "Author" }?.value
            self.version = node.attributes.first { $0.id == "Version" }?.value
        }
    }
}
