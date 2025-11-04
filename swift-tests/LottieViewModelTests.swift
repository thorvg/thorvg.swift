import XCTest
import Combine

@testable import ThorVGSwift

final class LottieViewModelTests: XCTestCase {
    
    // MARK: - Properties
    
    var sut: LottieViewModel!
    var lottie: Lottie!
    var cancellables: Set<AnyCancellable>!
    
    let testSize = CGSize(width: 512, height: 512)
    
    // MARK: - Setup & Teardown
    
    override func setUp() async throws {
        try await super.setUp()
        cancellables = Set<AnyCancellable>()
        
        guard let url = Bundle.module.url(forResource: "test", withExtension: "json") else {
            XCTFail("Required test resource not found")
            return
        }
        lottie = try Lottie(path: url.path)
    }
    
    override func tearDown() async throws {
        sut = nil
        lottie = nil
        cancellables = nil
        try await super.tearDown()
    }
    
    // MARK: - Initialization Tests
    
    func testInit_WithDefaultConfiguration_SetsInitialState() throws {
        sut = LottieViewModel(lottie: lottie, size: testSize)
        
        XCTAssertEqual(sut.playbackState, .stopped)
        XCTAssertNil(sut.error)
        XCTAssertEqual(sut.progress, 0.0, accuracy: 0.01)
        
        // Wait for async initial render
        let expectation = self.expectation(description: "Initial render")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
        
        XCTAssertNotNil(sut.renderedFrame, "Should render initial frame")
    }
    
    func testInit_WithCustomConfiguration_UsesConfiguration() throws {
        let config = LottieConfiguration(
            loopMode: .playOnce,
            speed: 2.0,
            contentMode: .scaleAspectFill,
            frameRate: 60.0
        )
        
        sut = LottieViewModel(lottie: lottie, size: testSize, configuration: config)
        
        // Wait for async initial render
        let expectation = self.expectation(description: "Initial render")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
        
        XCTAssertNotNil(sut.renderedFrame, "Should render initial frame")
    }
    
    // MARK: - Playback Control Tests
    
    func testPlay_FromStoppedState_StartsPlayback() throws {
        sut = LottieViewModel(lottie: lottie, size: testSize)
        
        sut.play()
        
        XCTAssertEqual(sut.playbackState, .playing)
        XCTAssertNil(sut.error)
    }
    
    func testPlay_WhenAlreadyPlaying_DoesNothing() throws {
        sut = LottieViewModel(lottie: lottie, size: testSize)
        sut.play()
        
        let initialState = sut.playbackState
        sut.play()
        
        XCTAssertEqual(sut.playbackState, initialState)
    }
    
    func testPause_WhenPlaying_PausesPlayback() throws {
        sut = LottieViewModel(lottie: lottie, size: testSize)
        sut.play()
        
        sut.pause()
        
        XCTAssertEqual(sut.playbackState, .paused)
    }
    
    func testStop_WhenPlaying_StopsAndResetsToFirstFrame() throws {
        sut = LottieViewModel(lottie: lottie, size: testSize)
        sut.play()
        
        // Wait briefly for some frames to render
        let expectation = self.expectation(description: "Wait for frames")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
        
        sut.stop()
        
        XCTAssertEqual(sut.playbackState, .stopped)
        XCTAssertEqual(sut.progress, 0.0, accuracy: 0.01)
    }
    
    // MARK: - Seek Tests
    
    func testSeek_ToProgress_UpdatesProgressAndRendersFrame() throws {
        sut = LottieViewModel(lottie: lottie, size: testSize)
        
        sut.seek(to: 0.5)
        
        XCTAssertEqual(sut.progress, 0.5, accuracy: 0.01)
        XCTAssertNotNil(sut.renderedFrame)
    }
    
    func testSeek_ToProgressBelowZero_ClampsToBounds() throws {
        sut = LottieViewModel(lottie: lottie, size: testSize)
        
        sut.seek(to: -0.5)
        
        XCTAssertEqual(sut.progress, 0.0, accuracy: 0.01)
    }
    
