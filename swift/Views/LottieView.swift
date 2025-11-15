import SwiftUI

/// A SwiftUI view for displaying and animating Lottie files.
///
/// `LottieView` provides a declarative interface for rendering Lottie animations in SwiftUI.
/// **All animation state is managed through the `LottieViewModel`**, which you create and control
/// externally using `@StateObject`.
///
/// ## Basic Usage
///
/// ```swift
/// @StateObject var viewModel = LottieViewModel(
///     lottie: myLottie,
///     configuration: .default
/// )
///
/// LottieView(viewModel: viewModel)
///     .onAppear { viewModel.play() }
/// ```
///
/// ## Observing Animation State
///
/// **The ViewModel publishes all animation state** including playback state, progress, errors,
/// and rendered frames. Observe these properties using SwiftUI's `.onChange` modifier:
///
/// ```swift
/// @StateObject var viewModel = LottieViewModel(
///     lottie: myLottie,
///     configuration: LottieConfiguration(loopMode: .loop, speed: 1.0)
/// )
///
/// VStack {
///     LottieView(viewModel: viewModel)
///
///     HStack {
///         Button("Play") { viewModel.play() }
///         Button("Pause") { viewModel.pause() }
///         Button("Stop") { viewModel.stop() }
///     }
///
///     Text("Progress: \(Int(viewModel.progress * 100))%")
/// }
/// .onChange(of: viewModel.playbackState) { _, state in
///     print("State changed: \(state)")
/// }
/// .onChange(of: viewModel.error) { _, error in
///     if let error = error {
///         // Handle animation errors
///         print("Error: \(error)")
///     }
/// }
/// ```
///
/// ## Content Modes and Render Size
///
/// For proper content mode behavior (especially `.scaleAspectFill`), set the `size` parameter
/// in `LottieViewModel` to match your view's display frame:
///
/// ```swift
/// let config = LottieConfiguration(contentMode: .scaleAspectFill)
/// @StateObject var viewModel = LottieViewModel(
///     lottie: myLottie,
///     size: CGSize(width: 200, height: 300),  // Match your .frame() size
///     configuration: config
/// )
///
/// LottieView(viewModel: viewModel)
///     .frame(width: 200, height: 300)
/// ```
///
/// See `LottieViewModel` and `LottieConfiguration.ContentMode` for more details.
@available(iOS 14.0, *)
public struct LottieView: View {
    
    // MARK: - Properties
    
    @ObservedObject public var viewModel: LottieViewModel
    
    // MARK: - Initialization
    
    /// Creates a new Lottie view with a ViewModel.
    ///
    /// - Parameter viewModel: The view model managing the animation state and rendering.
    ///   Create the ViewModel externally using `@StateObject` to maintain ownership.
    public init(viewModel: LottieViewModel) {
        self._viewModel = ObservedObject(wrappedValue: viewModel)
    }
    
    // MARK: - Body
    
    public var body: some View {
        content()
            .onDisappear {
                viewModel.stop()
            }
    }
    
    // MARK: - Content
    
    @ViewBuilder
    private func content() -> some View {
        if let cgImage = viewModel.renderedFrame {
            createImage(from: cgImage)
                .resizable()
                .scaledToFit()
        } else {
            Color.clear
        }
    }
    
    // MARK: - Helper Methods
    
    /// Creates a SwiftUI Image from a CGImage, handling platform differences.
    private func createImage(from cgImage: CGImage) -> Image {
        #if canImport(UIKit)
        let uiImage = UIImage(
            cgImage: cgImage,
            scale: UIScreen.main.scale,
            orientation: .up
        )
        return Image(uiImage: uiImage)
        #elseif canImport(AppKit)
        let size = NSSize(width: cgImage.width, height: cgImage.height)
        let nsImage = NSImage(cgImage: cgImage, size: size)
        return Image(nsImage: nsImage)
        #endif
    }
}
