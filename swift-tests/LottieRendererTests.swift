import CoreMedia
import XCTest

@testable import ThorVGSwift

final class LottieRendererTests: XCTestCase {

    let size = CGSize(width: 1024, height: 1024)
    let contentRect = CGRect(x: 0, y: 0, width: 1024, height: 1024)
    let pixelFormat = PixelFormat.argb

    var lottie: Lottie!

    override func setUpWithError() throws {
        try super.setUpWithError()
        let url = Bundle.module.url(forResource: "test", withExtension: "json")!
        lottie = try Lottie(path: url.path)
    }

    func testRender_WithValidFrameIndex_BufferPopulatedWithContent() throws {
        var buffer = [UInt32](repeating: 0, count: Int(size.width * size.height))
        let renderer = LottieRenderer(lottie, size: size, buffer: &buffer, stride: Int(size.width), pixelFormat: pixelFormat)

        try renderer.render(frameIndex: 0, contentRect: contentRect)

        let bufferHasContent = buffer.contains { $0 != 0 }
        XCTAssertTrue(bufferHasContent, "Buffer should have non-zero values after rendering.")
    }

    func testRender_WithAllFrames_Succeeds() throws {
        var buffer = [UInt32](repeating: 0, count: Int(size.width * size.height))
        let renderer = LottieRenderer(lottie, size: size, buffer: &buffer, stride: Int(size.width), pixelFormat: pixelFormat)

        do {
            for index in 0 ... lottie.numberOfFrames {
                try renderer.render(frameIndex: index, contentRect: contentRect)
            }
        } catch {
            XCTFail("Expected to render all lottie frames successfully, but \(error) error was thrown")
        }
    }

    func testRenderFrame_WithFrameIndexBelowBounds_ThrowsError() throws {
        var buffer = [UInt32](repeating: 0, count: Int(size.width * size.height))
        let renderer = LottieRenderer(lottie, size: size, buffer: &buffer, stride: Int(size.width), pixelFormat: pixelFormat)

        do {
            try renderer.render(frameIndex: -1, contentRect: contentRect)

            XCTFail("Expected frameIndexOutOfRange error to be thrown, but no error was thrown.")
        } catch {
            XCTAssertEqual(error as? ThorVGError, .frameIndexOutOfRange)
        }
    }

    func testRenderFrame_WithFrameIndexAboveBounds_ThrowsError() throws {
        var buffer = [UInt32](repeating: 0, count: Int(size.width * size.height))
        let renderer = LottieRenderer(lottie, size: size, buffer: &buffer, stride: Int(size.width), pixelFormat: pixelFormat)

        do {
            try renderer.render(frameIndex: 180, contentRect: contentRect)

            XCTFail("Expected frameIndexOutOfRange error to be thrown, but no error was thrown.")
        } catch {
            XCTAssertEqual(error as? ThorVGError, .frameIndexOutOfRange)
        }
    }
}

private extension CMTime {
    init(seconds: TimeInterval) {
        self.init(seconds: seconds, preferredTimescale: 600)
    }
}
