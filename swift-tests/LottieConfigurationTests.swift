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
        XCTAssertTrue(config.autoPlay)
    }
    
    func testInit_WithCustomValues_StoresCorrectly() {
        let config = LottieConfiguration(
            loopMode: .playOnce,
            speed: 2.0,
            contentMode: .scaleAspectFit,
            frameRate: 30.0,
            pixelFormat: .abgr,
            autoPlay: false
        )
        
        XCTAssertEqual(config.loopMode, .playOnce)
        XCTAssertEqual(config.speed, 2.0)
        XCTAssertEqual(config.contentMode, .scaleAspectFit)
        XCTAssertEqual(config.frameRate, 30.0)
        XCTAssertEqual(config.pixelFormat, .abgr)
        XCTAssertFalse(config.autoPlay)
    }
    
    func testInit_WithPartialValues_UsesDefaults() {
        let config = LottieConfiguration(speed: 0.5)
        
        // Should use defaults for non-specified values
        XCTAssertEqual(config.loopMode, .loop)
        XCTAssertEqual(config.speed, 0.5) // Custom value
        XCTAssertEqual(config.contentMode, .scaleAspectFit)
        XCTAssertEqual(config.frameRate, 30.0)
        XCTAssertEqual(config.pixelFormat, .argb)
        XCTAssertTrue(config.autoPlay)
    }
}

