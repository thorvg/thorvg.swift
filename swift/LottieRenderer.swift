import CoreGraphics

import ThorVG

/// Shorthand alias for the buffer type, representing image pixel data in a mutable pointer to UInt32.
public typealias Buffer = UnsafeMutablePointer<UInt32>

/// Object responsible for rendering a Lottie animation using ThorVG.
public class LottieRenderer {
    private let lottie: Lottie
    private let engine: Engine
    private let canvas: Canvas

    /// Initializes the LottieRenderer with a specific Lottie object, engine, size, buffer, and stride.
    /// - Parameters:
    ///   - lottie: The `Lottie` object containing the animation to render.
    ///   - engine: An optional `Engine` object to use. If not provided, the default engine configuration is used.
    ///   - size: The size of the rendering canvas. This size determines the final size of the rendered Lottie content.
    ///   - buffer: A buffer to hold the rendered pixel data.
    ///   - stride: The number of bytes in a row of the buffer.
    ///   - pixelFormat: The pixel format defining the format of the color components for each pixel value.
    public init(
        _ lottie: Lottie,
        engine: Engine = .main,
        size: CGSize,
        buffer: Buffer,
        stride: Int,
        pixelFormat: PixelFormat
    ) {
        self.lottie = lottie
        self.engine = engine
        self.canvas = Canvas(size: size, buffer: buffer, stride: stride, pixelFormat: pixelFormat)

        let picture = lottie.animation.getPicture()
        picture.resize(canvas.size)
        canvas.push(picture: picture)
    }

    /// Renders a specific frame of the Lottie animation using a specified area of the content, applying optional rotation.
    /// - Parameters:
    ///   - frameIndex: Index of the frame in the animation.
    ///   - contentRect: Specifies the area of the content to be rendered. This rectangle defines the portion of the animation that should be visible in the final rendered frame, scaled to fit the canvas size.
    ///   - rotation: Rotation angle in degrees to apply to the renderered frame.
    public func render(
        frameIndex: Float,
        contentRect: CGRect,
        rotation: Double = 0.0
    ) throws {
        guard frameIndex <= lottie.numberOfFrames, frameIndex >= 0 else {
            throw LottieRenderingError.frameIndexOutOfRange
        }

        lottie.animation.setFrame(frameIndex)

        let picture = lottie.animation.getPicture()
        let size = picture.getSize()

        // Create the transform for the Picture by multiplying three transform matrices.
        // 1. Translate the Picture to the content rect origin.
        // 2. Scale the Picture based on the Picture's size versus the content rect size.
        // 3. Rotate the Picture about its center.
        let transform =
            CGAffineTransform(
                translationX: -contentRect.minX,
                y: -contentRect.minY
            )
            .concatenating(
                CGAffineTransform(
                    scaleX: size.width / contentRect.width,
                    y: size.height / contentRect.height
                )
            )
            .concatenating(
                CGAffineTransform(
                    rotationAngle: rotation * .pi / 180.0
                )
                .appliedAround(pivot:
                    CGPoint(
                        x: size.width / 2,
                        y: size.height / 2
                    )
                )
            )
        
        picture.setTransform(transform)

        canvas.update()
        try canvas.draw()
    }
}

extension CGAffineTransform {
    /// Applies the transformation around a specified pivot point.
    func appliedAround(pivot: CGPoint) -> CGAffineTransform {
        CGAffineTransform(translationX: -pivot.x, y: -pivot.y)
            .concatenating(self)
            .concatenating(CGAffineTransform(translationX: pivot.x, y: pivot.y))
    }
}

