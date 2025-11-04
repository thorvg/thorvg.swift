import UIKit
import Combine

/// A UIKit view for displaying and animating Lottie files.
///
/// `LottieUIKitView` provides a UIKit interface for rendering Lottie animations
/// with support for various playback modes, speed controls, and content scaling options.
///
/// Basic usage:
/// ```swift
/// guard let lottie = try? Lottie(path: "animation.json") else { return }
/// let lottieView = LottieUIKitView(lottie: lottie)
/// view.addSubview(lottieView)
/// ```
///
/// Advanced usage with configuration:
/// ```swift
/// let config = LottieConfiguration(
///     loopMode: .loop,
///     speed: 1.0,
///     contentMode: .scaleAspectFit
/// )
/// let lottieView = LottieUIKitView(
///     lottie: myLottie,
///     size: CGSize(width: 300, height: 300),
///     configuration: config
/// )
/// lottieView.onPlaybackStateChanged = { state in
///     print("Playback state: \(state)")
/// }
/// ```
public class LottieUIKitView: UIView {
    
    // MARK: - Types
    
    /// Callback invoked when playback state changes.
    public var onPlaybackStateChanged: ((LottieViewModel.PlaybackState) -> Void)?
    
    /// Callback invoked when an error occurs.
    public var onError: ((LottieViewModel.PlaybackError) -> Void)?

    /// Callback invoked when animation progress changes.
    public var onProgressChanged: ((Double) -> Void)?
    
    // MARK: - Properties
    
    /// The current playback state of the animation.
    public var playbackState: LottieViewModel.PlaybackState {
        viewModel.playbackState
    }
    
    /// The current animation progress (0.0 to 1.0).
    public var progress: Double {
        viewModel.progress
    }
    
    /// Any error that occurred during playback.
    public var error: LottieViewModel.PlaybackError? {
        viewModel.error
    }
    
    // MARK: - Private Properties
    
    private let imageView: UIImageView
    private var viewModel: LottieViewModel
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    /// Creates a new Lottie UIKit view.
    ///
    /// - Parameters:
    ///   - lottie: The Lottie animation to display.
    ///   - size: The rendering size for the animation. If `nil`, uses the animation's intrinsic size.
    ///   - configuration: Configuration options for playback. Defaults to `.default`.
    ///   - engine: The ThorVG engine to use. Defaults to `.main`.
    public init(
        lottie: Lottie,
        size: CGSize? = nil,
        configuration: LottieConfiguration = .default,
        engine: Engine = .main
    ) {
        self.viewModel = LottieViewModel(
            lottie: lottie,
            size: size ?? lottie.frameSize,
            configuration: configuration,
            engine: engine
        )
        self.imageView = UIImageView()
        
        super.init(frame: .zero)
        
        setupView()
        setupBindings()
        
        // Auto-play if configured
        if configuration.autoPlay {
            play()
        }
    }
    
    /// Creates a new Lottie UIKit view with frame-based initialization.
    ///
    /// - Parameters:
    ///   - frame: The frame for the view.
    ///   - lottie: The Lottie animation to display.
    ///   - configuration: Configuration options for playback. Defaults to `.default`.
    ///   - engine: The ThorVG engine to use. Defaults to `.main`.
    public convenience init(
        frame: CGRect,
        lottie: Lottie,
        configuration: LottieConfiguration = .default,
        engine: Engine = .main
    ) {
        self.init(
            lottie: lottie,
            size: frame.size,
            configuration: configuration,
            engine: engine
        )
        self.frame = frame
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented. Use init(lottie:size:configuration:) instead.")
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
    
    // MARK: - Public Methods
    
    /// Starts or resumes animation playback.
    public func play() {
        viewModel.play()
    }
    
    /// Pauses animation playback at the current frame.
    public func pause() {
        viewModel.pause()
    }
    
    /// Stops animation playback and resets to the first frame.
    public func stop() {
        viewModel.stop()
    }
    
    /// Seeks to a specific progress point in the animation.
    ///
    /// - Parameter progress: A value between 0.0 (start) and 1.0 (end).
    public func seek(to progress: Double) {
        viewModel.seek(to: progress)
    }
    
    /// Seeks to a specific frame in the animation.
    ///
    /// - Parameter frame: The frame index to seek to.
    public func seek(toFrame frame: Float) {
        viewModel.seek(toFrame: frame)
    }
}

// MARK: - SwiftUI Preview Support

#if DEBUG
import SwiftUI

@available(iOS 13.0, *)
private struct LottieUIKitViewPreview: UIViewRepresentable {
    let lottie: Lottie
    let configuration: LottieConfiguration
    
