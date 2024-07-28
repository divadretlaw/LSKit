//
//  LSX+Config.swift
//  LSKit
//
//  Created by David Walter on 28.07.24.
//

import Foundation

extension LSX {
    public struct Config: Hashable, Equatable, Sendable {
        public let dependencies: LSXNode?
        public let moduleInfo: LSXNode.ModuleInfo?
        
        init?(lsx: LSX) {
            let rootNode = lsx.regions
                .first { $0.id == "Config" }?.nodes.first { $0.id == "root" }
            guard let rootNode else { return nil }
            
            self.dependencies = rootNode.children.first { $0.id == "Dependencies" }
            let moduleInfo = rootNode.children.first { $0.id == "ModuleInfo" }
            self.moduleInfo = LSXNode.ModuleInfo(node: moduleInfo)
        }
    }
}
