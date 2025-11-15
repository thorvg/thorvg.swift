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
