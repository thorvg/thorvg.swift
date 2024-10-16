import SwiftUI

@available(iOS 14.0, *)
struct LottieView: View {

    @StateObject private var viewModel: LottieViewModel

    init(lottie: Lottie) {
        let viewModel = LottieViewModel(
            lottie: lottie,
            size: CGSize(width: 500, height: 500),
            frameRate: 30.0
        )
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    @ViewBuilder func content() -> some View {
        if let image = viewModel.renderedFrame {
            Image(uiImage: image)
        } else {
            Color.clear
        }
    }

    var body: some View {
        content()
        .onAppear {
            viewModel.startAnimating()
        }
        .onDisappear {
            viewModel.stopAnimating()
        }
    }
}

#Preview {
    // Load the test.json file from the bundle
    if let path = Bundle.module.path(forResource: "test", ofType: "json"),
       let lottie = try? Lottie(path: path) {

        if #available(iOS 14.0, *) {
            LottieView(lottie: lottie)
        } else {
            Text(":")
            // Fallback on earlier versions
        }
    } else {
        Text("Failed to load Lottie file.")
    }
}
