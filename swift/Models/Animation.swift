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
