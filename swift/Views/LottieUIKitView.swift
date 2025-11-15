#if canImport(UIKit)
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
            .sink { [weak self] cgImage in
                self?.imageView.image = self?.createUIImage(from: cgImage)
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
    
    // MARK: - Helper Methods
    
    /// Creates a UIImage from a CGImage with proper scale and orientation.
    private func createUIImage(from cgImage: CGImage?) -> UIImage? {
        guard let cgImage = cgImage else { return nil }
        
        return UIImage(
            cgImage: cgImage,
            scale: UIScreen.main.scale,
            orientation: .up
        )
    }
}
#endif
