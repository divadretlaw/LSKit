//
//  LSXNode+Module.swift
//  LSKit
//
//  Created by David Walter on 28.07.24.
//

import Foundation

extension LSXNode {
    public struct Module: Hashable, Equatable, Sendable {
        public let uuid: String?

        public let raw: LSXNode

        init?(node: LSXNode?) {
            guard let node else { return nil }
            self.raw = node

            self.uuid = node.attributes.first { $0.id == "UUID" }?.value
        }
    }
}
