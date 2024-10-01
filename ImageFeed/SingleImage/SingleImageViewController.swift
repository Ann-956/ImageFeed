import UIKit
import Kingfisher

final class SingleImageViewController: UIViewController {
    
    var image: URL? {
        didSet {
            guard isViewLoaded else { return }
            checkAndSetImage()
        }
    }
    @IBOutlet weak var navBackButton: UIButton!
    
    @IBOutlet weak var singleImage: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    
    @IBAction private func didTapBackButton() {
        dismiss(animated: true, completion: nil)
    }
    @IBAction private func didTabShareButton(_ sender: Any) {
        guard let image = singleImage.image else { return }
        
        let items: [Any] = [image]
        let activityViewController = UIActivityViewController(activityItems: items, applicationActivities: nil)
        present(activityViewController, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navBackButton.accessibilityIdentifier = "NavBackButton"
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 1.25
        scrollView.delegate = self
            
        configureCache()
        
        checkAndSetImage()
    }
    
    private func rescaleAndCenterImageInScrollView(image: UIImage) {
        let minZoomScale = scrollView.minimumZoomScale
        let maxZoomScale = scrollView.maximumZoomScale
        view.layoutIfNeeded()
        let visibleRectSize = scrollView.bounds.size
        let imageSize = image.size
        print(imageSize.width)
        let hScale = visibleRectSize.width / imageSize.width
        let vScale = visibleRectSize.height / imageSize.height
        let scale = min(maxZoomScale, max(minZoomScale, max(hScale, vScale)))
        scrollView.setZoomScale(scale, animated: false)
        scrollView.layoutIfNeeded()
        
        let newContentSize = scrollView.contentSize
        let x = (newContentSize.width - visibleRectSize.width) / 2
        let y = (newContentSize.height - visibleRectSize.height) / 2
        
        self.scrollView.setContentOffset(CGPoint(x: x, y: y), animated: true)
        
        print("зум работает")
        
    }
    
    private func centerImage() {
        let offsetX = max((scrollView.bounds.width - scrollView.contentSize.width) * 0.5, 0.0)
        let offsetY = max((scrollView.bounds.height - scrollView.contentSize.height) * 0.5, 0.0)
        
        UIView.animate(withDuration: 0.3) { [weak self] in
               guard let self = self else { return }
               self.scrollView.contentInset = UIEdgeInsets(top: offsetY, left: offsetX, bottom: 0, right: 0)
           }
    }
    
    private func configureCache() {
        let cache = ImageCache.default
        cache.memoryStorage.config.totalCostLimit = 50 * 1024 * 1024
        cache.diskStorage.config.sizeLimit = 200 * 1024 * 1024
    }
    
    
    private func showError() {
        let alertController = UIAlertController(
            title: "Ошибка",
            message: "Что-то пошло не так. Попробовать ещё раз?",
            preferredStyle: .alert
        )
        
        let cancelAction = UIAlertAction(title: "Не надо", style: .cancel, handler: nil)
        
        let retryAction = UIAlertAction(title: "Повторить", style: .default) { [weak self] _ in
            self?.checkAndSetImage()
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(retryAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    private func checkAndSetImage() {
        guard let imageURL = image else { return }
        UIBlockingProgressHUD.show()
        
        let processor = DownsamplingImageProcessor(size: CGSize(width: 1024, height: 1024))
        let options: KingfisherOptionsInfo = [
            .processor(processor),
            .scaleFactor(UIScreen.main.scale),
            .cacheOriginalImage,
            .transition(.fade(0.3))
        ]
        
        singleImage.kf.setImage(with: imageURL, options: options) { [weak self] result in
            UIBlockingProgressHUD.dismiss()
            
            guard let self = self else { return }
            switch result {
            case .success(let value):
                self.rescaleAndCenterImageInScrollView(image: value.image)
            case .failure:
                self.showError()
            }
        }
    }
    
}

extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return singleImage
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        centerImage()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            centerImage()
        }
    }
}
