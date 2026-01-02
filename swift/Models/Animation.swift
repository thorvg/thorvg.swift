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

/// A Swift wrapper for ThorVG animations.
class Animation {
    /// Pointer to the underlying ThorVG animation object.
    let pointer: OpaquePointer

    /// Initializes a new Animation instance with a new ThorVG animation object.
    convenience init() {
        let pointer: OpaquePointer = tvg_animation_new()
        self.init(pointer: pointer)
    }

    /// Initializes a new Animation instance with an existing ThorVG animation pointer.
    init(pointer: OpaquePointer) {
        self.pointer = pointer
    }

    /// Returns the duration of the animation as a `CMTime`.
    func getDuration() -> CMTime {
        var duration: Float = 0
        tvg_animation_get_duration(pointer, &duration)
        return CMTime(seconds: Double(duration), preferredTimescale: 600)
    }

    /// Returns the total number of frames in the animation.
    func getNumberOfFrames() -> Float {
        var numberOfFrames: Float = 0
        tvg_animation_get_total_frame(pointer, &numberOfFrames)
        return numberOfFrames
    }

    /// Sets the current frame of the animation to the specified frame number.
    func setFrame(_ frame: Float) {
        tvg_animation_set_frame(pointer, frame)
    }

    /// Retrieves the current `Picture` instance associated with the animation.
    func getPicture() -> Picture {
        let picturePointer: OpaquePointer = tvg_animation_get_picture(pointer)
        return Picture(pointer: picturePointer)
    }

    deinit {
        tvg_animation_del(pointer)
    }
}
