//
//  LSX+ModuleSettings.swift
//  LSKit
//
//  Created by David Walter on 28.07.24.
//

import Foundation

extension LSX {
    /// Convenience representation of an ``LSX`` containing
    ///
    /// ```xml
    /// <region id="ModuleSettings">
    ///     <node id="root">...</node>
    /// </region>
    /// ```
    ///
    /// > For Example:
    /// > The user mod settings (`modsettings.lsx`) are in this format
    public struct ModuleSettings: Hashable, Equatable, Sendable {
        /// The mod order
        public let modOrder: [LSXNode.Module]
        /// The list of mods
        public let mods: [LSXNode.ModuleShortDesc]

        /// The raw representation of the node
        public let raw: LSXNode

        init?(lsx: LSX) {
            let rootNode = lsx.regions
                .first { $0.id == "ModuleSettings" }?.nodes.first { $0.id == "root" }
            guard let rootNode else { return nil }
            self.raw = rootNode

            let modOrder = rootNode.children.first { $0.id == "ModOrder" }
            self.modOrder = modOrder?.children.compactMap { LSXNode.Module(node: $0) } ?? []
            let mods = rootNode.children.first { $0.id == "Mods" }
            self.mods = mods?.children.compactMap { LSXNode.ModuleShortDesc(node: $0) } ?? []
        }
    }
}
