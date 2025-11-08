import Combine
import SwiftUI
import CoreMedia

/// View model responsible for managing Lottie animation playback state and rendering.
///
/// This view model handles the animation loop, frame rendering, playback state,
/// and configuration of Lottie animations, as well as publishing rendering
/// updates and errors to the UI layer.
public class LottieViewModel: ObservableObject {
    
    // MARK: - Types
    
    /// The current playback state of the animation.
    public enum PlaybackState: Equatable {
        /// Animation is currently playing.
        case playing
        
        /// Animation is paused.
        case paused
        
        /// Animation is stopped (at initial frame).
        case stopped
        
        /// Animation has completed playback.
        case completed
    }
    
    /// Errors that can occur during Lottie playback.
    public enum PlaybackError: Error, Equatable {
        /// Failed to render a frame.
        case renderingFailed(String)
        
        /// Failed to create UIImage from buffer.
        case imageCreationFailed
        
        /// Invalid frame index.
        case invalidFrameIndex
        
        /// Failed to create CGContext for rendering.
        case contextCreationFailed
    }
    
    // MARK: - Published Properties
    
    /// The currently rendered frame as a UIImage.
    @Published public private(set) var renderedFrame: UIImage?
    
    /// The current playback state.
    @Published public private(set) var playbackState: PlaybackState = .stopped
    
    /// Any error that occurred during playback.
    @Published public private(set) var error: PlaybackError?
    
    /// The current playback progress (normalized 0.0 to 1.0).
    @Published public private(set) var progress: Double = 0.0
    
    // MARK: - Private Properties
    
    private let lottie: Lottie
    private let totalFrames: Float
    private let size: CGSize
    private let configuration: LottieConfiguration
    private var buffer: [UInt32]
    private let renderer: LottieRenderer
    private var cgContext: CGContext?

    private var timer: AnyCancellable?
    private var elapsedTime: CMTime = .zero
    private var repeatCount: Int = 0
    private var isReversing: Bool = false
    
    // MARK: - Initialization
    
    /// Creates a new Lottie view model.
    ///
    /// - Parameters:
    ///   - lottie: The Lottie animation to play.
    ///   - size: The rendering size for the animation. If `nil`, uses the animation's intrinsic size
    ///           (`lottie.frameSize`). 
    ///   - configuration: Configuration options for playback. Defaults to `.default`.
    ///   - engine: The ThorVG engine to use. Defaults to `.main`.
    public init(
        lottie: Lottie,
        size: CGSize? = nil,
        configuration: LottieConfiguration = .default,
        engine: Engine = .main
    ) {
        self.lottie = lottie
        self.totalFrames = lottie.numberOfFrames
        self.size = size ?? lottie.frameSize
        self.configuration = configuration

        var buffer = [UInt32](repeating: 0, count: Int(self.size.width * self.size.height))
        self.renderer = LottieRenderer(
            lottie,
            engine: engine,
            size: self.size,
            buffer: &buffer,
            stride: Int(self.size.width),
            pixelFormat: configuration.pixelFormat
        )
        self.buffer = buffer
        
        // Render initial frame asynchronously to avoid blocking SwiftUI's observation setup
        DispatchQueue.main.async { [weak self] in
            self?.renderCurrentFrame()
        }
    }
    
    // MARK: - Public Methods
    
    /// Starts or resumes animation playback.
    public func play() {
        guard playbackState != .playing else { return }
        
        playbackState = .playing
        error = nil

        // Timer fires based on frameRate (controls render frequency/smoothness)
        // Time advances based on speed (controls playback speed)
        let renderInterval = 1.0 / configuration.frameRate
        timer = Timer.publish(every: renderInterval, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.renderNextFrame()
            }
    }
    
    /// Pauses animation playback at the current frame.
    public func pause() {
        guard playbackState == .playing else { return }
        
        playbackState = .paused
        
        timer?.cancel()
        timer = nil
    }
    
    /// Stops animation playback and resets to the first frame.
    public func stop() {
        playbackState = .stopped
        
        timer?.cancel()
        timer = nil
        
        elapsedTime = .zero
        repeatCount = 0
        isReversing = false
        renderCurrentFrame()
    }
    
    /// Seeks to a specific progress point in the animation.
    ///
    /// - Parameter progress: A value between 0.0 (start) and 1.0 (end).
    public func seek(to progress: Double) {
        let clampedProgress = max(0.0, min(1.0, progress))
        elapsedTime = CMTime(
            seconds: clampedProgress * lottie.duration.seconds,
            preferredTimescale: 600
        )
        self.progress = clampedProgress
        renderCurrentFrame()
    }
    
    /// Seeks to a specific frame in the animation.
    ///
    /// - Parameter frame: The frame index to seek to.
    public func seek(toFrame frame: Float) {
        guard frame >= 0 && frame <= totalFrames else {
            error = .invalidFrameIndex
            return
        }
        elapsedTime = CMTimeMultiply(lottie.frameDuration, multiplier: Int32(frame))
        progress = Double(frame / totalFrames)
        renderCurrentFrame()
    }
    
    // MARK: - Private Methods
    
