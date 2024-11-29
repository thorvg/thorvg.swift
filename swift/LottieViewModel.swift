import Combine
import SwiftUI

/// TODO: ....
class LottieViewModel: ObservableObject {
    private let totalFrames: Float
    private let size: CGSize
    private var buffer: [UInt32]
    private let renderer: LottieRenderer

    private var timer: AnyCancellable?
    
    private var currentFrame: Float = 0
    private let frameRate: Double = 30.0

    @Published var renderedFrame: UIImage? = nil

    // TODO: Handle different engine types.
    init(lottie: Lottie, size: CGSize) {
        var buffer = [UInt32](repeating: 0, count: Int(size.width * size.height))
        self.renderer = LottieRenderer(
            lottie,
            engine: .main,
            size: size,
            buffer: &buffer,
            stride: Int(size.width),
            pixelFormat: .argb
        )
        self.buffer = buffer
        self.totalFrames = lottie.numberOfFrames
        self.size = size
    }

    func startAnimating() {
        let frameDuration = 1.0 / frameRate
        timer = Timer.publish(every: frameDuration, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.renderNextFrame()
            }
    }

    func stopAnimating() {
        timer?.cancel()
        timer = nil
    }

    // TODO: Handle errors propery here.
    private func renderNextFrame() {
        guard currentFrame < totalFrames else {
            currentFrame = 0
            return
        }

        let contentRect = CGRect(x: 0, y: 0, width: size.width, height: size.height)

        do {
            try renderer.render(frameIndex: Float(currentFrame), contentRect: contentRect)
        } catch {
            print(error)
            fatalError("Rendering error.")
        }



        if let image = UIImage(buffer: &buffer, size: size, pixelFormat: .argb) {
            renderedFrame = image
            currentFrame += 1
        } else {
            print("UI IMAGE CAST ERROR")
            fatalError("UIImage cast error.")
        }
    }
}

extension UIImage {
    convenience init?(buffer: Buffer, size: CGSize, pixelFormat: PixelFormat) {
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = pixelFormat.bitmapInfo.rawValue
        let bitsPerComponent = 8
        let bytesPerRow = Int(size.width) * 4

        guard let context = CGContext(
            data: buffer,
            width: Int(size.width),
            height: Int(size.height),
            bitsPerComponent: bitsPerComponent,
            bytesPerRow: bytesPerRow,
            space: colorSpace,
            bitmapInfo: bitmapInfo
        ) else {
            return nil
        }

        guard let cgImage = context.makeImage() else {
            return nil
        }

        self.init(cgImage: cgImage, scale: 1.0, orientation: .up)
    }
}

extension PixelFormat {
    var bitmapInfo: CGBitmapInfo {
        switch self {
        case .argb:
            return [.byteOrder32Little, CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedFirst.rawValue)]
        case .abgr:
            return [.byteOrder32Big, CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)]
        }
    }
}

