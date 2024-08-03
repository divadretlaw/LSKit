//
//  LSXNode+ModuleShortDesc.swift
//  LSKit
//
//  Created by David Walter on 28.07.24.
//

import Foundation

extension LSXNode {
    /// A `ModuleShortDesc` within `Mods` in the `modsettings.lsx`
    public struct ModuleShortDesc: Hashable, Equatable, Sendable {
        /// The UUID of the mod
        public let uuid: String?
        /// The name of the mod
        public let name: String?
        /// The folder of the mod
        public let folder: String?
        /// The MD5 hash of the mod
        public let md5: String?
        /// The version of the mod
        public let version64: String?
        /// The raw representation of the node
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
