/// Errors that can occur while working with ThorVG.
public enum ThorVGError: Error {
    case frameIndexOutOfRange
    case failedToDrawFrame
    case failedToLoadFromDataString
    case failedToLoadFromPath
}
