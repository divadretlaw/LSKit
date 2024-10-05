//
//  Sequence+Extensions.swift
//  LSKit
//
//  Created by David Walter on 29.08.24.
//

import Foundation

extension Sequence {
    func sorted<T>(by keyPath: KeyPath<Element, T>) -> [Element] where T: Comparable {
        sorted { lhs, rhs in
            lhs[keyPath: keyPath] < rhs[keyPath: keyPath]
        }
    }
}