    /// Renders the next frame based on playback configuration.
    private func renderNextFrame() {
        if shouldStopPlayback() {
            handlePlaybackCompletion()
            return
        }

        updateFrameForNextIteration()
        renderCurrentFrame()
    }
    
    /// Renders the current frame to the buffer and creates a UIImage to publish.
    private func renderCurrentFrame() {
        let contentRect = calculateContentRect()

        let currentFrame = Float((elapsedTime.seconds / lottie.frameDuration.seconds).rounded(.down))
        
        do {
            try renderer.render(frameIndex: currentFrame, contentRect: contentRect)
        } catch {
            self.error = .renderingFailed(error.localizedDescription)
            return
        }
        
        // Lazy initialize CGContext on first render
        if cgContext == nil {
            guard let context = CGContext.create(
                buffer: &self.buffer,
                size: self.size,
                pixelFormat: configuration.pixelFormat
            ) else {
                self.error = .contextCreationFailed
                return
            }
            self.cgContext = context
        }

        guard let cgImage = cgContext?.makeImage() else {
            self.error = .imageCreationFailed
            return
        }
        
        renderedFrame = UIImage(cgImage: cgImage, scale: 1.0, orientation: .up)
        progress = elapsedTime.seconds / lottie.duration.seconds
    }
    
    /// Calculates the content rect based on the content mode configuration.
    private func calculateContentRect() -> CGRect {
        let animationSize = lottie.frameSize
        
        switch configuration.contentMode {
        case .scaleAspectFit:
            return CGRect(origin: .zero, size: animationSize)
            
        case .scaleAspectFill:
            // Calculate the rect that fills the view while maintaining aspect ratio
            let viewAspect = size.width / size.height
            let animationAspect = animationSize.width / animationSize.height
            
            if animationAspect > viewAspect {
                // Animation is wider - crop sides
                let newWidth = animationSize.height * viewAspect
                let x = (animationSize.width - newWidth) / 2
                return CGRect(x: x, y: 0, width: newWidth, height: animationSize.height)
            } else {
                // Animation is taller - crop top/bottom
                let newHeight = animationSize.width / viewAspect
                let y = (animationSize.height - newHeight) / 2
                return CGRect(x: 0, y: y, width: animationSize.width, height: newHeight)
            }
        }
    }
    
    /// Determines if playback should stop based on loop mode.
    private func shouldStopPlayback() -> Bool {
        switch configuration.loopMode {
        case .playOnce:
            return elapsedTime >= lottie.duration
        case .repeat(let count):
            return repeatCount >= count && elapsedTime >= lottie.duration
        case .autoReverse, .loop:
            return false
        }
    }
    
    /// Updates the elapsed time for the next iteration based on loop mode and speed.
    ///
    /// Each timer tick advances animation time based on render interval * speed
    /// This means: at speed 1.0, 1 second of real time = 1 second of animation time
    ///             at speed 2.0, 1 second of real time = 2 seconds of animation time
    private func updateFrameForNextIteration() {
        let renderInterval = 1.0 / configuration.frameRate
        let timeIncrement = CMTime(
            seconds: renderInterval * configuration.speed,
            preferredTimescale: 600
        )
        
        switch configuration.loopMode {
        case .playOnce:
            elapsedTime = elapsedTime + timeIncrement
            
        case .loop:
            elapsedTime = elapsedTime + timeIncrement
            if elapsedTime >= lottie.duration {
                elapsedTime = .zero
            }
            
        case .repeat(let count):
            elapsedTime = elapsedTime + timeIncrement
            if elapsedTime >= lottie.duration {
                repeatCount += 1
                if repeatCount < count {
                    elapsedTime = .zero
                }
            }
            
        case .autoReverse:
            if isReversing {
                elapsedTime = elapsedTime - timeIncrement
                if elapsedTime <= .zero {
                    elapsedTime = .zero
                    isReversing = false
                }
            } else {
                elapsedTime = elapsedTime + timeIncrement
                if elapsedTime >= lottie.duration {
                    elapsedTime = lottie.duration
                    isReversing = true
                }
            }
        }
    }
    
    /// Handles playback completion.
    private func handlePlaybackCompletion() {
        timer?.cancel()
        timer = nil
        playbackState = .completed
    }
    
    // MARK: - Cleanup
    
    deinit {
        timer?.cancel()
        timer = nil
    }
}

// MARK: - PixelFormat Extension

extension PixelFormat {
    var bitmapInfo: CGBitmapInfo {
        switch self {
        case .argb:
            return [
                .byteOrder32Little,
                CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedFirst.rawValue)
            ]
        case .abgr:
            return [
                .byteOrder32Big,
                CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
            ]
        }
    }
}

// MARK: - CGContext Extension

extension CGContext {
    /// Creates a CGContext for rendering Lottie animations.
    ///
    /// - Parameters:
    ///   - buffer: The buffer to render into.
    ///   - size: The size of the rendering context.
    ///   - pixelFormat: The pixel format for the buffer.
    /// - Returns: A configured CGContext for rendering, or `nil` if creation fails.
    static func create(
        buffer: Buffer,
        size: CGSize,
        pixelFormat: PixelFormat
    ) -> CGContext? {
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
        
        return context
    }
}
