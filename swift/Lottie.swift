import CoreGraphics
import CoreMedia

import thorvg

/// Object used to load and render Lottie frames.
public class Lottie {
    /// The number of frames in the Lottie animation.
    public let numberOfFrames: Float

    /// The duration of the Lottie animation.
    public let duration: CMTime

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

    public func getSize() -> CGSize {
        animation.getPicture().getSize()
    }
}
