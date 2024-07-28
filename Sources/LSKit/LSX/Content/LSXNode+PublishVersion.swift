//
//  LSXNode+PublishVersion.swift
//  LSKit
//
//  Created by David Walter on 28.07.24.
//

import Foundation

extension LSXNode {
    public struct PublishVersion: Hashable, Equatable, Sendable {
        public let uuid: String?
        public let md5: String?
        public let name: String?
        public let description: String?
        public let folder: String?

        public let author: String?
        public let version: String?

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
