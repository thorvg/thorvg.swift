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
