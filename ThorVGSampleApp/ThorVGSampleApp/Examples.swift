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
import UIKit

// MARK: - Loop Example

struct LoopExample: View {
    var body: some View {
        VStack(spacing: 20) {
            LoopAnimationView()
            
            Text("Loop Mode")
                .font(.headline)
            Text("Animation loops continuously")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .navigationTitle("Loop")
    }
}

private struct LoopAnimationView: View {
    @StateObject private var viewModel: LottieViewModel
    
    init() {
        guard let path = Bundle.main.path(forResource: "test", ofType: "json"),
              let lottie = try? Lottie(path: path) else {
            fatalError("Failed to load test Lottie")
        }
        
        let config = LottieConfiguration(loopMode: .loop, speed: 1.0)
        _viewModel = StateObject(wrappedValue: LottieViewModel(
            lottie: lottie,
            configuration: config
        ))
    }
    
    var body: some View {
        LottieView(viewModel: viewModel)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .onAppear { viewModel.play() }
    }
}

// MARK: - Play Once Example

struct PlayOnceExample: View {
    @StateObject private var viewModel: LottieViewModel
    
    init() {
        guard let path = Bundle.main.path(forResource: "test", ofType: "json"),
              let lottie = try? Lottie(path: path) else {
            fatalError("Failed to load test Lottie")
        }
        
        let config = LottieConfiguration(loopMode: .playOnce, speed: 1.0)
        _viewModel = StateObject(wrappedValue: LottieViewModel(
            lottie: lottie,
            configuration: config
        ))
    }
    
