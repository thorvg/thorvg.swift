import SwiftUI

/// A SwiftUI view for displaying and animating Lottie files.
///
/// `LottieView` provides a declarative interface for rendering Lottie animations in SwiftUI.
/// It supports various playback modes, speed controls, and content scaling options.
///
/// Basic usage:
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
/// Advanced usage with manual controls:
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
///     Text("Progress: \(viewModel.progress)")
/// }
/// .onChange(of: viewModel.playbackState) { _, state in
///     print("State changed: \(state)")
/// }
/// ```
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
                viewModel.pause()
            }
    }
    
    // MARK: - Content
    
    @ViewBuilder
    private func content() -> some View {
        if let image = viewModel.renderedFrame {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
        } else {
            Color.clear
        }
    }
}

// MARK: - Previews

#if DEBUG
@available(iOS 14.0, *)
#Preview("SwiftUI - Loop") {
    LottiePreview(loopMode: .loop)
}

@available(iOS 14.0, *)
#Preview("SwiftUI - Once") {
    LottiePreview(loopMode: .playOnce)
}

@available(iOS 14.0, *)
#Preview("SwiftUI - 2x Speed") {
    LottiePreview(speed: 2.0)
}

@available(iOS 14.0, *)
#Preview("SwiftUI - 0.5x Speed") {
    LottiePreview(speed: 0.5)
}

@available(iOS 14.0, *)
#Preview("SwiftUI - 60fps") {
    LottiePreview(frameRate: 60.0)
}

@available(iOS 14.0, *)
#Preview("SwiftUI - Manual Controls") {
    LottiePreviewWithControls()
}

// MARK: - Preview Helpers

@available(iOS 14.0, *)
private struct LottiePreview: View {
    @StateObject private var viewModel: LottieViewModel
    
    init(
        loopMode: LottieConfiguration.LoopMode = .loop,
        speed: Double = 1.0,
        frameRate: Double = 30.0
    ) {
        guard let path = Bundle.module.path(forResource: "test", ofType: "json"),
              let lottie = try? Lottie(path: path) else {
            fatalError("Failed to load test Lottie")
        }
        
        let config = LottieConfiguration(loopMode: loopMode, speed: speed, frameRate: frameRate)
        _viewModel = StateObject(wrappedValue: LottieViewModel(
            lottie: lottie,
            configuration: config
        ))
    }
    
    var body: some View {
        LottieView(viewModel: viewModel)
            .onAppear { viewModel.play() }
    }
}

@available(iOS 14.0, *)
private struct LottiePreviewWithControls: View {
    @StateObject private var viewModel: LottieViewModel
    
    init() {
        guard let path = Bundle.module.path(forResource: "test", ofType: "json"),
              let lottie = try? Lottie(path: path) else {
            fatalError("Failed to load test Lottie")
        }
        
        _viewModel = StateObject(wrappedValue: LottieViewModel(
            lottie: lottie,
            configuration: .default
        ))
    }
    
    var body: some View {
        VStack(spacing: 16) {
            LottieView(viewModel: viewModel)
            
            HStack(spacing: 12) {
                Button("Play") { viewModel.play() }
                Button("Pause") { viewModel.pause() }
                Button("Stop") { viewModel.stop() }
            }
            .buttonStyle(.automatic)

            Text("Progress: \(Int(viewModel.progress * 100))%")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
    }
}
#endif
