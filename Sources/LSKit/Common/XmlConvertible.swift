//
//  XmlConvertible.swift
//  LSKit
//
//  Created by David Walter on 28.07.24.
//

import Foundation

public protocol XmlConvertible {
    /// A XML representation of this instance.
    var xmlDescription: String { get }
}
