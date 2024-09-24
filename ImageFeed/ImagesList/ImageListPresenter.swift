import Foundation

protocol ImagesListViewPresenterProtocol {
    var photos: [Photos] { get set }
    var view: ImagesListViewControllerProtocol? { get set }
    func changeLike(for indexPath: IndexPath, completion: @escaping (Result<Void, Error>) -> Void)
    func configureCell(for indexPath: IndexPath) -> (imageURL: URL?, formattedDate: String, isLiked: Bool)
    func willDisplayCell(at indexPath: IndexPath)
    func viewDidLoad()
    func checkForUpdates()
    func getNewIndexPaths() -> [IndexPath]?
}

final class ImagesListViewPresenter: ImagesListViewPresenterProtocol {
    
    var view: ImagesListViewControllerProtocol?
    private var photosImagesListServiceObserver: NSObjectProtocol?
    private var newIndexPaths: [IndexPath]?
    var photos: [Photos] = []
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()
    
    init(view: ImagesListViewControllerProtocol) {
        self.view = view
    }
    
    func changeLike(for indexPath: IndexPath, completion: @escaping (Result<Void, Error>) -> Void) {
        let photo = photos[indexPath.row]
        let newIsLiked = photo.isLiked
        
        ImagesListService.shared.changeLikePhoto(photoId: photo.id, isLike: newIsLiked) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                self.photos[indexPath.row].isLiked = newIsLiked
                self.photos = ImagesListService.shared.photos
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func configureCell(for indexPath: IndexPath) -> (imageURL: URL?, formattedDate: String, isLiked: Bool) {
        let photo = photos[indexPath.row]
        let imageURL = URL(string: photo.thumbImageURL)
        
        let formattedDate = photo.createdAt.map { dateFormatter.string(from: $0) } ?? "Дата неизвестна"
        
        return (imageURL: imageURL, formattedDate: formattedDate, isLiked: photo.isLiked)
    }
    
    func willDisplayCell(at indexPath: IndexPath) {
        if indexPath.row == photos.count - 1 {
            ImagesListService.shared.fetchPhotosNextPage()
        }
    }
    
    func viewDidLoad() {
        ImagesListService.shared.fetchPhotosNextPage()
        addObserver()
        checkForUpdates()
    }
    func addObserver() {
        photosImagesListServiceObserver = NotificationCenter.default.addObserver(
            forName: .didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.checkForUpdates()
        }
    }
    
    func checkForUpdates() {
        let oldCount = photos.count
        let newPhotos = ImagesListService.shared.photos
        let newCount = newPhotos.count
        
        if oldCount != newCount {
            photos = newPhotos
            newIndexPaths = (oldCount..<newCount).map { IndexPath(row: $0, section: 0) }
            view?.updateTableViewAnimated()
        } else {
            newIndexPaths = nil
        }
    }
    
    func getNewIndexPaths() -> [IndexPath]? {
        return newIndexPaths
    }
    
    
}
