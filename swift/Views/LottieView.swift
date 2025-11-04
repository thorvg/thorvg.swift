import SwiftUI

/// A SwiftUI view for displaying and animating Lottie files.
///
/// `LottieView` provides a declarative interface for rendering Lottie animations in SwiftUI.
/// It supports various playback modes, speed controls, and content scaling options.
///
/// Basic usage:
/// ```swift
/// guard let lottie = try? Lottie(path: "animation.json") else { return }
/// LottieView(lottie: lottie)
/// ```
///
/// Advanced usage with configuration:
/// ```swift
/// let config = LottieConfiguration(
///     loopMode: .loop,
///     speed: 1.0,
///     contentMode: .scaleAspectFit
/// )
/// LottieView(
///     lottie: myLottie,
///     size: CGSize(width: 300, height: 300),
///     configuration: config
/// )
/// ```
@available(iOS 14.0, *)
public struct LottieView: View {
    
    // MARK: - Properties
    
    @StateObject private var viewModel: LottieViewModel
    private let shouldAutoPlay: Bool
    
    // MARK: - Initialization
    
    /// Creates a new Lottie view.
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
        self.shouldAutoPlay = configuration.autoPlay
        _viewModel = StateObject(wrappedValue: LottieViewModel(
            lottie: lottie,
            size: size ?? lottie.frameSize,
            configuration: configuration,
            engine: engine
        ))
    }
    
    // MARK: - Body
    
    public var body: some View {
        content()
        .onAppear {
            if shouldAutoPlay {
                viewModel.play()
            }
        }
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

// MARK: - Access to ViewModel
//
// Note: To observe playback state, errors, or progress, access the viewModel's
// published properties directly using standard SwiftUI modifiers like .onChange()
// However, the viewModel is private, so for now users should use the UIKit view
// if they need callbacks, or we can add a way to expose the viewModel.
//
// TODO: Do I need to make these available? See if I can use proper ViewModifiers

// MARK: - Previews

#if DEBUG
@available(iOS 14.0, *)
#Preview("SwiftUI View - Loop") {
    if let path = Bundle.module.path(forResource: "test", ofType: "json"),
       let lottie = try? Lottie(path: path) {
        
        let configuration = LottieConfiguration(
            loopMode: .loop,
            speed: 1.0,
            contentMode: .scaleAspectFit,
            frameRate: 30.0,
            autoPlay: true
        )
        
        LottieView(lottie: lottie, configuration: configuration)
            .frame(width: 300, height: 300)
            .background(Color.gray.opacity(0.2))
    } else {
        Text("Failed to load Lottie file")
    }
}

@available(iOS 14.0, *)
#Preview("SwiftUI View - Play Once") {
    if let path = Bundle.module.path(forResource: "test", ofType: "json"),
       let lottie = try? Lottie(path: path) {
        
        let configuration = LottieConfiguration(
            loopMode: .playOnce,
            speed: 1.0,
            contentMode: .scaleAspectFit,
            frameRate: 30.0,
            autoPlay: true
        )
        
        LottieView(lottie: lottie, configuration: configuration)
            .frame(width: 300, height: 300)
            .background(Color.blue.opacity(0.1))
    } else {
        Text("Failed to load Lottie file")
    }
}

@available(iOS 14.0, *)
#Preview("SwiftUI View - Fast Speed") {
    if let path = Bundle.module.path(forResource: "test", ofType: "json"),
       let lottie = try? Lottie(path: path) {
        
        let configuration = LottieConfiguration(
            loopMode: .loop,
            speed: 2.0,
            contentMode: .scaleAspectFit,
            frameRate: 30.0,
            autoPlay: true
        )
        
        LottieView(lottie: lottie, configuration: configuration)
            .frame(width: 300, height: 300)
            .background(Color.green.opacity(0.1))
    } else {
        Text("Failed to load Lottie file")
    }
}

@available(iOS 14.0, *)
#Preview("SwiftUI View - No AutoPlay") {
    if let path = Bundle.module.path(forResource: "test", ofType: "json"),
       let lottie = try? Lottie(path: path) {
        
        let configuration = LottieConfiguration(
            loopMode: .loop,
            speed: 1.0,
            autoPlay: false
        )
        
        InteractiveSwiftUIPreview(lottie: lottie, configuration: configuration)
    } else {
        Text("Failed to load Lottie file")
    }
}

@available(iOS 14.0, *)
private struct InteractiveSwiftUIPreview: View {
    let lottie: Lottie
    let configuration: LottieConfiguration
    @StateObject private var viewModel: LottieViewModel
    
    init(lottie: Lottie, configuration: LottieConfiguration) {
        self.lottie = lottie
        self.configuration = configuration
        _viewModel = StateObject(wrappedValue: LottieViewModel(
            lottie: lottie,
            size: lottie.frameSize,
            configuration: configuration
        ))
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Text("AutoPlay Disabled - Manual Controls")
                .font(.caption)
                .foregroundColor(.secondary)
            
            if let image = viewModel.renderedFrame {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 300, height: 300)
                    .background(Color.orange.opacity(0.1))
            } else {
                Color.clear
                    .frame(width: 300, height: 300)
            }
            
            HStack(spacing: 15) {
                Button("Play") {
                    viewModel.play()
                }
                .buttonStyle(.plain)

                Button("Pause") {
                    viewModel.pause()
                }
                .buttonStyle(.plain)

                Button("Stop") {
                    viewModel.stop()
                }
                .buttonStyle(.plain)
            }
            
            Text("State: \(String(describing: viewModel.playbackState))")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding()
    }
}
#endif
