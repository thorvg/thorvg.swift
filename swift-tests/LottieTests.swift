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
    
    func testFrameDuration_CalculatesCorrectly() throws {
        let lottie = try Lottie(path: testLottieUrl.path)
        
        // Expected: 3 seconds / 180 frames = 0.0166... seconds per frame
        let expected = CMTime(seconds: 3.0 / 180.0, preferredTimescale: 600)
        XCTAssertEqual(lottie.frameDuration, expected)
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
}

private extension CMTime {
    init(seconds: TimeInterval) {
        self.init(seconds: seconds, preferredTimescale: 600)
    }
}
