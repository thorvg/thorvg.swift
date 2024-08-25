/// Errors that can occur while rendering Lottie content.
public enum LottieRenderingError: Error {
    case frameIndexOutOfRange
    case failedToDrawFrame
    case failedToLoadFromDataString
    case failedToLoadFromPath
}
