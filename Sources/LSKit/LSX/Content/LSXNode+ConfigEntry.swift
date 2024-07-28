//
//  LSXNode+ConfigEntry.swift
//  LSKit
//
//  Created by David Walter on 28.07.24.
//

import Foundation

extension LSXNode {
    public struct ConfigEntry: Hashable, Equatable, Sendable {
        public let mapKey: String?
        public let type: String?
        public let value: String?

        public let raw: LSXNode

        init?(node: LSXNode?) {
            guard let node else { return nil }
            self.raw = node

            self.mapKey = node.attributes.first { $0.id == "MapKey" }?.value
            self.type = node.attributes.first { $0.id == "Type" }?.value
            self.value = node.attributes.first { $0.id == "Value" }?.value
        }
    }
}
