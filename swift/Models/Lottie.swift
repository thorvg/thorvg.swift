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

import CoreGraphics
import CoreMedia

import ThorVG

/// Object used to load and render Lottie frames.
public class Lottie {
    /// The number of frames in the Lottie animation.
    public let numberOfFrames: Float

    /// The duration of the Lottie animation.
    public let duration: CMTime

    /// The size of the rendered Lottie frames.
    public var frameSize: CGSize {
        animation.getPicture().getSize()
    }
    
    /// The duration of a single frame in the animation.
    public var frameDuration: CMTime {
        CMTime(
            seconds: duration.seconds / Double(numberOfFrames),
            preferredTimescale: 600
        )
    }

    /// The internal animation object, used for manipulating and rendering frames.
    let animation: Animation

    /// Create a `Lottie` instance from a file path.
    /// - Parameter path: The file path of the Lottie animation to load.
    public convenience init(path: String) throws {
        let animation = Animation()
        let picture = animation.getPicture()
        try picture.load(fromPath: path)
        self.init(animation: animation)
    }

    /// Create a `Lottie` instance from a raw string.
    /// - Parameter string: The raw string containing the Lottie animation data.
    public convenience init(string: String) throws {
        let animation = Animation()
        let picture = animation.getPicture()
        try picture.load(fromString: string, mimeType: .lottie)
        self.init(animation: animation)
    }

    private init(animation: Animation) {
        self.animation = animation
        self.numberOfFrames = animation.getNumberOfFrames()
        self.duration = animation.getDuration()
    }
}
