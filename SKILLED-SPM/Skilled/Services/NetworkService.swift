import Foundation

// Network Error Types
enum NetworkError: Error {
    case invalidURL
    case noData
    case decodingError
    case serverError(statusCode: Int, message: String?)
    case networkError(Error)
    case unauthorized
    case unknown
}

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
    case patch = "PATCH"
}

class NetworkService {
    static let shared = NetworkService()
    
    private let baseURL = "https://api.yourdomain.com/v1"
    private let tokenManager = TokenManager.shared
    
    private init() {}
    
    // MARK: - API Request Methods
    
    func request<T: Decodable>(endpoint: String,
                              method: HTTPMethod = .get,
                              parameters: [String: Any]? = nil,
                              completion: @escaping (Result<T, NetworkError>) -> Void) {
        
        guard let url = URL(string: baseURL + endpoint) else {
            completion(.failure(.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        // Add auth token to headers if available
        if let token = tokenManager.getToken() {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        // Add parameters
        if let parameters = parameters {
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: parameters)
                request.httpBody = jsonData
            } catch {
                completion(.failure(.networkError(error)))
                return
            }
        }
        
        // Create and start the request task
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(.networkError(error)))
                return
            }
            
            // Check for HTTP response
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(.unknown))
                return
            }
            
            // Handle HTTP status codes
            switch httpResponse.statusCode {
            case 200...299:
                // Success
                guard let data = data else {
                    completion(.failure(.noData))
                    return
                }
                
                do {
                    let decodedObject = try JSONDecoder().decode(T.self, from: data)
                    completion(.success(decodedObject))
                } catch {
                    print("Decoding error: \(error)")
                    completion(.failure(.decodingError))
                }
                
            case 401:
                // Unauthorized
                completion(.failure(.unauthorized))
                
            default:
                // Handle other error cases
                var errorMessage: String?
                if let data = data {
                    errorMessage = String(data: data, encoding: .utf8)
                }
                completion(.failure(.serverError(statusCode: httpResponse.statusCode, message: errorMessage)))
            }
        }
        
        task.resume()
    }
}