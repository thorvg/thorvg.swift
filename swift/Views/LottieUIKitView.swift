import UIKit
import Combine

/// A UIKit view for displaying and animating Lottie files.
///
/// `LottieUIKitView` provides a UIKit interface for rendering Lottie animations
/// with support for various playback modes, speed controls, and content scaling options.
///
/// Basic usage:
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
/// Advanced usage with callbacks:
/// ```swift
/// let config = LottieConfiguration(loopMode: .loop, speed: 1.0)
/// let viewModel = LottieViewModel(
///     lottie: myLottie,
///     configuration: config
/// )
/// let lottieView = LottieUIKitView(viewModel: viewModel)
/// lottieView.onPlaybackStateChanged = { state in
///     print("Playback state: \(state)")
/// }
/// lottieView.onProgressChanged = { progress in
///     print("Progress: \(Int(progress * 100))%")
/// }
/// viewModel.play()
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
#endif
