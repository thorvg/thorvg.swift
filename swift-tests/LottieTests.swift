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

import CoreMedia
import XCTest

@testable import ThorVGSwift

final class LottieTests: XCTestCase {

    let testLottieUrl = Bundle.module.url(forResource: "test", withExtension: "json")!

    func testInit_WithValidPath_ReturnsCorrectNumberOfFrames() throws {
        let lottie = try Lottie(path: testLottieUrl.path)

        XCTAssertEqual(lottie.numberOfFrames, 180)
    }

    func testInit_WithValidPath_ReturnsCorrectDuration() throws {
        let lottie = try Lottie(path: testLottieUrl.path)

        XCTAssertEqual(lottie.duration, CMTime(seconds: 3))
    }

    func testInit_WithInvalidPath_ThrowsError() {
        do {
            _ = try Lottie(path: "")

            XCTFail("Expected failedToLoadFromPath error to be thrown, but no error was thrown.")
        } catch {
            XCTAssertEqual(error as? LottieRenderingError, .failedToLoadFromPath)
        }
    }

    func testInit_WithValidString_Succeeds() throws {
        let animationJson = try NSMutableString(contentsOf: testLottieUrl, encoding: String.Encoding.utf8.rawValue) as String
        let lottie = try Lottie(string: animationJson)

        XCTAssertEqual(lottie.numberOfFrames, 180)
    }

    func testInit_WithInvalidString_ThrowsError() throws {
        do {
            _ = try Lottie(string: "")

            XCTFail("Expected failedToLoadFromString error to be thrown, but no error was thrown.")
        } catch {
            XCTAssertEqual(error as? LottieRenderingError, .failedToLoadFromDataString)
        }
    }

    func testFrameDuration_ReturnsCorrectDuration() throws {
        let lottie = try Lottie(path: testLottieUrl.path)

        // Expected: 3 seconds / 180 frames = 0.0166... seconds per frame
        let expected = CMTime(seconds: 3.0 / 180.0, preferredTimescale: 600)
        XCTAssertEqual(lottie.frameDuration, expected)
    }

    func testFrameSize_ReturnsCorrectSize() throws {
        let lottie = try Lottie(path: testLottieUrl.path)

        let expected = CGSize(width: 1024, height: 1024)
        XCTAssertEqual(lottie.frameSize, expected)
    }
}

private extension CMTime {
    init(seconds: TimeInterval) {
        self.init(seconds: seconds, preferredTimescale: 600)
    }
}
