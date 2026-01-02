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

import Foundation

/// Configuration options for Lottie animation playback.
///
/// Use this structure to customize how a Lottie animation plays, including
/// looping behavior, speed, and content rendering options.
///
/// ## Basic Usage
///
/// ```swift
/// let config = LottieConfiguration(
///     loopMode: .repeat(count: 3),
///     speed: 1.5,
///     contentMode: .scaleAspectFit
/// )
/// ```
///
/// ## Understanding Content Modes and Render Size
///
/// The `contentMode` property controls how the animation is **cropped and scaled during rendering**,
/// not just how it's displayed. For optimal results:
///
/// - **Default (no size set)**: Works great for most cases. Renders at native resolution.
/// - **With `.scaleAspectFill`**: Set `size` in `LottieViewModel` to match your view's frame
///   for proper cropping behavior.
/// - **For performance**: Set `size` smaller than display size (e.g., 100×100 for thumbnails).
///
/// See `ContentMode` and `LottieViewModel.init` documentation for details.
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
    ///
    /// **Important**: For proper behavior, especially with `.scaleAspectFill`, set the `size` parameter
    /// in `LottieViewModel` to match your view's display size. The content mode controls how the animation
    /// is cropped/scaled during rendering, not just how the final image is displayed.
    public enum ContentMode {
        /// Scale to fit within the view while maintaining aspect ratio.
        ///
        /// The animation will scale to fit entirely within the rendering size, maintaining its
        /// original aspect ratio. This may result in letterboxing (empty space on sides/top/bottom).
        case scaleAspectFit
        
        /// Scale to fill the view while maintaining aspect ratio (may crop).
        ///
        /// The animation will scale to completely fill the rendering size while maintaining its
        /// aspect ratio. Parts of the animation may be cropped if the aspect ratios don't match.
        ///
        /// **Note**: For this mode to work correctly, you **must** set the `size` parameter in
        /// `LottieViewModel` to match your view's display frame. Otherwise, cropping won't occur
        /// as expected.
        ///
        /// Example:
        /// ```swift
        /// let config = LottieConfiguration(contentMode: .scaleAspectFill)
        /// let viewModel = LottieViewModel(
        ///     lottie: myLottie,
        ///     size: CGSize(width: 200, height: 300),  // Match your view's frame
        ///     configuration: config
        /// )
        /// ```
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

