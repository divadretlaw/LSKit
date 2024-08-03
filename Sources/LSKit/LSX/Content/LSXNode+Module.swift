//
//  LSXNode+Module.swift
//  LSKit
//
//  Created by David Walter on 28.07.24.
//

import Foundation

extension LSXNode {
    /// A `Module` within `ModOrder` in the `modsettings.lsx`
    ///
    /// This is used to determine the load order of the mods
    public struct Module: Hashable, Equatable, Sendable {
        /// The UUID of the mod
        public let uuid: String?
        /// The raw representation of the node
        public let raw: LSXNode

        init?(node: LSXNode?) {
            guard let node else { return nil }
            self.raw = node

            self.uuid = node.attributes.first { $0.id == "UUID" }?.value
        }
    }
}
