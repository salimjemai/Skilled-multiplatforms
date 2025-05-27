import Foundation
import Firebase
import FirebaseStorage

class StorageService {
    
    // MARK: - Shared Instance
    static let shared = StorageService()
    
    // MARK: - Properties
    private let storage = Storage.storage()
    
    // MARK: - Initialization
    private init() {}
    
    // MARK: - Upload Methods
    
    /// Upload image data to Firebase Storage
    /// - Parameters:
    ///   - imageData: The image data to upload
    ///   - path: The path in storage where the image should be stored
    ///   - completion: Callback with URL string or error
    func uploadImage(_ imageData: Data, path: String, completion: @escaping (Result<String, Error>) -> Void) {
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpeg"
        
        let storageRef = storage.reference().child(path)
        
        storageRef.putData(imageData, metadata: metaData) { (_, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            storageRef.downloadURL { (url, error) in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let downloadURL = url else {
                    completion(.failure(NSError(domain: "StorageService", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to get download URL"])))
                    return
                }
                
                completion(.success(downloadURL.absoluteString))
            }
        }
    }
    
    /// Upload profile image for a user
    /// - Parameters:
    ///   - imageData: The image data to upload
    ///   - userId: The ID of the user
    ///   - completion: Callback with URL string or error
    func uploadProfileImage(_ imageData: Data, userId: String, completion: @escaping (Result<String, Error>) -> Void) {
        let path = "profile_images/\(userId)_\(Date().timeIntervalSince1970).jpg"
        uploadImage(imageData, path: path, completion: completion)
    }
    
    /// Upload service image
    /// - Parameters:
    ///   - imageData: The image data to upload
    ///   - serviceId: The ID of the service
    ///   - completion: Callback with URL string or error
    func uploadServiceImage(_ imageData: Data, serviceId: String, completion: @escaping (Result<String, Error>) -> Void) {
        let path = "service_images/\(serviceId)_\(Date().timeIntervalSince1970).jpg"
        uploadImage(imageData, path: path, completion: completion)
    }
    
    // MARK: - Delete Methods
    
    /// Delete image from Firebase Storage
    /// - Parameters:
    ///   - urlString: The URL string of the image to delete
    ///   - completion: Callback with optional error
    func deleteImage(urlString: String, completion: @escaping (Error?) -> Void) {
        guard let url = URL(string: urlString),
              url.host == "firebasestorage.googleapis.com" else {
            completion(NSError(domain: "StorageService", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid storage URL"]))
            return
        }
        
        // Extract the path from the URL
        if let fullPath = url.path.components(separatedBy: "/o/").last,
           let path = fullPath.removingPercentEncoding {
            
            let storageRef = storage.reference().child(path)
            storageRef.delete { error in
                completion(error)
            }
        } else {
            completion(NSError(domain: "StorageService", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to parse storage path"]))
        }
    }
}
