import thorvg

/// Specifies the methods of combining the 8-bit color components into 32-bit color.
public enum PixelFormat {
    /// The components are joined in the order: alpha, blue, green, red. Colors are alpha-premultiplied. (a << 24 | b << 16 | g << 8 | r)
    case abgr
    /// The components are joined in the order: alpha, red, green, blue. Colors are alpha-premultiplied. (a << 24 | r << 16 | g << 8 | b)
    case argb
}

extension PixelFormat {
    /// Provides the corresponding `Tvg_Colorspace` value for a `PixelFormat` instance.
    var colorspace: Tvg_Colorspace {
        switch self {
        case .abgr:
            return TVG_COLORSPACE_ABGR8888
        case .argb:
            return TVG_COLORSPACE_ARGB8888
        }
    }
}
