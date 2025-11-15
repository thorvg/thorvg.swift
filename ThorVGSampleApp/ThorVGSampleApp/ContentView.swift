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

