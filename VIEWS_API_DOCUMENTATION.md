# Lottie Views API Documentation

This document provides comprehensive documentation for the SwiftUI and UIKit view implementations built on top of the `LottieRenderer` type.

## Table of Contents

1. [Architecture Overview](#architecture-overview)
2. [LottieConfiguration](#lottieconfiguration)
3. [LottieViewModel](#lottieviewmodel)
4. [LottieView (SwiftUI)](#lottieview-swiftui)
5. [LottieUIKitView (UIKit)](#lottieu ikitview-uikit)
6. [Testing](#testing)
7. [Usage Examples](#usage-examples)

---

## Architecture Overview

The Lottie views implementation consists of three main layers:

```
┌─────────────────────────────────────┐
│   LottieView / LottieUIKitView      │  ← View Layer (SwiftUI/UIKit)
└─────────────┬───────────────────────┘
              │
┌─────────────▼───────────────────────┐
│       LottieViewModel               │  ← Business Logic Layer
└─────────────┬───────────────────────┘
              │
┌─────────────▼───────────────────────┐
│       LottieRenderer                │  ← Rendering Layer
└─────────────────────────────────────┘
```

### Key Design Principles

1. **Separation of Concerns**: The ViewModel handles all business logic, state management, and rendering coordination, while views focus solely on presentation.

2. **Configuration-Driven**: All playback behavior is configured through the `LottieConfiguration` type, making it easy to customize animations.

3. **Reactive**: Uses Combine framework for reactive updates, ensuring UI stays in sync with animation state.

4. **Platform-Specific**: Views are conditionally compiled for iOS only, as they depend on UIKit.

---

## LottieConfiguration

The `LottieConfiguration` struct provides a declarative way to configure Lottie animation playback.

### Properties

#### Loop Mode
```swift
public enum LoopMode: Equatable {
    case playOnce       // Play once and stop
    case loop           // Loop indefinitely
    case repeat(count: Int)  // Repeat N times
    case autoReverse    // Play forward, then backward continuously
}
```

#### Content Mode
```swift
public enum ContentMode {
    case scaleToFill     // Fill view, may distort
    case scaleAspectFit  // Fit within view, maintain aspect
    case scaleAspectFill // Fill view, maintain aspect, may crop
}
```

#### All Configuration Options

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `loopMode` | `LoopMode` | `.loop` | Controls how the animation loops |
| `speed` | `Double` | `1.0` | Playback speed multiplier |
| `contentMode` | `ContentMode` | `.scaleAspectFit` | How content fits in view |
| `frameRate` | `Double` | `30.0` | Rendering frame rate (fps) |
| `pixelFormat` | `PixelFormat` | `.argb` | Pixel format for rendering |
| `autoPlay` | `Bool` | `true` | Start playing automatically |

### Example

```swift
let config = LottieConfiguration(
    loopMode: .repeat(count: 3),
    speed: 1.5,
    contentMode: .scaleAspectFit,
    frameRate: 60.0,
    pixelFormat: .argb,
    autoPlay: true
)
```

---

## LottieViewModel

The `LottieViewModel` is an `ObservableObject` that manages animation playback state and rendering.

### Published Properties

```swift
@Published public private(set) var renderedFrame: UIImage?
@Published public private(set) var playbackState: PlaybackState
@Published public private(set) var error: PlaybackError?
@Published public private(set) var progress: Double  // 0.0 to 1.0
```

### Playback State

```swift
public enum PlaybackState: Equatable {
    case playing
    case paused
    case stopped
    case completed
}
```

### Errors

```swift
public enum PlaybackError: Error, Equatable {
    case renderingFailed(String)
    case imageCreationFailed
    case invalidFrameIndex
}
```

### Public Methods

#### Playback Control

```swift
public func play()
public func pause()
public func stop()
```

#### Seeking

```swift
// Seek to progress (0.0 to 1.0)
public func seek(to progress: Double)

// Seek to specific frame
public func seek(toFrame frame: Float)
```

### Implementation Details

- **Thread Safety**: All UI updates are posted to the main thread
- **Memory Management**: Automatically cancels timers on deinit
- **Error Handling**: Errors are published rather than causing crashes
- **Efficient Rendering**: Buffer is reused across frames
- **Time-Based Playback**: Uses `CMTime` for precise animation timing
- **Decoupled Speed and Frame Rate**: 
  - `speed` controls playback rate (how fast animation time progresses)
  - `frameRate` controls rendering frequency (smoothness of display)

---

## LottieView (SwiftUI)

A SwiftUI view for displaying Lottie animations with declarative configuration.

### Basic Usage

```swift
import SwiftUI
import ThorVGSwift

struct ContentView: View {
    var body: some View {
        if let lottie = try? Lottie(path: "animation.json") {
            LottieView(lottie: lottie)
        }
    }
}
```

### Initialization

```swift
public init(
    lottie: Lottie,
    size: CGSize? = nil,
    configuration: LottieConfiguration = .default,
    engine: Engine = .main
)
```

**Parameters:**
- `lottie`: The Lottie animation to display
- `size`: Rendering size (uses animation's intrinsic size if nil)
- `configuration`: Playback configuration
- `engine`: ThorVG engine to use

### Accessing ViewModel Properties

To access playback state, progress, and errors, you can observe the view model directly:

```swift
struct ContentView: View {
    let lottie: Lottie
    @StateObject private var viewModel: LottieViewModel
    
    init(lottie: Lottie) {
        self.lottie = lottie
        _viewModel = StateObject(wrappedValue: LottieViewModel(
            lottie: lottie,
            size: CGSize(width: 300, height: 300)
        ))
    }
    
    var body: some View {
        VStack {
            Image(uiImage: viewModel.renderedFrame ?? UIImage())
                .resizable()
                .aspectRatio(contentMode: .fit)
            
            Text("Progress: \(Int(viewModel.progress * 100))%")
            Text("State: \(String(describing: viewModel.playbackState))")
            
            if let error = viewModel.error {
                Text("Error: \(error.localizedDescription)")
                    .foregroundColor(.red)
            }
        }
    }
}
```

### Lifecycle

- **onAppear**: Automatically starts playback if `autoPlay` is true
- **onDisappear**: Pauses playback to conserve resources

---

## LottieUIKitView (UIKit)

A UIKit view for displaying Lottie animations with similar functionality to the SwiftUI version.

### Basic Usage

```swift
import UIKit
import ThorVGSwift

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let lottie = try? Lottie(path: "animation.json") {
            let lottieView = LottieUIKitView(lottie: lottie)
            view.addSubview(lottieView)
            
            // Setup constraints...
        }
    }
}
```

### Initialization

```swift
// Basic initializer
public init(
    lottie: Lottie,
    size: CGSize? = nil,
    configuration: LottieConfiguration = .default,
    engine: Engine = .main
)

// Frame-based initializer
public convenience init(
    frame: CGRect,
    lottie: Lottie,
    configuration: LottieConfiguration = .default,
    engine: Engine = .main
)
```

### Public Properties

```swift
// Read-only state properties
public var playbackState: LottieViewModel.PlaybackState { get }
public var progress: Double { get }
public var error: LottieViewModel.PlaybackError? { get }

// Callbacks
public var onPlaybackStateChanged: ((LottieViewModel.PlaybackState) -> Void)?
public var onError: ((LottieViewModel.PlaybackError) -> Void)?
public var onProgressChanged: ((Double) -> Void)?
```

### Methods

```swift
// Playback control
public func play()
public func pause()
public func stop()

// Seeking
public func seek(to progress: Double)
public func seek(toFrame frame: Float)
```

### Example with Callbacks

```swift
let config = LottieConfiguration(
    loopMode: .playOnce,
    autoPlay: false
)

let lottieView = LottieUIKitView(
    lottie: myLottie,
    size: CGSize(width: 300, height: 300),
    configuration: config
)

lottieView.onPlaybackStateChanged = { state in
    if state == .completed {
        print("Animation finished!")
    }
}

lottieView.onProgressChanged = { progress in
    progressBar.progress = Float(progress)
}

lottieView.play()
```

### View Hierarchy

The `LottieUIKitView` contains a single `UIImageView` subview that displays the rendered frames. The image view is constrained to fill the parent view and uses Auto Layout.

---

## Testing

Comprehensive test suites are provided for all components:

### LottieViewModelTests

Tests for the ViewModel layer covering:
- Initialization with various configurations
- Playback control (play, pause, stop)
- Seeking functionality
- Loop modes (playOnce, loop, repeat, autoReverse)
- Published property updates
- Error handling
- Speed control
- Content modes
- Memory management

**Location**: `swift-tests/LottieViewModelTests.swift`

### LottieConfigurationTests

Tests for the configuration struct covering:
- Default configuration values
- Custom configuration initialization
- Partial configuration with defaults

**Location**: `swift-tests/LottieConfigurationTests.swift`

### LottieTests

Tests for the core `Lottie` model covering:
- Frame count and duration validation
- `frameDuration` calculation
- Initialization from path and string
- Error handling

**Location**: `swift-tests/LottieTests.swift`

### View Testing

View layer testing is accomplished through **SwiftUI Previews** which allow for:
- Visual verification of rendering
- Interactive testing of playback controls
- Testing various configurations and loop modes
- Real-time debugging

**Location**: Preview implementations in `LottieView.swift` and `LottieUIKitView.swift`

### Running Tests

Since this is an iOS-only package, tests should be run on iOS Simulator:

```bash
cd /path/to/thorvg.swift
swift test --destination 'platform=iOS Simulator'
```

Or use Xcode's test runner for interactive testing with Previews.

---

## Usage Examples

### Example 1: Simple Looping Animation

```swift
// SwiftUI
struct SimpleAnimationView: View {
    let lottie = try! Lottie(path: "loader.json")
    
    var body: some View {
        LottieView(
            lottie: lottie,
            size: CGSize(width: 100, height: 100)
        )
    }
}

// UIKit
let lottie = try! Lottie(path: "loader.json")
let lottieView = LottieUIKitView(
    lottie: lottie,
    size: CGSize(width: 100, height: 100)
)
view.addSubview(lottieView)
```

### Example 2: Play Once with Completion Handler

```swift
// SwiftUI
struct OneShotAnimationView: View {
    let lottie = try! Lottie(path: "success.json")
    @StateObject private var viewModel: LottieViewModel
    @State private var isComplete = false
    
    init(lottie: Lottie) {
        self.lottie = lottie
        _viewModel = StateObject(wrappedValue: LottieViewModel(
            lottie: lottie,
            size: CGSize(width: 300, height: 300),
            configuration: LottieConfiguration(loopMode: .playOnce)
        ))
    }
    
    var body: some View {
        VStack {
            Image(uiImage: viewModel.renderedFrame ?? UIImage())
                .resizable()
                .aspectRatio(contentMode: .fit)
        }
        .onChange(of: viewModel.playbackState) { state in
            if state == .completed {
                isComplete = true
                // Navigate away or show next screen
            }
        }
        .onAppear {
            viewModel.play()
        }
    }
}

// UIKit
let config = LottieConfiguration(loopMode: .playOnce)
let lottieView = LottieUIKitView(lottie: lottie, configuration: config)

lottieView.onPlaybackStateChanged = { state in
    if state == .completed {
        // Navigate away or show next screen
    }
}
```

### Example 3: Manual Playback Control

```swift
// SwiftUI
struct ControlledAnimationView: View {
    let lottie: Lottie
    @StateObject private var viewModel: LottieViewModel
    
    init(lottie: Lottie) {
        self.lottie = lottie
        _viewModel = StateObject(wrappedValue: LottieViewModel(
            lottie: lottie,
            size: CGSize(width: 300, height: 300),
            configuration: LottieConfiguration(autoPlay: false)
        ))
    }
    
    var body: some View {
        VStack {
            Image(uiImage: viewModel.renderedFrame ?? UIImage())
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 300, height: 300)
            
            HStack {
                Button("Play") { viewModel.play() }
                Button("Pause") { viewModel.pause() }
                Button("Stop") { viewModel.stop() }
            }
        }
    }
}

// UIKit
let config = LottieConfiguration(autoPlay: false)
let lottieView = LottieUIKitView(lottie: lottie, configuration: config)

// Control buttons
playButton.addTarget(self, action: #selector(play), for: .touchUpInside)
pauseButton.addTarget(self, action: #selector(pause), for: .touchUpInside)
stopButton.addTarget(self, action: #selector(stop), for: .touchUpInside)

@objc func play() { lottieView.play() }
@objc func pause() { lottieView.pause() }
@objc func stop() { lottieView.stop() }
```

### Example 4: Progress Tracking with Slider

```swift
// SwiftUI
struct ProgressAnimationView: View {
    let lottie: Lottie
    @StateObject private var viewModel: LottieViewModel
    
    init(lottie: Lottie) {
        self.lottie = lottie
        _viewModel = StateObject(wrappedValue: LottieViewModel(
            lottie: lottie,
            size: CGSize(width: 300, height: 300),
            configuration: LottieConfiguration(autoPlay: false)
        ))
    }
    
    var body: some View {
        VStack {
            Image(uiImage: viewModel.renderedFrame ?? UIImage())
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 300, height: 300)
            
            Slider(value: Binding(
                get: { viewModel.progress },
                set: { viewModel.seek(to: $0) }
            ), in: 0...1)
            
            Text("Progress: \(Int(viewModel.progress * 100))%")
        }
    }
}

// UIKit
let config = LottieConfiguration(autoPlay: false)
let lottieView = LottieUIKitView(lottie: lottie, configuration: config)

lottieView.onProgressChanged = { progress in
    progressSlider.value = Float(progress)
    progressLabel.text = "\(Int(progress * 100))%"
}

@objc func sliderValueChanged(_ slider: UISlider) {
    lottieView.seek(to: Double(slider.value))
}
```

### Example 5: Fast Playback

```swift
let config = LottieConfiguration(
    loopMode: .loop,
    speed: 2.0,  // 2x speed
    frameRate: 60.0
)

// SwiftUI
LottieView(lottie: lottie, configuration: config)

// UIKit
let lottieView = LottieUIKitView(lottie: lottie, configuration: config)
```

### Example 6: Auto-Reverse Animation

```swift
let config = LottieConfiguration(
    loopMode: .autoReverse,
    speed: 1.0
)

// SwiftUI
LottieView(lottie: lottie, configuration: config)

// UIKit
let lottieView = LottieUIKitView(lottie: lottie, configuration: config)
```

### Example 7: Error Handling

```swift
// SwiftUI
struct SafeAnimationView: View {
    let lottie: Lottie
    @StateObject private var viewModel: LottieViewModel
    
    init(lottie: Lottie) {
        self.lottie = lottie
        _viewModel = StateObject(wrappedValue: LottieViewModel(
            lottie: lottie,
            size: CGSize(width: 300, height: 300)
        ))
    }
    
    var body: some View {
        VStack {
            Image(uiImage: viewModel.renderedFrame ?? UIImage())
                .resizable()
                .aspectRatio(contentMode: .fit)
            
            if let error = viewModel.error {
                Text("Error: \(error.localizedDescription)")
                    .foregroundColor(.red)
            }
        }
        .onAppear {
            viewModel.play()
        }
    }
}

// UIKit
lottieView.onError = { [weak self] error in
    let alert = UIAlertController(
        title: "Animation Error",
        message: error.localizedDescription,
        preferredStyle: .alert
    )
    alert.addAction(UIAlertAction(title: "OK", style: .default))
    self?.present(alert, animated: true)
}
```

---

## Best Practices

### 1. Resource Management

Always ensure Lottie animations are properly loaded and handle errors:

```swift
guard let url = Bundle.main.url(forResource: "animation", withExtension: "json") else {
    // Handle missing resource
    return
}

do {
    let lottie = try Lottie(path: url.path)
    // Use lottie
} catch {
    // Handle loading error
}
```

### 2. Size Considerations

For best performance, specify an appropriate size:

```swift
// Good: Explicit size matching your layout
LottieView(lottie: lottie, size: CGSize(width: 300, height: 300))

// Acceptable: Uses intrinsic size (may be very large)
LottieView(lottie: lottie)
```

### 3. Auto-Play Configuration

Consider disabling auto-play for user-controlled animations:

```swift
let config = LottieConfiguration(autoPlay: false)
let lottieView = LottieUIKitView(lottie: lottie, configuration: config)

// Start playback when appropriate
button.addTarget(self, action: #selector(playAnimation), for: .touchUpInside)
```

### 4. Memory Management

Views automatically clean up resources, but for long-lived animations:

```swift
override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    lottieView.stop()  // Stop and reset
}
```

### 5. Configuration Reuse

Create reusable configurations:

```swift
extension LottieConfiguration {
    static let onboarding = LottieConfiguration(
        loopMode: .playOnce,
        speed: 1.0,
        autoPlay: true
    )
    
    static let loader = LottieConfiguration(
        loopMode: .loop,
        speed: 1.5,
        frameRate: 30.0
    )
}

// Usage
LottieView(lottie: lottie, configuration: .onboarding)
```

---

## Platform Support

- **Platform**: iOS only
- **Minimum iOS Version**: iOS 13.0 (ViewModel and UIKit views), iOS 14.0 (SwiftUI views due to `@StateObject`)
- **Minimum Swift Version**: Swift 5.9
- **Testing**: Run tests with `swift test --destination 'platform=iOS Simulator'`

This package is designed exclusively for iOS and requires UIKit.

---

## Troubleshooting

### Issue: Animation not playing

**Solution**: Check that:
1. The Lottie file is valid and loads successfully
2. `autoPlay` is set to `true` or you've called `play()` manually
3. The view is added to the view hierarchy (UIKit) or appears (SwiftUI)

### Issue: Poor performance

**Solution**:
1. Reduce the rendering size
2. Lower the frame rate
3. Consider using a simpler animation

### Issue: Animation appears distorted

**Solution**: Check the `contentMode` configuration:
- Use `.scaleAspectFit` to maintain aspect ratio
- Use `.scaleToFill` if distortion is acceptable

### Issue: Memory warnings

**Solution**:
1. Ensure you're not creating too many simultaneous animations
2. Stop animations when views are off-screen
3. Use appropriate sizes (avoid rendering at unnecessarily high resolutions)

---

## License

This implementation is part of the ThorVGSwift library. See LICENSE file for details.

