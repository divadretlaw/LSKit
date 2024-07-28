//
//  Data+Extensions.swift
//  LSKit
//
//  Created by David Walter on 24.07.24.
//

import Foundation
import Compression

extension Data {
    func load<T>(index: Index, as type: T.Type) -> T {
        self[index..<index.advanced(by: MemoryLayout<T>.size)].withUnsafeBytes { pointer in
            pointer.loadUnaligned(as: T.self)
        }
    }
    
    func decompressed(size: Int, algorithm: compression_algorithm) throws -> Data {        
        let destinationBuffer = UnsafeMutablePointer<UInt8>.allocate(capacity: size)
        
        return try withUnsafeBytes { sourceBuffer in
            let typedPointer = sourceBuffer.bindMemory(to: UInt8.self)
            
            let compressedSize = compression_decode_buffer(
                destinationBuffer,
                size,
                typedPointer.baseAddress!, // swiftlint:disable:this force_unwrapping
                count,
                nil,
                algorithm
            )
            
            if compressedSize == 0 {
                throw LSPKError.decompressionFailed("")
            }
            
            return Data(bytesNoCopy: destinationBuffer, count: size, deallocator: .free)
        }
    }
}
