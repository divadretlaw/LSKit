//
//  String+Extensions.swift
//  LSKit
//
//  Created by David Walter on 27.07.24.
//

import Foundation

extension String {
    func indent(prefix: String = "\t", separator: Character = "\n") -> String {
        self
            .split(separator: separator)
            .map { "\(prefix)\($0)" }
            .joined(separator: "\(separator)")
    }
}