    func makeUIView(context: Context) -> LottieUIKitView {
        let view = LottieUIKitView(
            lottie: lottie,
            configuration: configuration
        )
        
        // Setup callbacks for debugging
        view.onPlaybackStateChanged = { state in
            print("UIKit View - Playback State: \(state)")
        }
        
        view.onProgressChanged = { progress in
            print("UIKit View - Progress: \(Int(progress * 100))%")
        }
        
        view.onError = { error in
            print("UIKit View - Error: \(error)")
        }
        
        return view
    }
    
    func updateUIView(_ uiView: LottieUIKitView, context: Context) {
        // No updates needed for preview
    }
}

@available(iOS 13.0, *)
#Preview("UIKit View - Loop") {
    if let path = Bundle.module.path(forResource: "test", ofType: "json"),
       let lottie = try? Lottie(path: path) {
        
        let configuration = LottieConfiguration(
            loopMode: .loop,
            speed: 1.0,
            contentMode: .scaleAspectFit,
            frameRate: 30.0,
            pixelFormat: .argb,
            autoPlay: true
        )
        
        LottieUIKitViewPreview(lottie: lottie, configuration: configuration)
            .frame(width: 300, height: 300)
            .background(Color.gray.opacity(0.2))
    } else {
        Text("Failed to load Lottie file")
    }
}

@available(iOS 13.0, *)
#Preview("UIKit View - Play Once") {
    if let path = Bundle.module.path(forResource: "test", ofType: "json"),
       let lottie = try? Lottie(path: path) {
        
        let configuration = LottieConfiguration(
            loopMode: .playOnce,
            speed: 1.0,
            contentMode: .scaleAspectFit,
            frameRate: 30.0,
            autoPlay: true
        )
        
        LottieUIKitViewPreview(lottie: lottie, configuration: configuration)
            .frame(width: 300, height: 300)
            .background(Color.blue.opacity(0.1))
    } else {
        Text("Failed to load Lottie file")
    }
}

@available(iOS 13.0, *)
#Preview("UIKit View - Fast Speed") {
    if let path = Bundle.module.path(forResource: "test", ofType: "json"),
       let lottie = try? Lottie(path: path) {
        
        let configuration = LottieConfiguration(
            loopMode: .loop,
            speed: 2.0,
            contentMode: .scaleAspectFit,
            frameRate: 30.0,
            autoPlay: true
        )
        
        LottieUIKitViewPreview(lottie: lottie, configuration: configuration)
            .frame(width: 300, height: 300)
            .background(Color.green.opacity(0.1))
    } else {
        Text("Failed to load Lottie file")
    }
}

@available(iOS 13.0, *)
#Preview("UIKit View - No AutoPlay") {
    if let path = Bundle.module.path(forResource: "test", ofType: "json"),
       let lottie = try? Lottie(path: path) {
        
        let configuration = LottieConfiguration(
            loopMode: .loop,
            speed: 1.0,
            autoPlay: false
        )
        
        InteractiveUIKitPreview(lottie: lottie, configuration: configuration)
    } else {
        Text("Failed to load Lottie file")
    }
}

@available(iOS 13.0, *)
private struct InteractiveUIKitPreview: View {
    let lottie: Lottie
    let configuration: LottieConfiguration
    @State private var lottieView: LottieUIKitView?
    
    var body: some View {
        VStack(spacing: 20) {
            Text("AutoPlay Disabled - Manual Controls")
                .font(.caption)
                .foregroundColor(.secondary)
            
            LottieUIKitViewPreviewWithRef(
                lottie: lottie,
                configuration: configuration,
                viewRef: $lottieView
            )
            .frame(width: 300, height: 300)
            .background(Color.orange.opacity(0.1))
            
            HStack(spacing: 15) {
                Button("Play") {
                    lottieView?.play()
                }
                .buttonStyle(.plain)

                Button("Pause") {
                    lottieView?.pause()
                }
                .buttonStyle(.plain)

                Button("Stop") {
                    lottieView?.stop()
                }
                .buttonStyle(.plain)
            }
        }
        .padding()
    }
}

@available(iOS 13.0, *)
private struct LottieUIKitViewPreviewWithRef: UIViewRepresentable {
    let lottie: Lottie
    let configuration: LottieConfiguration
    @Binding var viewRef: LottieUIKitView?
    
    func makeUIView(context: Context) -> LottieUIKitView {
        let view = LottieUIKitView(
            lottie: lottie,
            configuration: configuration
        )
        
        DispatchQueue.main.async {
            viewRef = view
        }
        
        return view
    }
    
    func updateUIView(_ uiView: LottieUIKitView, context: Context) {
        // No updates needed
    }
}
#endif
