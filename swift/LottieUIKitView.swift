import UIKit
import Combine

/// TODO: ....
public class LottieUIKitView: UIView {
    private let imageView: UIImageView
    private var viewModel: LottieViewModel
    private var cancellables = Set<AnyCancellable>()

    /// TODO: ....
    public init(lottie: Lottie) {
        self.viewModel = LottieViewModel(lottie: lottie, size: lottie.getSize())
        self.imageView = UIImageView()
        super.init(frame: .zero)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        imageView.contentMode = .scaleAspectFit
        addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }

    /// TODO: ....
    public func startAnimating() {
        viewModel.startAnimating()
        viewModel.$renderedFrame
            .sink { [weak self] image in
                self?.imageView.image = image
            }
            .store(in: &cancellables)
    }

    /// TODO: ....
    public func stopAnimating() {
        viewModel.stopAnimating()
    }
}
