/*
 * Copyright (c) 2025 - 2026 ThorVG project. All rights reserved.

 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:

 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.

 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

import SwiftUI
import ThorVGSwift

struct ContentView: View {
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Playback Modes")) {
                    NavigationLink("Loop Mode", destination: LoopExample())
                    NavigationLink("Play Once", destination: PlayOnceExample())
                }
                
                Section(header: Text("Speed Control")) {
                    NavigationLink("2x Speed", destination: SpeedExample(speed: 2.0))
                    NavigationLink("0.5x Speed", destination: SpeedExample(speed: 0.5))
                }
                
                Section(header: Text("Frame Rate")) {
                    NavigationLink("60 FPS", destination: FrameRateExample(frameRate: 60.0))
                    NavigationLink("30 FPS (Default)", destination: FrameRateExample(frameRate: 30.0))
                }
                
                Section(header: Text("Interactive")) {
                    NavigationLink("Manual Controls", destination: ManualControlsExample())
                    NavigationLink("Slider Seeking", destination: SliderSeekingExample())
                }
                
                Section(header: Text("Layout")) {
                    NavigationLink("Content Modes", destination: ContentModesExample())
                }
                
                Section(header: Text("UIKit Integration")) {
                    NavigationLink("UIKit View Example", destination: UIKitViewExample())
                }
            }
            .navigationTitle("Lottie Examples")
        }
    }
}

