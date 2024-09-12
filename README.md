# ThorVG for Swift
<p align="center"> <img width="800" height="auto" src="./res/thorvg-swift-logo.png"> </p>

ThorVG for Swift is a lightweight wrapper around the [ThorVG C++ API](https://github.com/thorvg/thorvg), providing native support for vector graphics in Swift applications. This package currently only supports rendering Lottie animations and is actively evolving to include more features.

**ThorVG Version:** `v0.14.7` (commit `e3a6bf`)   
**Supported Platforms:** iOS (minimum deployment target: iOS 13.0)

## Contents
- [Installation](#installation)
- [Usage](#usage)
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

The API of `ThorVGSwift` closely follows the structure of the original ThorVG API. It enables rendering of Lottie frames to a buffer. Below is a quick guide to help you get started with the essential APIs.

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