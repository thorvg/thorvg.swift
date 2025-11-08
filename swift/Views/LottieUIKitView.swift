import UIKit
import Combine

/// A UIKit view for displaying and animating Lottie files.
///
/// `LottieUIKitView` provides a UIKit interface for rendering Lottie animations
/// with support for various playback modes, speed controls, and content scaling options.
/// **All animation state is managed through the `LottieViewModel`**, which you create and
/// control externally.
///
/// ## Basic Usage
///
/// ```swift
/// let viewModel = LottieViewModel(
///     lottie: myLottie,
///     configuration: .default
/// )
/// let lottieView = LottieUIKitView(viewModel: viewModel)
/// view.addSubview(lottieView)
/// viewModel.play()
/// ```
///
/// ## Observing Animation State
///
/// **The ViewModel publishes all animation state** via Combine publishers. You can observe
/// these changes either through the view's callback properties or by subscribing directly
/// to the ViewModel's publishers:
///
/// ```swift
/// let config = LottieConfiguration(loopMode: .loop, speed: 1.0)
/// let viewModel = LottieViewModel(
///     lottie: myLottie,
///     configuration: config
/// )
/// let lottieView = LottieUIKitView(viewModel: viewModel)
///
/// // Option 1: Use the view's callbacks
/// lottieView.onPlaybackStateChanged = { state in
///     print("Playback state: \(state)")
/// }
/// lottieView.onProgressChanged = { progress in
///     print("Progress: \(Int(progress * 100))%")
/// }
/// lottieView.onError = { error in
///     // Handle animation errors
///     print("Error: \(error)")
/// }
///
/// // Option 2: Subscribe to ViewModel publishers directly
/// viewModel.$playbackState
///     .sink { state in
///         print("State: \(state)")
///     }
///     .store(in: &cancellables)
///
/// viewModel.play()
/// ```
///
/// ## Content Modes and Render Size
///
/// For proper content mode behavior (especially `.scaleAspectFill`), set the `size` parameter
/// in `LottieViewModel` to match your view's display frame:
///
/// ```swift
/// let config = LottieConfiguration(contentMode: .scaleAspectFill)
/// let viewModel = LottieViewModel(
///     lottie: myLottie,
///     size: CGSize(width: 200, height: 300),  // Match your view's frame
///     configuration: config
/// )
/// let lottieView = LottieUIKitView(viewModel: viewModel)
/// lottieView.frame = CGRect(x: 0, y: 0, width: 200, height: 300)
/// ```
///
/// See `LottieViewModel` and `LottieConfiguration.ContentMode` for more details.
public class LottieUIKitView: UIView {
    
    // MARK: - Types
    
    /// Callback invoked when playback state changes.
    public var onPlaybackStateChanged: ((LottieViewModel.PlaybackState) -> Void)?
    
    /// Callback invoked when an error occurs.
    public var onError: ((LottieViewModel.PlaybackError) -> Void)?

    /// Callback invoked when animation progress changes.
    public var onProgressChanged: ((Double) -> Void)?
    
    // MARK: - Properties
    
    /// The view model managing the animation state and rendering.
    /// Use this to control playback (play, pause, stop, seek) and observe state changes.
    public let viewModel: LottieViewModel
    
    // MARK: - Private Properties
    
    private let imageView: UIImageView
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    /// Creates a new Lottie UIKit view with an external ViewModel.
    ///
    /// - Parameter viewModel: The view model managing the animation state and rendering.
    public init(viewModel: LottieViewModel) {
        self.viewModel = viewModel
        self.imageView = UIImageView()
        
        super.init(frame: .zero)
        
        setupView()
        setupBindings()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented. Use init(viewModel:) instead.")
    }
    
    // MARK: - Setup
    
    private func setupView() {
        imageView.contentMode = .scaleAspectFit
        addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
    
    private func setupBindings() {
        // Bind rendered frame to image view
        viewModel.$renderedFrame
            .receive(on: DispatchQueue.main)
            .sink { [weak self] image in
                self?.imageView.image = image
            }
            .store(in: &cancellables)
        
        // Bind playback state changes
        viewModel.$playbackState
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.onPlaybackStateChanged?(state)
            }
            .store(in: &cancellables)
        
        // Bind error changes
        viewModel.$error
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                if let error = error {
                    self?.onError?(error)
                }
            }
            .store(in: &cancellables)
        
        // Bind progress changes
        viewModel.$progress
            .receive(on: DispatchQueue.main)
            .sink { [weak self] progress in
                self?.onProgressChanged?(progress)
            }
            .store(in: &cancellables)
    }
}

// MARK: - SwiftUI Preview Support

#if DEBUG
import SwiftUI

#Preview("UIKit - Loop") {
    LottieUIKitPreview(loopMode: .loop)
}

#Preview("UIKit - Once") {
    LottieUIKitPreview(loopMode: .playOnce)
}

#Preview("UIKit - 2x Speed") {
    LottieUIKitPreview(speed: 2.0)
}

#Preview("UIKit - 0.5x Speed") {
    LottieUIKitPreview(speed: 0.5)
}

#Preview("UIKit - 60fps") {
    LottieUIKitPreview(frameRate: 60.0)
}

#Preview("UIKit - Manual Controls") {
    if #available(iOS 14.0, *) {
        LottieUIKitPreviewWithControls()
    }
}

#Preview("UIKit - Slider Seeking") {
    if #available(iOS 14.0, *) {
        LottieUIKitPreviewWithSlider()
    }
}

#Preview("UIKit - Content Modes") {
    if #available(iOS 14.0, *) {
        LottieUIKitPreviewContentModes()
    }
}

// MARK: - Preview Helpers

private struct LottieUIKitPreview: UIViewRepresentable {
    let viewModel: LottieViewModel
    
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
        viewModel = LottieViewModel(
            lottie: lottie,
            configuration: config
        )
    }
    
    func makeUIView(context: Context) -> LottieUIKitView {
        let view = LottieUIKitView(viewModel: viewModel)
        viewModel.play()
        return view
    }
    
    func updateUIView(_ uiView: LottieUIKitView, context: Context) {}
}

@available(iOS 14.0, *)
private struct LottieUIKitPreviewWithControls: View {
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
            UIKitViewWrapper(viewModel: viewModel)
            
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

private struct UIKitViewWrapper: UIViewRepresentable {
    let viewModel: LottieViewModel
    
    func makeUIView(context: Context) -> LottieUIKitView {
        LottieUIKitView(viewModel: viewModel)
    }
    
    func updateUIView(_ uiView: LottieUIKitView, context: Context) {}
}

@available(iOS 14.0, *)
private struct LottieUIKitPreviewWithSlider: View {
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
            UIKitViewWrapper(viewModel: viewModel)
                .frame(width: 300, height: 300)
            
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
private struct LottieUIKitPreviewContentModes: View {
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
        ScrollView {
            VStack(spacing: 32) {
                VStack(spacing: 8) {
                    Text("Scale Aspect Fill")
                        .font(.headline)
                    Text("Wide frame - crops top/bottom")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    UIKitViewWrapper(viewModel: fillViewModel)
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
                    UIKitViewWrapper(viewModel: fitViewModel)
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
