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

@available(iOS 14.0, *)
#Preview("SwiftUI - Slider Seeking") {
    LottiePreviewWithSlider()
}

@available(iOS 14.0, *)
#Preview("SwiftUI - Content Modes") {
    LottiePreviewContentModes()
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

@available(iOS 14.0, *)
private struct LottiePreviewWithSlider: View {
    @StateObject private var viewModel: LottieViewModel
    @State private var sliderValue: Double = 0.0
    @State private var isDragging: Bool = false
    
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
            
            VStack(spacing: 8) {
                Slider(
                    value: $sliderValue,
                    in: 0...1,
                    onEditingChanged: { editing in
                        if editing {
                            // Pause on touch down
                            isDragging = true
                            viewModel.pause()
                        } else {
                            // Resume on touch up
                            isDragging = false
                        }
                    }
                )
                .onChange(of: sliderValue) { newValue in
                    if isDragging {
                        viewModel.seek(to: newValue)
                    }
                }
                
                HStack {
                    Button(viewModel.playbackState == .playing ? "Pause" : "Play") {
                        if viewModel.playbackState == .playing {
                            viewModel.pause()
                        } else {
                            viewModel.play()
                        }
                    }
                    .buttonStyle(.automatic)
                    
                    Spacer()
                    
                    Text("\(Int(viewModel.progress * 100))%")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal)
        }
        .padding()
        .onChange(of: viewModel.progress) { newProgress in
            if !isDragging {
                sliderValue = newProgress
            }
        }
    }
}

@available(iOS 14.0, *)
private struct LottiePreviewContentModes: View {
    @StateObject private var fillViewModel: LottieViewModel
    @StateObject private var fitViewModel: LottieViewModel
    
    init() {
        guard let path = Bundle.module.path(forResource: "test", ofType: "json"),
              let lottie = try? Lottie(path: path) else {
            fatalError("Failed to load test Lottie")
        }
        
        // Different frame sizes to demonstrate each mode's behavior
        
        // scaleAspectFill: Wide frame - will crop top/bottom if Lottie is square
        let fillConfig = LottieConfiguration(
            loopMode: .loop,
            contentMode: .scaleAspectFill
        )
        _fillViewModel = StateObject(wrappedValue: LottieViewModel(
            lottie: lottie,
            size: CGSize(width: 300, height: 150),  // Wide aspect ratio
            configuration: fillConfig
        ))
        
        // scaleAspectFit: Square frame - renders full animation
        let fitConfig = LottieConfiguration(
            loopMode: .loop,
            contentMode: .scaleAspectFit
        )
        _fitViewModel = StateObject(wrappedValue: LottieViewModel(
            lottie: lottie,
            size: CGSize(width: 250, height: 250),  // Square
            configuration: fitConfig
        ))
    }
    
    var body: some View {
        ScrollView() {
            VStack(spacing: 32) {
                VStack(spacing: 8) {
                    Text("Scale Aspect Fill")
                        .font(.headline)
                    Text("Wide frame - crops top/bottom")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    LottieView(viewModel: fillViewModel)
                        .frame(width: 300, height: 150)
                        .background(Color.blue.opacity(0.1))
                        .border(Color.blue, width: 2)
                        .onAppear { fillViewModel.play() }
                }

                VStack(spacing: 8) {
                    Text("Scale Aspect Fit")
                        .font(.headline)
                    Text("Square frame - shows full animation")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    LottieView(viewModel: fitViewModel)
                        .frame(width: 250, height: 250)
                        .background(Color.green.opacity(0.1))
                        .border(Color.green, width: 2)
                        .onAppear { fitViewModel.play() }
                }
            }
            .padding()
        }
    }
}
#endif
