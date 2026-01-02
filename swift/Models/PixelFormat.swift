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

import ThorVG

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
