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

import ThorVG

/// A Swift wrapper for ThorVG's Picture, facilitating picture manipulation.
class Picture {
    /// Supported MIME types for loading picture data.
    enum MimeType: String {
        case lottie = "lottie"
    }

    /// Pointer to the underlying ThorVG picture object.
    let pointer: OpaquePointer

    /// Initializes a new Picture instance with an empty ThorVG picture object.
    convenience init() {
        let pointer: OpaquePointer = tvg_picture_new()
        self.init(pointer: pointer)
    }

    /// Initializes a Picture instance from an existing ThorVG picture pointer.
    init(pointer: OpaquePointer) {
        self.pointer = pointer
    }

    /// Loads a picture from a given file path.
    func load(fromPath path: String) throws {
        guard tvg_picture_load(pointer, path) == TVG_RESULT_SUCCESS else {
            throw LottieRenderingError.failedToLoadFromPath
        }
    }

    /// Loads a picture from a given data string.
    ///
    /// Use the `mimeType` to indicate the data format for correct parsing.
    func load(fromString string: String, mimeType: MimeType) throws {
        guard let cString = string.cString(using: .utf8),
              tvg_picture_load_data(
                pointer,
                cString,
                UInt32(cString.count),
                mimeType.rawValue,
                nil,
                false
              ) == TVG_RESULT_SUCCESS
        else {
            throw LottieRenderingError.failedToLoadFromDataString
        }
    }

    /// Resizes the picture content to the given size.
    func resize(_ size: CGSize) {
        tvg_picture_set_size(pointer, Float(size.width), Float(size.height))
    }

    /// Retrieves the size of the picture.
    func getSize() -> CGSize {
        var width: Float = 0
        var height: Float = 0
        tvg_picture_get_size(pointer, &width, &height)
        return CGSize(width: Double(width), height: Double(height))
    }

    /// Sets the transformation matrix of the picture.
    func setTransform(_ transform: CGAffineTransform) {
        var matrix = Tvg_Matrix(
            e11: Float(transform.a), e12: Float(transform.c), e13: Float(transform.tx),
            e21: Float(transform.b), e22: Float(transform.d), e23: Float(transform.ty),
            e31: 0, e32: 0, e33: 1
        )

        tvg_paint_set_transform(pointer, &matrix)
    }
}