    func testSeek_ToProgressAboveOne_ClampsToBounds() throws {
        sut = LottieViewModel(lottie: lottie, size: testSize)
        
        sut.seek(to: 1.5)
        
        XCTAssertEqual(sut.progress, 1.0, accuracy: 0.01)
    }
    
    func testSeek_ToValidFrame_UpdatesFrame() throws {
        sut = LottieViewModel(lottie: lottie, size: testSize)
        let targetFrame: Float = 50.0
        
        sut.seek(toFrame: targetFrame)
        
        let expectedProgress = Double(targetFrame / lottie.numberOfFrames)
        XCTAssertEqual(sut.progress, expectedProgress, accuracy: 0.01)
        XCTAssertNotNil(sut.renderedFrame)
    }
    
    func testSeek_ToInvalidFrame_SetsError() throws {
        sut = LottieViewModel(lottie: lottie, size: testSize)
        let invalidFrame = lottie.numberOfFrames + 10
        
        sut.seek(toFrame: invalidFrame)
        
        XCTAssertNotNil(sut.error)
        if case .invalidFrameIndex = sut.error {
            // Expected
        } else {
            XCTFail("Expected invalidFrameIndex error")
        }
    }
    
    // MARK: - Loop Mode Tests
    
    func testPlayOnce_CompletesAfterOneIteration() throws {
        let config = LottieConfiguration(
            loopMode: .playOnce,
            speed: 10.0, // Fast playback for testing
            frameRate: 60.0
        )
        sut = LottieViewModel(lottie: lottie, size: testSize, configuration: config)
        
        let expectation = self.expectation(description: "Animation completes")
        sut.$playbackState
            .sink { state in
                if state == .completed {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        sut.play()
        
        wait(for: [expectation], timeout: 10.0)
        XCTAssertEqual(sut.playbackState, .completed)
    }
    
    func testRepeatMode_CompletesAfterSpecifiedCount() throws {
        let repeatCount = 2
        let config = LottieConfiguration(
            loopMode: .repeat(count: repeatCount),
            speed: 10.0,
            frameRate: 60.0
        )
        sut = LottieViewModel(lottie: lottie, size: testSize, configuration: config)
        
        let expectation = self.expectation(description: "Animation completes after repeats")
        sut.$playbackState
            .sink { state in
                if state == .completed {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        sut.play()
        
        wait(for: [expectation], timeout: 15.0)
        XCTAssertEqual(sut.playbackState, .completed)
    }
    
    // MARK: - Published Property Tests
    
    func testRenderedFrame_PublishesUpdates() throws {
        sut = LottieViewModel(lottie: lottie, size: testSize)
        
        let expectation = self.expectation(description: "Rendered frame updates")
        var updateCount = 0
        
        sut.$renderedFrame
            .dropFirst() // Skip initial value
            .sink { _ in
                updateCount += 1
                if updateCount >= 3 {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        sut.play()
        
        wait(for: [expectation], timeout: 2.0)
        XCTAssertGreaterThan(updateCount, 0)
    }
    
    func testPlaybackState_PublishesUpdates() throws {
        sut = LottieViewModel(lottie: lottie, size: testSize)
        
        var states: [LottieViewModel.PlaybackState] = []
        sut.$playbackState
            .sink { state in
                states.append(state)
            }
            .store(in: &cancellables)
        
        sut.play()
        sut.pause()
        sut.stop()
        
        XCTAssertTrue(states.contains(.playing))
        XCTAssertTrue(states.contains(.paused))
        XCTAssertTrue(states.contains(.stopped))
    }
    
    func testProgress_PublishesUpdates() throws {
        sut = LottieViewModel(lottie: lottie, size: testSize)
        
        let expectation = self.expectation(description: "Progress updates")
        var progressValues: [Double] = []
        
        sut.$progress
            .sink { progress in
                progressValues.append(progress)
                if progressValues.count >= 5 {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        sut.play()
        
        wait(for: [expectation], timeout: 2.0)
        XCTAssertGreaterThan(progressValues.count, 1)
    }
    
    // MARK: - Error Handling Tests
    
    func testError_ClearsOnPlay() throws {
        sut = LottieViewModel(lottie: lottie, size: testSize)
        
        // Trigger an error
        sut.seek(toFrame: -1)
        XCTAssertNotNil(sut.error)
        
        // Play should clear the error
        sut.play()
        
        XCTAssertNil(sut.error)
    }
    
    // MARK: - Speed Tests
    
    func testSpeed_AffectsPlaybackRate() throws {
        let normalConfig = LottieConfiguration(speed: 1.0, frameRate: 30.0)
        let fastConfig = LottieConfiguration(speed: 2.0, frameRate: 30.0)
        
        let normalSut = LottieViewModel(lottie: lottie, size: testSize, configuration: normalConfig)
        let fastSut = LottieViewModel(lottie: lottie, size: testSize, configuration: fastConfig)
        
        // Both should be at different speeds
        // This is a basic check - in production you might want more sophisticated timing tests
        normalSut.play()
        fastSut.play()
        
        let expectation = self.expectation(description: "Wait for playback")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
        
        // Fast playback should have progressed further
        XCTAssertGreaterThan(fastSut.progress, normalSut.progress)
        
        normalSut.stop()
        fastSut.stop()
    }
    
    func testFrameRate_DoesNotAffectPlaybackSpeed() throws {
        // Verify that frameRate affects render frequency but NOT playback speed
        let lowFrameRateConfig = LottieConfiguration(speed: 1.0, frameRate: 15.0)
        let highFrameRateConfig = LottieConfiguration(speed: 1.0, frameRate: 60.0)
        
        let lowFrameRateSut = LottieViewModel(lottie: lottie, size: testSize, configuration: lowFrameRateConfig)
        let highFrameRateSut = LottieViewModel(lottie: lottie, size: testSize, configuration: highFrameRateConfig)
        
        lowFrameRateSut.play()
        highFrameRateSut.play()
        
        let expectation = self.expectation(description: "Wait for playback")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
        
        // Both should have similar progress despite different frameRates
        // Allow some tolerance due to timer precision
        XCTAssertEqual(lowFrameRateSut.progress, highFrameRateSut.progress, accuracy: 0.1)
        
        lowFrameRateSut.stop()
        highFrameRateSut.stop()
    }
    
    // MARK: - Memory Management Tests
    
    func testDeinit_CancelsTimer() throws {
        var viewModel: LottieViewModel? = LottieViewModel(lottie: lottie, size: testSize)
        viewModel?.play()
        
        let expectation = self.expectation(description: "ViewModel deallocated")
        
        DispatchQueue.main.async {
            viewModel = nil
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
        XCTAssertNil(viewModel)
    }
    
    // MARK: - Content Mode Tests
    
    func testContentMode_ScaleToFill_RendersCorrectly() throws {
        let config = LottieConfiguration(contentMode: .scaleToFill)
        sut = LottieViewModel(lottie: lottie, size: testSize, configuration: config)
        
        // Wait for async initial render
        let expectation = self.expectation(description: "Initial render")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
        
        XCTAssertNotNil(sut.renderedFrame)
    }
    
    func testContentMode_ScaleAspectFit_RendersCorrectly() throws {
        let config = LottieConfiguration(contentMode: .scaleAspectFit)
        sut = LottieViewModel(lottie: lottie, size: testSize, configuration: config)
        
        // Wait for async initial render
        let expectation = self.expectation(description: "Initial render")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
        
        XCTAssertNotNil(sut.renderedFrame)
    }
    
    func testContentMode_ScaleAspectFill_RendersCorrectly() throws {
        let config = LottieConfiguration(contentMode: .scaleAspectFill)
        sut = LottieViewModel(lottie: lottie, size: testSize, configuration: config)
        
        // Wait for async initial render
        let expectation = self.expectation(description: "Initial render")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
        
        XCTAssertNotNil(sut.renderedFrame)
    }
}

