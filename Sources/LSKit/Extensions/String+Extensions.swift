//
//  String+Extensions.swift
//  LSKit
//
//  Created by David Walter on 27.07.24.
//

import Foundation

extension String {
    func indent() -> String {
        self
            .split(separator: "\n")
            .map { "\t\($0)" }
            .joined(separator: "\n")
    }
}
