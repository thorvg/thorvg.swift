import SwiftUI

/// TODO: ....
@available(iOS 14.0, *)
public struct LottieView: View {

    @StateObject private var viewModel: LottieViewModel

    // TODO: Later feature - be dynamic with size.

    /// TODO: ....
    public init(lottie: Lottie, size: CGSize? = nil) {
        let viewModel = LottieViewModel(
            lottie: lottie,
            size: size ?? lottie.size
        )
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    @ViewBuilder private func content() -> some View {
        if let image = viewModel.renderedFrame {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
        } else {
            Color.clear
        }
    }

    /// TODO: ....
    public var body: some View {
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
    // TODO: Does this have to live in resources?
    if let path = Bundle.module.path(forResource: "test", ofType: "json"),
       let lottie = try? Lottie(path: path) {

        if #available(iOS 14.0, *) {
            LottieView(lottie: lottie)
        } else {
            Text("Unsupported iOS Version.")
        }
    } else {
        Text("Failed to load Lottie file.")
    }
}
