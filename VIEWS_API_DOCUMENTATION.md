# Lottie Views API Documentation

This document provides comprehensive documentation for the SwiftUI and UIKit view implementations built on top of the `LottieRenderer` type.

## Table of Contents

1. [Architecture Overview](#architecture-overview)
2. [LottieConfiguration](#lottieconfiguration)
3. [LottieViewModel](#lottieviewmodel)
4. [LottieView (SwiftUI)](#lottieview-swiftui)
5. [LottieUIKitView (UIKit)](#lottieuitkitview-uikit)
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

1. **External ViewModel Pattern**: Views accept a pre-configured `LottieViewModel`, giving users complete control over playback and state observation.

2. **Single Source of Truth**: All playback control (`play()`, `pause()`, `stop()`, `seek()`) happens through the ViewModel, not the views.

3. **Configuration-Driven**: All rendering behavior is configured through the `LottieConfiguration` type, making it easy to customize animations.

4. **Reactive**: Uses Combine framework for reactive updates, ensuring UI stays in sync with animation state.

5. **Platform-Specific**: Views are conditionally compiled for iOS only, as they depend on UIKit.

---

## LottieConfiguration

The `LottieConfiguration` struct provides a declarative way to configure Lottie animation rendering and playback behavior.

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
    case scaleAspectFit  // Fit within view, maintain aspect
    case scaleAspectFill // Fill view, maintain aspect, may crop
}
```

> [!NOTE]
> Content modes control how the animation is cropped/scaled **during rendering**, not view-level scaling. For best results, pass a `size` parameter to `LottieViewModel` that matches your view's frame dimensions. See [Understanding Content Modes and Render Size](#understanding-content-modes-and-render-size) for details.

#### All Configuration Options

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `loopMode` | `LoopMode` | `.loop` | Controls how the animation loops |
| `speed` | `Double` | `1.0` | Playback speed multiplier |
| `contentMode` | `ContentMode` | `.scaleAspectFit` | How content fits in view |
| `frameRate` | `Double` | `30.0` | Rendering frame rate (fps) |
| `pixelFormat` | `PixelFormat` | `.argb` | Pixel format for rendering |

### Example

```swift
let config = LottieConfiguration(
    loopMode: .repeat(count: 3),
    speed: 1.5,
    contentMode: .scaleAspectFit,
    frameRate: 60.0,
    pixelFormat: .argb
)
```

### Understanding Content Modes and Render Size

Content modes control how the animation is **rendered to the buffer**, not how the view is displayed on screen:

**`.scaleAspectFit` (default)**
- Renders the complete animation
- Maintains aspect ratio
- Best for most use cases where you want to see the entire animation

**`.scaleAspectFill`**
- Fills the render buffer completely
- Maintains aspect ratio by cropping content
- Requires the `size` parameter in `LottieViewModel` to match your view's display dimensions for predictable cropping

**How it works:**
```swift
// Example 1: Using default intrinsic size (recommended)
let viewModel = LottieViewModel(
    lottie: lottie,
    configuration: LottieConfiguration(contentMode: .scaleAspectFit)
)
// SwiftUI or UIKit then scales the rendered image to fit your view frame

// Example 2: Using scaleAspectFill with explicit size
let viewModel = LottieViewModel(
    lottie: lottie,
    size: CGSize(width: 300, height: 150),  // Match your view frame
    configuration: LottieConfiguration(contentMode: .scaleAspectFill)
)
// Renders at 300x150, cropping to fill this specific size
```

---

## LottieViewModel

The `LottieViewModel` is an `ObservableObject` that manages animation playback state and rendering. Users create and own the ViewModel, then pass it to views.

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
    case contextCreationFailed
    case invalidFrameIndex
}
```

- `renderingFailed`: The underlying ThorVG renderer failed to render a frame
- `imageCreationFailed`: Failed to create a `UIImage` from the rendered buffer
- `contextCreationFailed`: Failed to create a `CGContext` for rendering
- `invalidFrameIndex`: Attempted to render an invalid frame index

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
- `lottie`: The Lottie animation to render
- `size`: Optional render size. If `nil`, defaults to `lottie.frameSize` (the animation's intrinsic dimensions)
- `configuration`: Animation playback and rendering configuration
- `engine`: The ThorVG rendering engine to use (defaults to `.main`)

**Understanding the `size` Parameter:**

The `size` parameter controls the **render buffer dimensions** and interacts with `contentMode`:

- **When `nil` (default)**: Renders at the animation's intrinsic size. The view layer (SwiftUI/UIKit) handles scaling to fit your UI. Best for most use cases.

- **When specified**: Renders at the exact dimensions you provide. Useful when:
  - Using `.scaleAspectFill` to crop content (requires matching the view's display size)
  - Optimizing performance for very large or very small display sizes
  - You know the exact display dimensions ahead of time

**Example:**
```swift
// Use intrinsic size - SwiftUI handles scaling
let viewModel = LottieViewModel(
    lottie: lottie,
    configuration: .default
)

// Or specify size for scaleAspectFill cropping
let viewModel = LottieViewModel(
    lottie: lottie,
    size: CGSize(width: 300, height: 150),  // Wide frame
    configuration: LottieConfiguration(contentMode: .scaleAspectFill)
)
```

### Implementation Details

- **Thread Safety**: All UI updates are posted to the main thread
- **Memory Management**: Automatically cancels timers on deinit
- **Error Handling**: Errors are published rather than causing crashes
- **Efficient Rendering**: 
  - Buffer is reused across frames
  - CGContext is created once and reused for all frames
- **Time-Based Playback**: Uses `CMTime` for precise animation timing
- **Decoupled Speed and Frame Rate**: 
  - `speed` controls playback rate (how fast animation time progresses)
  - `frameRate` controls rendering frequency (smoothness of display)

---

## LottieView (SwiftUI)

A SwiftUI view for displaying Lottie animations. The view accepts an external `LottieViewModel` for complete control over playback and state observation.

### Basic Usage

```swift
import SwiftUI
import ThorVGSwift

struct ContentView: View {
    @StateObject private var viewModel: LottieViewModel
    
    init() {
        guard let lottie = try? Lottie(path: "animation.json") else {
            fatalError("Failed to load Lottie")
        }
        
        // Size is optional - defaults to animation's intrinsic size
        _viewModel = StateObject(wrappedValue: LottieViewModel(
            lottie: lottie,
            configuration: .default
        ))
    }
    
    var body: some View {
        LottieView(viewModel: viewModel)
            .frame(width: 300, height: 300)  // SwiftUI handles scaling
            .onAppear { viewModel.play() }
            .onChange(of: viewModel.error) { _, error in
                if let error = error {
                    print("Animation error: \(error)")
                }
            }
    }
}
```

### Initialization

```swift
public init(viewModel: LottieViewModel)
```

**Parameters:**
- `viewModel`: The view model managing animation state and rendering. Create using `@StateObject` to maintain ownership.

### Accessing ViewModel Properties

Since you create the ViewModel externally, you have direct access to all its properties:

```swift
struct ContentView: View {
    @StateObject private var viewModel: LottieViewModel
    
    init(lottie: Lottie) {
        _viewModel = StateObject(wrappedValue: LottieViewModel(
            lottie: lottie,
            size: CGSize(width: 300, height: 300)
        ))
    }
    
    var body: some View {
        VStack {
            LottieView(viewModel: viewModel)
                .frame(width: 300, height: 300)
            
            // Direct access to ViewModel properties
            Text("Progress: \(Int(viewModel.progress * 100))%")
            Text("State: \(String(describing: viewModel.playbackState))")
            
            if let error = viewModel.error {
                Text("Error: \(error.localizedDescription)")
                    .foregroundColor(.red)
            }
            
            // Direct playback control
            HStack {
                Button("Play") { viewModel.play() }
                Button("Pause") { viewModel.pause() }
                Button("Stop") { viewModel.stop() }
            }
        }
        .onChange(of: viewModel.playbackState) { _, state in
            print("Playback state changed: \(state)")
        }
    }
}
```

### Lifecycle

- **onDisappear**: Automatically pauses playback to conserve resources

---

## LottieUIKitView (UIKit)

A UIKit view for displaying Lottie animations. Like the SwiftUI view, it accepts an external `LottieViewModel`.

### Basic Usage

```swift
import UIKit
import ThorVGSwift

class ViewController: UIViewController {
    private var viewModel: LottieViewModel!
    private var lottieView: LottieUIKitView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let lottie = try? Lottie(path: "animation.json") else { return }
        
        viewModel = LottieViewModel(
            lottie: lottie,
            size: CGSize(width: 300, height: 300),
            configuration: .default
        )
        
        lottieView = LottieUIKitView(viewModel: viewModel)
        view.addSubview(lottieView)
        
        // Setup constraints...
        
        viewModel.play()
    }
}
```

### Initialization

```swift
public init(viewModel: LottieViewModel)
```

**Parameters:**
- `viewModel`: The view model managing animation state and rendering.

### Public Properties

```swift
// Access to the ViewModel
public let viewModel: LottieViewModel

// Callbacks (optional, for convenience)
public var onPlaybackStateChanged: ((LottieViewModel.PlaybackState) -> Void)?
public var onError: ((LottieViewModel.PlaybackError) -> Void)?
public var onProgressChanged: ((Double) -> Void)?
```

### Playback Control

All playback control happens through the ViewModel:

```swift
// Directly on ViewModel
viewModel.play()
viewModel.pause()
viewModel.stop()
viewModel.seek(to: 0.5)
viewModel.seek(toFrame: 10)
```

### Example with Callbacks

```swift
let config = LottieConfiguration(loopMode: .playOnce)

let viewModel = LottieViewModel(
    lottie: myLottie,
    size: CGSize(width: 300, height: 300),
    configuration: config
)

let lottieView = LottieUIKitView(viewModel: viewModel)

lottieView.onPlaybackStateChanged = { state in
    if state == .completed {
        print("Animation finished!")
    }
}

lottieView.onProgressChanged = { progress in
    progressBar.progress = Float(progress)
}

viewModel.play()
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
- Speed control (independent of frame rate)
- Frame rate control (rendering frequency)
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
- Testing different speeds (0.5x, 1x, 2x)
- Testing different frame rates (30fps, 60fps)
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
    @StateObject private var viewModel: LottieViewModel
    
    init() {
        let lottie = try! Lottie(path: "loader.json")
        _viewModel = StateObject(wrappedValue: LottieViewModel(
            lottie: lottie,
            configuration: .default
        ))
    }
    
    var body: some View {
        LottieView(viewModel: viewModel)
            .frame(width: 100, height: 100)
            .onAppear { viewModel.play() }
    }
}

// UIKit
let lottie = try! Lottie(path: "loader.json")
let viewModel = LottieViewModel(lottie: lottie)
let lottieView = LottieUIKitView(viewModel: viewModel)
lottieView.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
view.addSubview(lottieView)
viewModel.play()
```

### Example 2: Play Once with Completion Handler

```swift
// SwiftUI
struct OneShotAnimationView: View {
    @StateObject private var viewModel: LottieViewModel
    @State private var isComplete = false
    
    init(lottie: Lottie) {
        let config = LottieConfiguration(loopMode: .playOnce)
        _viewModel = StateObject(wrappedValue: LottieViewModel(
            lottie: lottie,
            configuration: config
        ))
    }
    
    var body: some View {
        LottieView(viewModel: viewModel)
            .frame(width: 300, height: 300)
            .onChange(of: viewModel.playbackState) { _, state in
                if state == .completed {
                    isComplete = true
                    // Navigate away or show next screen
                }
            }
            .onAppear { viewModel.play() }
    }
}

// UIKit
let config = LottieConfiguration(loopMode: .playOnce)
let viewModel = LottieViewModel(lottie: lottie, configuration: config)
let lottieView = LottieUIKitView(viewModel: viewModel)
lottieView.frame = CGRect(x: 0, y: 0, width: 300, height: 300)

lottieView.onPlaybackStateChanged = { state in
    if state == .completed {
        // Navigate away or show next screen
    }
}

viewModel.play()
```

### Example 3: Manual Playback Control

```swift
// SwiftUI
struct ControlledAnimationView: View {
    @StateObject private var viewModel: LottieViewModel
    
    init(lottie: Lottie) {
        _viewModel = StateObject(wrappedValue: LottieViewModel(lottie: lottie))
    }
    
    var body: some View {
        VStack {
            LottieView(viewModel: viewModel)
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
let viewModel = LottieViewModel(lottie: lottie)
let lottieView = LottieUIKitView(viewModel: viewModel)
lottieView.frame = CGRect(x: 0, y: 0, width: 300, height: 300)

// Control buttons
playButton.addTarget(self, action: #selector(play), for: .touchUpInside)
pauseButton.addTarget(self, action: #selector(pause), for: .touchUpInside)
stopButton.addTarget(self, action: #selector(stop), for: .touchUpInside)

@objc func play() { viewModel.play() }
@objc func pause() { viewModel.pause() }
@objc func stop() { viewModel.stop() }
```

### Example 4: Progress Tracking with Slider

```swift
// SwiftUI
struct ProgressAnimationView: View {
    @StateObject private var viewModel: LottieViewModel
    
    init(lottie: Lottie) {
        _viewModel = StateObject(wrappedValue: LottieViewModel(lottie: lottie))
    }
    
    var body: some View {
        VStack {
            LottieView(viewModel: viewModel)
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
let viewModel = LottieViewModel(lottie: lottie)
let lottieView = LottieUIKitView(viewModel: viewModel)
lottieView.frame = CGRect(x: 0, y: 0, width: 300, height: 300)

lottieView.onProgressChanged = { progress in
    progressSlider.value = Float(progress)
    progressLabel.text = "\(Int(progress * 100))%"
}

@objc func sliderValueChanged(_ slider: UISlider) {
    viewModel.seek(to: Double(slider.value))
}
```

### Example 5: Custom Speed

```swift
let config = LottieConfiguration(
    loopMode: .loop,
    speed: 2.0  // 2x speed
)

// SwiftUI
@StateObject var viewModel = LottieViewModel(
    lottie: lottie,
    configuration: config
)
LottieView(viewModel: viewModel)
    .frame(width: 300, height: 300)
    .onAppear { viewModel.play() }

// UIKit
let viewModel = LottieViewModel(lottie: lottie, configuration: config)
let lottieView = LottieUIKitView(viewModel: viewModel)
lottieView.frame = CGRect(x: 0, y: 0, width: 300, height: 300)
viewModel.play()
```

### Example 6: High Frame Rate

```swift
let config = LottieConfiguration(
    loopMode: .loop,
    frameRate: 60.0  // Smoother rendering
)

// SwiftUI
@StateObject var viewModel = LottieViewModel(
    lottie: lottie,
    configuration: config
)
LottieView(viewModel: viewModel)
    .frame(width: 300, height: 300)
    .onAppear { viewModel.play() }

// UIKit
let viewModel = LottieViewModel(lottie: lottie, configuration: config)
let lottieView = LottieUIKitView(viewModel: viewModel)
lottieView.frame = CGRect(x: 0, y: 0, width: 300, height: 300)
viewModel.play()
```

### Example 7: Auto-Reverse Animation

```swift
let config = LottieConfiguration(loopMode: .autoReverse)

// SwiftUI
@StateObject var viewModel = LottieViewModel(
    lottie: lottie,
    configuration: config
)
LottieView(viewModel: viewModel)
    .frame(width: 300, height: 300)
    .onAppear { viewModel.play() }

// UIKit
let viewModel = LottieViewModel(lottie: lottie, configuration: config)
let lottieView = LottieUIKitView(viewModel: viewModel)
lottieView.frame = CGRect(x: 0, y: 0, width: 300, height: 300)
viewModel.play()
```

### Example 8: Error Handling

```swift
// SwiftUI
struct SafeAnimationView: View {
    @StateObject private var viewModel: LottieViewModel
    
    init(lottie: Lottie) {
        _viewModel = StateObject(wrappedValue: LottieViewModel(lottie: lottie))
    }
    
    var body: some View {
        VStack {
            LottieView(viewModel: viewModel)
                .frame(width: 300, height: 300)
            
            if let error = viewModel.error {
                Text("Error: \(error.localizedDescription)")
                    .foregroundColor(.red)
            }
        }
        .onAppear { viewModel.play() }
        .onChange(of: viewModel.error) { _, error in
            if let error = error {
                print("Animation error occurred: \(error)")
            }
        }
    }
}

// UIKit
let viewModel = LottieViewModel(lottie: lottie)
let lottieView = LottieUIKitView(viewModel: viewModel)
lottieView.frame = CGRect(x: 0, y: 0, width: 300, height: 300)

lottieView.onError = { [weak self] error in
    let alert = UIAlertController(
        title: "Animation Error",
        message: error.localizedDescription,
        preferredStyle: .alert
    )
    alert.addAction(UIAlertAction(title: "OK", style: .default))
    self?.present(alert, animated: true)
}

viewModel.play()
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

### 2. ViewModel Ownership

Always use `@StateObject` in SwiftUI to maintain ViewModel ownership:

```swift
// ✅ Good: StateObject maintains ownership
@StateObject private var viewModel = LottieViewModel(...)

// ❌ Bad: ObservedObject doesn't maintain ownership
@ObservedObject private var viewModel = LottieViewModel(...)
```

### 3. Size Considerations

The `size` parameter is optional and defaults to the animation's intrinsic size:

```swift
// ✅ Recommended: Use default size (animation's intrinsic dimensions)
// Let SwiftUI/UIKit handle scaling to your desired frame
LottieViewModel(lottie: lottie)

// ✅ Also valid: Specify size when using .scaleAspectFill
// or when you need to optimize for a specific display size
LottieViewModel(lottie: lottie, size: CGSize(width: 300, height: 300))
```

For most use cases, omit the `size` parameter and use SwiftUI's `.frame()` or UIKit's frame property to control the display size.

### 4. Explicit Playback Control

Start playback explicitly when appropriate:

```swift
// SwiftUI
LottieView(viewModel: viewModel)
    .onAppear { viewModel.play() }

// UIKit
viewModel.play()
```

### 5. Memory Management

Views automatically clean up resources, but for long-lived animations:

```swift
override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    viewModel.stop()  // Stop and reset
}
```

### 6. Configuration Reuse

Create reusable configurations:

```swift
extension LottieConfiguration {
    static let onboarding = LottieConfiguration(
        loopMode: .playOnce,
        speed: 1.0
    )
    
    static let loader = LottieConfiguration(
        loopMode: .loop,
        speed: 1.5,
        frameRate: 30.0
    )
    
    static let highQuality = LottieConfiguration(
        loopMode: .loop,
        frameRate: 60.0
    )
}

// Usage
let viewModel = LottieViewModel(lottie: lottie, configuration: .onboarding)
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
2. You've called `viewModel.play()` manually
3. The view is added to the view hierarchy (UIKit) or appears (SwiftUI)

### Issue: Poor performance

**Solution**:
1. Reduce the rendering size
2. Lower the frame rate (default 30fps is usually sufficient)
3. Consider using a simpler animation

### Issue: Animation appears distorted or cropped

**Solution**: Check the `contentMode` configuration:
- Use `.scaleAspectFit` (default) to show the full animation while maintaining aspect ratio
- Use `.scaleAspectFill` to fill the view while maintaining aspect ratio (may crop content)
- When using `.scaleAspectFill`, ensure the `size` parameter matches your view's display dimensions

### Issue: Animation plays too fast/slow at higher frame rates

**Solution**: This is working correctly! `frameRate` and `speed` are decoupled:
- `frameRate` controls rendering smoothness (30fps vs 60fps)
- `speed` controls playback rate (1.0x, 2.0x, etc.)

### Issue: Memory warnings

**Solution**:
1. Ensure you're not creating too many simultaneous animations
2. Stop animations when views are off-screen
3. Use appropriate sizes (avoid rendering at unnecessarily high resolutions)

---

## License

This implementation is part of the ThorVGSwift library. See LICENSE file for details.
