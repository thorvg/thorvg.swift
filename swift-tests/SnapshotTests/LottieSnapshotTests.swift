/*
 * Copyright (c) 2025 - 2026 ThorVG project. All rights reserved.

 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:

 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.

 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

import XCTest

import SnapshotTesting

#if canImport(UIKit)
import UIKit
typealias PlatformImage = UIImage
#elseif canImport(AppKit)
import AppKit
typealias PlatformImage = NSImage
#endif

@testable import ThorVGSwift

class LottieSnapshotTests: XCTestCase {

    let size = CGSize(width: 1024, height: 1024)
    let contentRect = CGRect(x: 0, y: 0, width: 1024, height: 1024)
    let pixelFormat = PixelFormat.argb

    var lottie: Lottie {
        get throws {
            guard let url = Bundle.module.url(forResource: "test", withExtension: "json") else {
                preconditionFailure("Required resource for testing not found.")
            }
            return try Lottie(path: url.path)
        }
    }

    func testRenderFrame_WhenValidBufferAndSize_ReturnsCorrectImageSnapshot() throws {
        var buffer = [UInt32](repeating: 0, count: Int(size.width * size.height))
        let renderer = LottieRenderer(try lottie, size: size, buffer: &buffer, stride: Int(size.width), pixelFormat: pixelFormat)

        try renderer.render(frameIndex: 0, contentRect: contentRect)

        guard let image = PlatformImage(buffer: &buffer, size: size, pixelFormat: pixelFormat) else {
            XCTFail("Unable to create image from buffer")
            return
        }

        assertSnapshot(of: image, as: .image)
    }

    func testRenderFrame_WhenDesiredSizeIsLargerThanLottieOriginalSize_ReturnsScaledImageSnapshot() throws {
        let size = CGSize(width: 2048, height: 2048)
        let contentRect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        var buffer = [UInt32](repeating: 0, count: Int(size.width * size.height))
        let renderer = LottieRenderer(try lottie, size: size, buffer: &buffer, stride: Int(size.width), pixelFormat: pixelFormat)

        try renderer.render(frameIndex: 0, contentRect: contentRect)

        guard let image = PlatformImage(buffer: &buffer, size: size, pixelFormat: pixelFormat) else {
            XCTFail("Unable to create image from buffer")
            return
        }

        assertSnapshot(of: image, as: .image)
    }

    func testRenderFrame_WhenDesiredSizeIsSmallerThanLottieOriginalSize_ReturnsScaledImageSnapshot() throws {
        let size = CGSize(width: 512, height: 512)
        let contentRect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        var buffer = [UInt32](repeating: 0, count: Int(size.width * size.height))
        let renderer = LottieRenderer(try lottie, size: size, buffer: &buffer, stride: Int(size.width), pixelFormat: pixelFormat)

        try renderer.render(frameIndex: 0, contentRect: contentRect)

        guard let image = PlatformImage(buffer: &buffer, size: size, pixelFormat: pixelFormat) else {
            XCTFail("Unable to create image from buffer")
            return
        }

        assertSnapshot(of: image, as: .image)
    }

    func testRenderFrame_WhenCropped_ReturnsCroppedAndScaledImageSnapshot() throws {
        var buffer = [UInt32](repeating: 0, count: Int(size.width * size.height))
        let renderer = LottieRenderer(try lottie, size: size, buffer: &buffer, stride: Int(size.width), pixelFormat: pixelFormat)

        let crop = CGRect(x: 0, y: 0, width: 512, height: 512)

        try renderer.render(frameIndex: 0, contentRect: crop)

        guard let image = PlatformImage(buffer: &buffer, size: size, pixelFormat: pixelFormat) else {
            XCTFail("Unable to create image from buffer")
            return
        }

        assertSnapshot(of: image, as: .image)
    }

    func testRenderFrame_WhenCroppedWithNonUniformRectangle_ReturnsCroppedAndScaledImageSnapshot() throws {
        var buffer = [UInt32](repeating: 0, count: Int(size.width * size.height))
        let renderer = LottieRenderer(try lottie, size: size, buffer: &buffer, stride: Int(size.width), pixelFormat: pixelFormat)

        let crop = CGRect(x: 0, y: 0, width: 750, height: 1000)

        try renderer.render(frameIndex: 0, contentRect: crop)

        guard let image = PlatformImage(buffer: &buffer, size: size, pixelFormat: pixelFormat) else {
            XCTFail("Unable to create image from buffer")
            return
        }

        assertSnapshot(of: image, as: .image)
    }

    func testRenderFrame_WhenCenterCropped_ReturnsCroppedAndScaledImageSnapshot() throws {
        var buffer = [UInt32](repeating: 0, count: Int(size.width * size.height))
        let renderer = LottieRenderer(try lottie, size: size, buffer: &buffer, stride: Int(size.width), pixelFormat: pixelFormat)

        let crop = CGRect(x: 384, y: 384, width: 256, height: 256)

        try renderer.render(frameIndex: 0, contentRect: crop)

        guard let image = PlatformImage(buffer: &buffer, size: size, pixelFormat: pixelFormat) else {
            XCTFail("Unable to create image from buffer")
            return
        }

        assertSnapshot(of: image, as: .image)
    }

    func testRenderFrame_WhenCenterCroppedAndRotated_ReturnsCroppedScaledAndRotatedImageSnapshot() throws {
        var buffer = [UInt32](repeating: 0, count: Int(size.width * size.height))
        let renderer = LottieRenderer(try lottie, size: size, buffer: &buffer, stride: Int(size.width), pixelFormat: pixelFormat)

        let crop = CGRect(x: 384, y: 384, width: 256, height: 256)

        try renderer.render(frameIndex: 0, contentRect: crop, rotation: 90)

        guard let image = PlatformImage(buffer: &buffer, size: size, pixelFormat: pixelFormat) else {
            XCTFail("Unable to create image from buffer")
            return
        }

        assertSnapshot(of: image, as: .image)
    }

    func testRenderFrame_WhenRotated_ReturnsRotatedImageSnapshot() throws {
        var buffer = [UInt32](repeating: 0, count: Int(size.width * size.height))
        let renderer = LottieRenderer(try lottie, size: size, buffer: &buffer, stride: Int(size.width), pixelFormat: pixelFormat)

        let rotation = 90.0

        try renderer.render(frameIndex: 0, contentRect: contentRect, rotation: rotation)

        guard let image = PlatformImage(buffer: &buffer, size: size, pixelFormat: pixelFormat) else {
            XCTFail("Unable to create image from buffer")
            return
        }

        assertSnapshot(of: image, as: .image)
    }

    func testRenderFrame_WhenCroppedAndRotated_ReturnsCroppedAndRotatedImageSnapshot() throws {
        var buffer = [UInt32](repeating: 0, count: Int(size.width * size.height))
        let renderer = LottieRenderer(try lottie, size: size, buffer: &buffer, stride: Int(size.width), pixelFormat: pixelFormat)

        let crop = CGRect(x: 0, y: 0, width: 512, height: 512)
        let rotation = 90.0

        try renderer.render(frameIndex: 0, contentRect: crop, rotation: rotation)

        guard let image = PlatformImage(buffer: &buffer, size: size, pixelFormat: pixelFormat) else {
            XCTFail("Unable to create image from buffer")
            return
        }

        assertSnapshot(of: image, as: .image)
    }

    func testRenderFrame_WhenScaledCroppedAndRotated_ReturnsScaleCroppedAndRotatedImageSnapshot() throws {
        let size = CGSize(width: 2048, height: 2048)
        let crop = CGRect(x: 0, y: 0, width: 1024, height: 1024)
        let rotation = 90.0

        var buffer = [UInt32](repeating: 0, count: Int(size.width * size.height))
        let renderer = LottieRenderer(try lottie, size: size, buffer: &buffer, stride: Int(size.width), pixelFormat: pixelFormat)

        try renderer.render(frameIndex: 0, contentRect: crop, rotation: rotation)

        guard let image = PlatformImage(buffer: &buffer, size: size, pixelFormat: pixelFormat) else {
            XCTFail("Unable to create image from buffer")
            return
        }

        assertSnapshot(of: image, as: .image)
    }

    func testRenderFrame_WhenUsingABGRPixelFormat_ReturnsImageWithCorrectPixelValues() throws {
        let pixelFormat = PixelFormat.abgr
        var buffer = [UInt32](repeating: 0, count: Int(size.width * size.height))
        let renderer = LottieRenderer(try lottie, size: size, buffer: &buffer, stride: Int(size.width), pixelFormat: pixelFormat)

        try renderer.render(frameIndex: 0, contentRect: contentRect)

        guard let image = PlatformImage(buffer: &buffer, size: size, pixelFormat: pixelFormat) else {
            XCTFail("Unable to create image from buffer")
            return
        }

        assertSnapshot(of: image, as: .image)
    }
}

#if canImport(UIKit)
extension UIImage {
    convenience init?(buffer: Buffer, size: CGSize, pixelFormat: PixelFormat) {
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = pixelFormat.bitmapInfo.rawValue
        let bitsPerComponent = 8
        let bytesPerRow = Int(size.width) * 4

        guard let context = CGContext(
            data: buffer,
            width: Int(size.width),
            height: Int(size.height),
            bitsPerComponent: bitsPerComponent,
            bytesPerRow: bytesPerRow,
            space: colorSpace,
            bitmapInfo: bitmapInfo
        ) else {
            return nil
        }

        guard let cgImage = context.makeImage() else {
            return nil
        }

        self.init(cgImage: cgImage, scale: 1.0, orientation: .up)
    }
}
#elseif canImport(AppKit)
extension NSImage {
    convenience init?(buffer: Buffer, size: CGSize, pixelFormat: PixelFormat) {
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = pixelFormat.bitmapInfo.rawValue
        let bitsPerComponent = 8
        let bytesPerRow = Int(size.width) * 4

        guard let context = CGContext(
            data: buffer,
            width: Int(size.width),
            height: Int(size.height),
            bitsPerComponent: bitsPerComponent,
            bytesPerRow: bytesPerRow,
            space: colorSpace,
            bitmapInfo: bitmapInfo
        ) else {
            return nil
        }

        guard let cgImage = context.makeImage() else {
            return nil
        }

        self.init(cgImage: cgImage, size: size)
    }
}
#endif

extension PixelFormat {
    var bitmapInfo: CGBitmapInfo {
        switch self {
        case .argb:
            return [.byteOrder32Little, CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedFirst.rawValue)]
        case .abgr:
            return [.byteOrder32Big, CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)]
        }
    }
}
