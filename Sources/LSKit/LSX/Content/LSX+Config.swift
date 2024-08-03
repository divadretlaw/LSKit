//
//  LSX+Config.swift
//  LSKit
//
//  Created by David Walter on 28.07.24.
//

import Foundation

extension LSX {
    /// Convenience representation of an ``LSX`` containing
    ///
    /// ```xml
    /// <region id="Config">
    ///     <node id="root">...</node>
    /// </region>
    /// ```
    ///
    /// > For Example:
    /// > Mods in LSPK format contain a `meta.lsx` file in this format
    public struct Config: Hashable, Equatable, Sendable {
        /// Dependencies of the module
        public let dependencies: LSXNode?
        /// The ``LSXNode/ModuleInfo`` containg information about the module
        public let moduleInfo: LSXNode.ModuleInfo?
        /// The raw representation of the node
        public let raw: LSXNode

        init?(lsx: LSX) {
            let rootNode = lsx.regions
                .first { $0.id == "Config" }?.nodes.first { $0.id == "root" }
            guard let rootNode else { return nil }
            self.raw = rootNode

            self.dependencies = rootNode.children.first { $0.id == "Dependencies" }
            let moduleInfo = rootNode.children.first { $0.id == "ModuleInfo" }
            self.moduleInfo = LSXNode.ModuleInfo(node: moduleInfo)
        }
    }
}
