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

@testable import ThorVGSwift

final class LottieConfigurationTests: XCTestCase {
    
    func testDefaultConfiguration_HasExpectedValues() {
        let config = LottieConfiguration.default
        
        XCTAssertEqual(config.loopMode, .loop)
        XCTAssertEqual(config.speed, 1.0)
        XCTAssertEqual(config.contentMode, .scaleAspectFit)
        XCTAssertEqual(config.frameRate, 30.0)
        XCTAssertEqual(config.pixelFormat, .argb)
    }
    
    func testInit_WithCustomValues_StoresCorrectly() {
        let config = LottieConfiguration(
            loopMode: .playOnce,
            speed: 2.0,
            contentMode: .scaleAspectFit,
            frameRate: 30.0,
            pixelFormat: .abgr
        )
        
        XCTAssertEqual(config.loopMode, .playOnce)
        XCTAssertEqual(config.speed, 2.0)
        XCTAssertEqual(config.contentMode, .scaleAspectFit)
        XCTAssertEqual(config.frameRate, 30.0)
        XCTAssertEqual(config.pixelFormat, .abgr)
    }
    
    func testInit_WithPartialValues_UsesDefaults() {
        let config = LottieConfiguration(speed: 0.5)
        
        // Should use defaults for non-specified values
        XCTAssertEqual(config.loopMode, .loop)
        XCTAssertEqual(config.speed, 0.5) // Custom value
        XCTAssertEqual(config.contentMode, .scaleAspectFit)
        XCTAssertEqual(config.frameRate, 30.0)
        XCTAssertEqual(config.pixelFormat, .argb)
    }
}

