import CoreGraphics

import thorvg

/// A Swift wrapper for managing ThorVG's engine initialization and termination.
public class Engine {
    /// A default instance of `Engine`, running on the main thread.
    public static let main = Engine()

    /// Initializes the engine with a specified number of threads.
    ///
    /// Note: This defaults the number of threads to 0, which tells ThorVG to run on the main thread.
    public init(numberOfThreads: Int = 0) {
        tvg_engine_init(TVG_ENGINE_SW, UInt32(numberOfThreads))
    }
}
