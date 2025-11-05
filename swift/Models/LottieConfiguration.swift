import Foundation

/// Configuration options for Lottie animation playback.
///
/// Use this structure to customize how a Lottie animation plays, including
/// looping behavior, speed, and content rendering options.
///
/// Example:
/// ```swift
/// let config = LottieConfiguration(
///     loopMode: .repeat(count: 3),
///     speed: 1.5,
///     contentMode: .scaleAspectFit
/// )
/// ```
public struct LottieConfiguration {
    
    /// Defines how the animation should loop.
    public enum LoopMode: Equatable {
        /// Play the animation once and stop.
        case playOnce
        
        /// Loop the animation indefinitely.
        case loop
        
        /// Repeat the animation a specific number of times.
        case `repeat`(count: Int)
        
        /// Auto-reverse: play forward, then backward, continuously.
        case autoReverse
    }
    
    /// Defines how content should be displayed within the view bounds.
    public enum ContentMode {
        /// Scale to fill the view, potentially distorting the aspect ratio.
        case scaleToFill
        
        /// Scale to fit within the view while maintaining aspect ratio.
        case scaleAspectFit
        
        /// Scale to fill the view while maintaining aspect ratio (may crop).
        case scaleAspectFill
    }
    
    /// The loop mode for the animation. Defaults to `.loop`.
    public let loopMode: LoopMode
    
    /// The playback speed multiplier. A value of 1.0 is normal speed,
    /// 2.0 is double speed, 0.5 is half speed. Defaults to 1.0.
    public let speed: Double
    
    /// The content mode determining how the animation fits within the view.
    /// Defaults to `.scaleAspectFit`.
    public let contentMode: ContentMode
    
    /// The frame rate at which to render the animation. Defaults to 30 fps.
    public let frameRate: Double
    
    /// The pixel format to use for rendering. Defaults to `.argb`.
    public let pixelFormat: PixelFormat
    
    /// Creates a new Lottie configuration.
    ///
    /// - Parameters:
    ///   - loopMode: The loop mode for playback. Defaults to `.loop`.
    ///   - speed: The playback speed multiplier. Defaults to 1.0.
    ///   - contentMode: How content should fit within the view. Defaults to `.scaleAspectFit`.
    ///   - frameRate: The rendering frame rate in fps. Defaults to 30.
    ///   - pixelFormat: The pixel format for rendering. Defaults to `.argb`.
    public init(
        loopMode: LoopMode = .loop,
        speed: Double = 1.0,
        contentMode: ContentMode = .scaleAspectFit,
        frameRate: Double = 30.0,
        pixelFormat: PixelFormat = .argb
    ) {
        self.loopMode = loopMode
        self.speed = speed
        self.contentMode = contentMode
        self.frameRate = frameRate
        self.pixelFormat = pixelFormat
    }
    
    /// A default configuration with standard settings.
    public static let `default` = LottieConfiguration()
}