    var body: some View {
        VStack(spacing: 20) {
            LottieView(viewModel: viewModel)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            Text("Play Once")
                .font(.headline)
            Text("Animation plays once and stops")
                .font(.caption)
                .foregroundColor(.secondary)
            
            if viewModel.playbackState == .completed {
                Button("Replay") {
                    viewModel.stop()
                    viewModel.play()
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
        .navigationTitle("Play Once")
        .onAppear { viewModel.play() }
    }
}

// MARK: - Speed Example

struct SpeedExample: View {
    @StateObject private var viewModel: LottieViewModel
    let speed: Double
    
    init(speed: Double) {
        self.speed = speed
        
        guard let path = Bundle.main.path(forResource: "test", ofType: "json"),
              let lottie = try? Lottie(path: path) else {
            fatalError("Failed to load test Lottie")
        }
        
        let config = LottieConfiguration(loopMode: .loop, speed: speed)
        _viewModel = StateObject(wrappedValue: LottieViewModel(
            lottie: lottie,
            configuration: config
        ))
    }
    
    var body: some View {
        VStack(spacing: 20) {
            LottieView(viewModel: viewModel)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            Text("\(speed, specifier: "%.1f")x Speed")
                .font(.headline)
            Text(speed > 1 ? "Animation plays faster" : "Animation plays slower")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .navigationTitle("\(speed, specifier: "%.1f")x Speed")
        .onAppear { viewModel.play() }
    }
}

// MARK: - Frame Rate Example

struct FrameRateExample: View {
    @StateObject private var viewModel: LottieViewModel
    let frameRate: Double
    
    init(frameRate: Double) {
        self.frameRate = frameRate
        
        guard let path = Bundle.main.path(forResource: "test", ofType: "json"),
              let lottie = try? Lottie(path: path) else {
            fatalError("Failed to load test Lottie")
        }
        
        let config = LottieConfiguration(loopMode: .loop, speed: 1.0, frameRate: frameRate)
        _viewModel = StateObject(wrappedValue: LottieViewModel(
            lottie: lottie,
            configuration: config
        ))
    }
    
    var body: some View {
        VStack(spacing: 20) {
            LottieView(viewModel: viewModel)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            Text("\(Int(frameRate)) FPS")
                .font(.headline)
            Text("Frame rate: \(Int(frameRate)) frames per second")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .navigationTitle("\(Int(frameRate)) FPS")
        .onAppear { viewModel.play() }
    }
}

// MARK: - Manual Controls Example

struct ManualControlsExample: View {
    @StateObject private var viewModel: LottieViewModel
    
    init() {
        guard let path = Bundle.main.path(forResource: "test", ofType: "json"),
              let lottie = try? Lottie(path: path) else {
            fatalError("Failed to load test Lottie")
        }
        
        _viewModel = StateObject(wrappedValue: LottieViewModel(
            lottie: lottie,
            configuration: .default
        ))
    }
    
    var body: some View {
        VStack(spacing: 20) {
            LottieView(viewModel: viewModel)
                .frame(maxWidth: .infinity, maxHeight: 400)
            
            VStack(spacing: 16) {
                Text("State: \(stateDescription)")
                    .font(.headline)
                
                Text("Progress: \(Int(viewModel.progress * 100))%")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                HStack(spacing: 12) {
                    Button {
                        viewModel.play()
                    } label: {
                        Label("Play", systemImage: "play.fill")
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(viewModel.playbackState == .playing)
                    
                    Button {
                        viewModel.pause()
                    } label: {
                        Label("Pause", systemImage: "pause.fill")
                    }
                    .buttonStyle(.bordered)
                    .disabled(viewModel.playbackState != .playing)
                    
                    Button {
                        viewModel.stop()
                    } label: {
                        Label("Stop", systemImage: "stop.fill")
                    }
                    .buttonStyle(.bordered)
                }
            }
            .padding()
        }
        .navigationTitle("Manual Controls")
    }
    
    private var stateDescription: String {
        switch viewModel.playbackState {
        case .playing: return "Playing"
        case .paused: return "Paused"
        case .stopped: return "Stopped"
        case .completed: return "Completed"
        }
    }
}

// MARK: - Slider Seeking Example

struct SliderSeekingExample: View {
    @StateObject private var viewModel: LottieViewModel
    @State private var sliderValue: Double = 0.0
    @State private var isDragging: Bool = false
    
    init() {
        guard let path = Bundle.main.path(forResource: "test", ofType: "json"),
              let lottie = try? Lottie(path: path) else {
            fatalError("Failed to load test Lottie")
        }
        
        _viewModel = StateObject(wrappedValue: LottieViewModel(
            lottie: lottie,
            configuration: .default
        ))
    }
    
    var body: some View {
        VStack(spacing: 20) {
            LottieView(viewModel: viewModel)
                .frame(maxWidth: .infinity, maxHeight: 400)
            
            VStack(spacing: 16) {
                Slider(
                    value: $sliderValue,
                    in: 0...1,
                    onEditingChanged: { editing in
                        if editing {
                            isDragging = true
                            viewModel.pause()
                        } else {
                            isDragging = false
                        }
                    }
                )
                .onChange(of: sliderValue) { newValue in
                    if isDragging {
                        viewModel.seek(to: newValue)
                    }
                }
                
                HStack {
                    Button(viewModel.playbackState == .playing ? "Pause" : "Play") {
                        if viewModel.playbackState == .playing {
                            viewModel.pause()
                        } else {
                            viewModel.play()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    
                    Spacer()
                    
                    Text("\(Int(viewModel.progress * 100))%")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
        }
        .navigationTitle("Slider Seeking")
        .onChange(of: viewModel.progress) { newProgress in
            if !isDragging {
                sliderValue = newProgress
            }
        }
    }
}

// MARK: - Content Modes Example

struct ContentModesExample: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                ScaleAspectFillExample()
                ScaleAspectFitExample()
            }
            .padding()
        }
        .navigationTitle("Content Modes")
    }
}

private struct ScaleAspectFillExample: View {
    @StateObject private var viewModel: LottieViewModel
    
    init() {
        guard let path = Bundle.main.path(forResource: "test", ofType: "json"),
              let lottie = try? Lottie(path: path) else {
            fatalError("Failed to load test Lottie")
        }
        
        let config = LottieConfiguration(
            loopMode: .loop,
            contentMode: .scaleAspectFill
        )
        _viewModel = StateObject(wrappedValue: LottieViewModel(
            lottie: lottie,
            size: CGSize(width: 300, height: 150),
            configuration: config
        ))
    }
    
    var body: some View {
        VStack(spacing: 8) {
            Text("Scale Aspect Fill")
                .font(.headline)
            Text("Wide frame - crops top/bottom")
                .font(.caption)
                .foregroundColor(.secondary)
            LottieView(viewModel: viewModel)
                .frame(width: 300, height: 150)
                .background(Color.blue.opacity(0.1))
                .border(Color.blue, width: 2)
                .onAppear {
                    viewModel.play()
                }
        }
    }
}

private struct ScaleAspectFitExample: View {
    @StateObject private var viewModel: LottieViewModel
    
    init() {
        guard let path = Bundle.main.path(forResource: "test", ofType: "json"),
              let lottie = try? Lottie(path: path) else {
            fatalError("Failed to load test Lottie")
        }
        
        let config = LottieConfiguration(
            loopMode: .loop,
            contentMode: .scaleAspectFit
        )
        _viewModel = StateObject(wrappedValue: LottieViewModel(
            lottie: lottie,
            size: CGSize(width: 250, height: 250),
            configuration: config
        ))
    }
    
    var body: some View {
        VStack(spacing: 8) {
            Text("Scale Aspect Fit")
                .font(.headline)
            Text("Square frame - shows full animation")
                .font(.caption)
                .foregroundColor(.secondary)
            LottieView(viewModel: viewModel)
                .frame(width: 250, height: 250)
                .background(Color.green.opacity(0.1))
                .border(Color.green, width: 2)
                .onAppear {
                    viewModel.play()
                }
        }
    }
}

// MARK: - UIKit View Example

struct UIKitViewExample: View {
    @StateObject private var viewModel: LottieViewModel
    @State private var progressText: String = "0%"
    @State private var stateText: String = "Stopped"
    
    init() {
        guard let path = Bundle.main.path(forResource: "test", ofType: "json"),
              let lottie = try? Lottie(path: path) else {
            fatalError("Failed to load test Lottie")
        }
        
        let config = LottieConfiguration(loopMode: .loop, speed: 1.0)
        _viewModel = StateObject(wrappedValue: LottieViewModel(
            lottie: lottie,
            configuration: config
        ))
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Text("LottieUIKitView in SwiftUI")
                .font(.headline)
            
            Text("Demonstrates UIKit integration using UIViewRepresentable")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            // UIKit view wrapped in SwiftUI
            LottieUIKitViewWrapper(viewModel: viewModel)
                .frame(maxWidth: .infinity)
                .frame(height: 300)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
            
            VStack(spacing: 12) {
                HStack(spacing: 16) {
                    Button(action: { viewModel.play() }) {
                        Label("Play", systemImage: "play.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    
                    Button(action: { viewModel.pause() }) {
                        Label("Pause", systemImage: "pause.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    
                    Button(action: { viewModel.stop() }) {
                        Label("Stop", systemImage: "stop.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                }
                
                VStack(spacing: 8) {
                    HStack {
                        Text("State:")
                            .fontWeight(.medium)
                        Text(stateText)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                    
                    HStack {
                        Text("Progress:")
                            .fontWeight(.medium)
                        Text(progressText)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                }
                .padding()
                .background(Color.secondary.opacity(0.1))
                .cornerRadius(8)
            }
            
            Spacer()
        }
        .padding()
        .navigationTitle("UIKit View")
        .onChange(of: viewModel.playbackState) { newState in
            stateText = "\(newState)"
        }
        .onChange(of: viewModel.progress) { newProgress in
            progressText = "\(Int(newProgress * 100))%"
        }
    }
}

// MARK: - UIViewRepresentable Wrapper

struct LottieUIKitViewWrapper: UIViewRepresentable {
    let viewModel: LottieViewModel
    
    func makeUIView(context: Context) -> LottieUIKitView {
        let view = LottieUIKitView(viewModel: viewModel)
        view.contentMode = .scaleAspectFit
        return view
    }
    
    func updateUIView(_ uiView: LottieUIKitView, context: Context) {
        // Updates are handled by the view model
    }
}

