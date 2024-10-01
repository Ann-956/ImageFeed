import Foundation

protocol ImagesListServiceProtocol {
    var photos: [Photos] { get }
    func fetchPhotosNextPage()
    func changeLikePhoto(photoId: String, isLike: Bool, completion: @escaping (Result<Void, Error>) -> Void)
}

final class ImagesListService: ImagesListServiceProtocol {
    static let shared = ImagesListService()
    private let tokenStorage = OAuth2TokenStorage()
    var photos: [Photos] = []
    private var task: URLSessionTask?
    private let urlSession = URLSession.shared
    private var lastLoadedPage: Int?
    private init() {}
    
    func clearImages() {
        photos.removeAll()
    }
    
    private func makeImagesListRequest(page: Int) -> URLRequest? {
        guard
            let url = URL(string: "https://api.unsplash.com/photos?page=\(page)&per_page=10"),
            let token = tokenStorage.token
        else {
            assertionFailure("Failed to create URL")
            return nil
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
    
    func fetchPhotosNextPage() {
        if let task = task, task.state == .running {
            return
        }
        
        let nextPage = (lastLoadedPage ?? 0) + 1
        guard
            let request = makeImagesListRequest(page: nextPage)
        else {
            print("[ImagesListService]: Ошибка создания запроса")
            return
        }
        
        task = urlSession.objectTask(for: request) { [weak self] (result: Result<[PhotosResult], Error>) in
            guard let self = self else { return }
            
            switch result {
            case.success(let photosResults):
                let newPhotos = photosResults.map { Photos(from: $0) }
                self.photos.append(contentsOf: newPhotos)
                self.lastLoadedPage = nextPage
                NotificationCenter.default.post(
                    name: .didChangeNotification,
                    object: self,
                    userInfo: ["Array": newPhotos]
                )
            case.failure(let error):
                print("[ImagesListService]: \(error.localizedDescription)")
            }
        }
        task?.resume()
    }
    
    func makeChangeLikePhotoRequest(photoId: String, isLike: Bool) -> URLRequest? {
        guard
            let url = URL(string: "https://api.unsplash.com/photos/\(photoId)/like"),
            let token = tokenStorage.token
        else {
            assertionFailure("Failed to create URL")
            return nil
        }
        var request = URLRequest(url: url)
        request.httpMethod = isLike ? "DELETE" : "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
    
    func changeLikePhoto(photoId: String, isLike: Bool, completion: @escaping(Result<Void, Error>) -> Void) {
        guard let request = makeChangeLikePhotoRequest(photoId: photoId, isLike: isLike) else {
            completion(.failure(AuthServiceError.invalidRequest))
            return
        }
        
        task = urlSession.objectTask(for: request) { [weak self] (result: Result<PhotoResponse, Error>) in
            guard let self = self else { return }
            
            switch result {
            case .success(let photoResponse):
                
                let photoResult = photoResponse.photo
                if let index = self.photos.firstIndex(where: { $0.id == photoId }) {
                    var updatedPhoto = self.photos[index]
                    updatedPhoto.isLiked = photoResult.likedByUser
                    self.photos[index] = updatedPhoto
                }
                completion(.success(()))
            case .failure(let error):
                print("[ImagesListService]: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
        task?.resume()
    }
    
}

extension Notification.Name {
    static let didChangeNotification = Notification.Name("ImagesListServiceDidChange")
}
