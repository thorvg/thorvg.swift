# ThorVGSwift Sample App

An interactive iOS sample application demonstrating all features of ThorVGSwift.

## What's Inside

This sample app showcases:

- **Basic Animation**: Simple looping Lottie animations
- **Playback Controls**: Play, pause, stop, and seek controls
- **Speed Control**: Adjust animation speed (0.5x, 1x, 2x)
- **Loop Modes**: Different looping behaviors (once, loop, repeat N times, auto-reverse)
- **Manual Controls**: Interactive playback with state management
- **Slider Seeking**: Scrub through animation frames with a slider
- **Content Modes**: Aspect fit vs. aspect fill scaling
- **UIKit Integration**: Example of using `LottieUIKitView` with `UIViewRepresentable`

## How to Run

1. **Open the project**:
   ```bash
   cd ThorVGSampleApp
   open ThorVGSampleApp.xcodeproj
   ```

2. **Select the target**:
   - Choose `ThorVGSampleApp` scheme in Xcode
   - Select your preferred simulator or device

3. **Build and run**:
   - Press `⌘R` or click the Run button
   - The app will launch showing all examples

## For Developers

This sample app is perfect for:
- Testing changes to ThorVGSwift
- Understanding how to integrate ThorVGSwift in your own app
- Visual validation of features
- Learning the Views API

The app automatically links to the local ThorVGSwift package, so any changes you make to the Swift code in `../swift/` will be reflected when you rebuild the sample app.

## Structure

```
ThorVGSampleApp/
├── ThorVGSampleApp.xcodeproj      # Xcode project file
├── ThorVGSampleApp/
│   ├── ThorVGSampleAppApp.swift   # App entry point
│   ├── ContentView.swift          # Main navigation view
│   ├── Examples.swift             # All example views
│   └── test.json                  # Sample Lottie file
└── README.md                      # This file
```
