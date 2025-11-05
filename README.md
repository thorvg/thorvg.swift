swift-tests/LottieTests.swift# ThorVG for Swift
<p align="center"> <img width="800" height="auto" src="./res/thorvg-swift-logo.png"> </p>

ThorVG for Swift is a lightweight wrapper around the [ThorVG C++ API](https://github.com/thorvg/thorvg), providing native support for vector graphics in Swift applications. This package currently only supports rendering Lottie animations and is actively evolving to include more features.

**ThorVG Version:** `v0.14.7` (commit `e3a6bf`)   
**Supported Platforms:** iOS (minimum deployment target: iOS 13.0)

## Contents
- [Installation](#installation)
- [Usage](#usage)
  - [Low-Level API (Direct Rendering)](#low-level-api-direct-rendering)
  - [High-Level Views API (SwiftUI & UIKit)](#high-level-views-api-swiftui--uikit)
- [Build](#build)
- [Contributing](#contributing)

## Installation
To integrate `ThorVGSwift` into your Swift project, use Swift Package Manager. Simply add the following line to the dependencies section of your `Package.swift` file:

```swift
dependencies: [
  // ...
  .package(url: "https://github.com/thorvg/thorvg.swift", from: "0.1.0")
]
```

## Usage
This Swift wrapper currently only supports rendering Lottie animations. As the package evolves, additional support for more content types will be added.

ThorVGSwift provides two levels of API:
1. **Low-Level API**: Direct access to the rendering engine for frame-by-frame control
2. **High-Level Views API**: Ready-to-use SwiftUI and UIKit views with playback controls

### Low-Level API (Direct Rendering)

The low-level API closely follows the structure of the original ThorVG API, enabling rendering of Lottie frames to a buffer. This is useful when you need fine-grained control over frame rendering.

To start, create a `Lottie` instance using a desired local file path.

```swift
let url = Bundle.main.url(forResource: "test", withExtension: "json")
let lottie = try Lottie(path: url.path)
```

If you only have the string data of the Lottie, you can use the alternate `String` initialiser.

```swift
let lottie = try Lottie(string: "...")
```

Next, initialise a buffer for ThorVG to draw Lottie frame data into.

```swift
let size = CGSize(width: 1024, height: 1024)
let buffer = [UInt32](repeating: 0, count: Int(size.width * size.height))
```

From here, initialise a `LottieRenderer` instance to handle the rendering of individual Lottie frames.

```swift
let renderer = LottieRenderer(
    lottie,
    size: size,
    buffer: &buffer,
    stride: Int(size.width),
    pixelFormat: .argb
)
```

> [!NOTE]
> You can use different pixel formats including `.argb`, `.rgba`, etc. (see the complete list [here](/swift/PixelFormat.swift)).

By default, the `LottieRenderer` runs on the main thread. If needed, you can create a custom `Engine` with multiple threads.

```swift
let engine = Engine(numberOfThreads: 4)
let renderer = LottieRenderer(
    lottie,
    engine: engine,
    size: size,
    buffer: &buffer,
    stride: Int(size.width),
    pixelFormat: .argb
)
```

Once your `LottieRenderer` is set up, you can start rendering Lottie frames using the `render` function.

The `render` function takes three parameters:
- `frameIndex`: the index of the frame to render
- `contentRect`: the area of the Lottie content to render
- `rotation` (optional): the rotation angle to apply to the renderered frame

```swift
let contentRect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
try renderer.render(frameIndex: 0, contentRect: contentRect, rotation: 0.0)
```

And voilà! Your buffer is now filled with the rendered Lottie frame data.

> [!TIP]
> To render all of the frames in a `Lottie` animation, you can iterate through the `numberOfFrames` property of the `Lottie` class.

### High-Level Views API (SwiftUI & UIKit)

For most use cases, ThorVGSwift provides convenient view components that handle rendering, playback, and animation lifecycle automatically.

#### SwiftUI

```swift
import SwiftUI
import ThorVGSwift

struct ContentView: View {
    @StateObject private var viewModel: LottieViewModel
    
    init() {
        let lottie = try! Lottie(path: "animation.json")
        let config = LottieConfiguration(loopMode: .loop, speed: 1.0)
        _viewModel = StateObject(wrappedValue: LottieViewModel(
            lottie: lottie,
            size: CGSize(width: 300, height: 300),
            configuration: config
        ))
    }
    
    var body: some View {
        LottieView(viewModel: viewModel)
            .onAppear { viewModel.play() }
    }
}
```

#### UIKit

```swift
import UIKit
import ThorVGSwift

class ViewController: UIViewController {
    private var viewModel: LottieViewModel!
    private var lottieView: LottieUIKitView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let lottie = try! Lottie(path: "animation.json")
        let config = LottieConfiguration(loopMode: .loop, speed: 1.0)
        
        viewModel = LottieViewModel(
            lottie: lottie,
            size: CGSize(width: 300, height: 300),
            configuration: config
        )
        lottieView = LottieUIKitView(viewModel: viewModel)
        
        view.addSubview(lottieView)
        // Add constraints...
        
        viewModel.play()
    }
}
```

#### Features

The high-level Views API provides:
- ✅ **Automatic Playback**: Control loop modes (playOnce, loop, repeat, autoReverse)
- ✅ **Speed Control**: Adjust playback speed with the `speed` parameter
- ✅ **Content Modes**: Scale animations to fit, fill, or maintain aspect ratio
- ✅ **Progress Tracking**: Monitor playback progress and state
- ✅ **Error Handling**: Built-in error reporting through published properties
- ✅ **Manual Controls**: Play, pause, stop, and seek to specific frames
- ✅ **SwiftUI Previews**: Interactive previews for rapid development

📖 **[View Complete Views API Documentation →](VIEWS_API_DOCUMENTATION.md)**

The full documentation includes:
- Detailed API reference for `LottieView`, `LottieUIKitView`, and `LottieViewModel`
- Configuration options and best practices
- Complete usage examples and integration patterns
- Testing strategies and troubleshooting guides

## Build
Follow these steps to configure your environment and build the ThorVG Swift package in Xcode.

### Build with Swift Package Manager
Before building the Swift package in Xcode, make sure to run the `setup.sh` script:

```bash
./setup.sh
```

This script updates the submodule reference and copies the necessary configuration files required for compilation.

> [!WARNING]
> ThorVG uses the Meson build system to generate artifacts, including a `config.h` file required for compilation.    
> Since Swift Package Manager needs all files present at compile time, this file must be generated before building.   
> The `setup.sh` script handles this by copying a pre-built `config.h` file into the correct location within the `thorvg/src` directory.

> [!IMPORTANT]
> After running the setup, you'll see a `config.h` file in the git status of the ThorVG submodule. This is expected, and you can safely ignore this file when reviewing changes or making commits.

Once the setup script is executed, you can successfully build the ThorVG Swift package in Xcode.

## Contributing
Contributions are welcome! If you'd like to help, feel free to open an issue or submit a pull request.
