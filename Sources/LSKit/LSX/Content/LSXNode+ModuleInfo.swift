//
//  LSXNode+ModuleInfo.swift
//  LSKit
//
//  Created by David Walter on 28.07.24.
//

import Foundation

extension LSXNode {
    /// Information about the mod
    public struct ModuleInfo: Hashable, Equatable, Sendable {
        /// Publish version information about the mod
        public let publishVersion: PublishVersion?
        public let scripts: LSXNode?
        public let targetModes: LSXNode?
        /// The raw representation of the node
        public let raw: LSXNode

        init?(node: LSXNode?) {
            guard let node else { return nil }
            self.raw = node

            let publishVersion = node.children.first { $0.id == "PublishVersion" }
            self.publishVersion = PublishVersion(node: publishVersion)
            self.scripts = node.children.first { $0.id == "Scripts" }
            self.targetModes = node.children.first { $0.id == "TargetModes" }
        }
    }
}
