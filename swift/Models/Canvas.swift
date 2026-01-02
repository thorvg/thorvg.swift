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

/// A Swift wrapper for ThorVG's Canvas, facilitating drawing operations.
class Canvas {
    /// Pointer to the underlying ThorVG canvas object.
    let pointer: OpaquePointer

    /// The size of the canvas.
    let size: CGSize

    /// Initializes a canvas with a specific size, buffer, stride and pixel format for drawing.
    init(size: CGSize, buffer: Buffer, stride: Int, pixelFormat: PixelFormat) {
        self.pointer = tvg_swcanvas_create(TVG_ENGINE_OPTION_DEFAULT)
        self.size = size

        tvg_swcanvas_set_target(pointer, buffer, UInt32(stride), UInt32(size.width), UInt32(size.height), pixelFormat.colorspace)
    }

    /// Pushes a picture onto the the canvas.
    func push(picture: Picture) {
        tvg_canvas_push(pointer, picture.pointer)
    }

    /// Updates the canvas.
    func update() {
        tvg_canvas_update(pointer)
    }

    /// Draws the contents of the canvas into the buffer.
    func draw() throws {
        guard tvg_canvas_draw(pointer, true) == TVG_RESULT_SUCCESS else {
            throw LottieRenderingError.failedToDrawFrame
        }

        tvg_canvas_sync(pointer)
    }

    deinit {
        tvg_canvas_destroy(pointer)
    }
}
