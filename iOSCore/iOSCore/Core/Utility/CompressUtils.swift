//
//  CompressUtils.swift
//  iOSCore
//
//  Created by Chunlin Yao on 2026/4/13.
//

import Foundation
import zlib

/// 压缩工具
public enum CompressUtils {

    // MARK: - zlib

    /// 压缩数据 (gzip)
    public static func compress(_ source: Data) -> Data? {
        guard !source.isEmpty else { return Data() }
        let sourceBuffer = [UInt8](source)
        var outputData = Data()
        let outputBufferSize = 4096
        var outputBuffer = [UInt8](repeating: 0, count: outputBufferSize)

        var stream = z_stream()
        let streamSize = Int32(MemoryLayout<z_stream>.size)

        sourceBuffer.withUnsafeBufferPointer { ptr in
            stream.next_in = UnsafeMutablePointer(mutating: ptr.baseAddress!)
            stream.avail_in = uInt(sourceBuffer.count)

            guard deflateInit2_(&stream, Z_DEFAULT_COMPRESSION, Z_DEFLATED, MAX_WBITS + 16, MAX_MEM_LEVEL, Z_DEFAULT_STRATEGY, ZLIB_VERSION, streamSize) == Z_OK else {
                return
            }

            repeat {
                stream.avail_out = uInt(outputBufferSize)
                outputBuffer.withUnsafeMutableBufferPointer { outPtr in
                    stream.next_out = outPtr.baseAddress
                }

                let status = deflate(&stream, Z_FINISH)
                if status != Z_OK && status != Z_STREAM_END {
                    break
                }

                let bytesProduced = outputBufferSize - Int(stream.avail_out)
                outputData.append(contentsOf: outputBuffer[0..<bytesProduced])

                if status == Z_STREAM_END {
                    break
                }
            } while stream.avail_out == 0

            deflateEnd(&stream)
        }

        return outputData.isEmpty ? nil : outputData
    }

    /// 解压数据 (gzip)
    public static func decompress(_ source: Data) -> Data? {
        guard !source.isEmpty else { return Data() }
        let sourceBuffer = [UInt8](source)
        var outputData = Data()
        let outputBufferSize = 16384
        var outputBuffer = [UInt8](repeating: 0, count: outputBufferSize)

        var stream = z_stream()
        let streamSize = Int32(MemoryLayout<z_stream>.size)

        sourceBuffer.withUnsafeBufferPointer { ptr in
            stream.next_in = UnsafeMutablePointer(mutating: ptr.baseAddress!)
            stream.avail_in = uInt(sourceBuffer.count)

            guard inflateInit2_(&stream, MAX_WBITS + 16, ZLIB_VERSION, streamSize) == Z_OK else {
                return
            }

            repeat {
                stream.avail_out = uInt(outputBufferSize)
                outputBuffer.withUnsafeMutableBufferPointer { outPtr in
                    stream.next_out = outPtr.baseAddress
                }

                let status = inflate(&stream, Z_NO_FLUSH)
                if status != Z_OK && status != Z_STREAM_END && status != Z_BUF_ERROR {
                    break
                }

                let bytesProduced = outputBufferSize - Int(stream.avail_out)
                outputData.append(contentsOf: outputBuffer[0..<bytesProduced])

                if status == Z_STREAM_END {
                    break
                }
            } while stream.avail_out == 0

            inflateEnd(&stream)
        }

        return outputData.isEmpty ? nil : outputData
    }
}
