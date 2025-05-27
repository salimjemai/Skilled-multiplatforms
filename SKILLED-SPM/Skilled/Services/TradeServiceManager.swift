import Foundation

// MARK: - Trade Service Manager
class TradeServiceManager {
    static let shared = TradeServiceManager()
    
    private init() {}
    
    // MARK: - Trade Service Operations
    
    func fetchTradeServices(category: String? = nil, completion: @escaping (Result<[[String: Any]], Error>) -> Void) {
        // Return mock data for now since we have Firebase import issues
        let mockData = createMockServices()
        completion(.success(mockData))
    }
    
    func fetchServiceDetails(serviceId: String, completion: @escaping (Result<[String: Any], Error>) -> Void) {
        // Use mock data service to find a specific service
        let mockData = createMockServices()
        let service = mockData.first(where: { ($0["id"] as? String) == serviceId })
        
        if let service = service {
            completion(.success(service))
        } else {
            completion(.failure(NSError(domain: "com.skilled.error", code: 404, userInfo: [NSLocalizedDescriptionKey: "Service not found"])))
        }
    }
    
    func createService(service: [String: Any], completion: @escaping (Result<[String: Any], Error>) -> Void) {
        guard let currentUserId = AuthService.shared.getCurrentUserId() else {
            completion(.failure(NSError(domain: "com.skilled.error", 
                                      code: 401, 
                                      userInfo: [NSLocalizedDescriptionKey: "User must be logged in to create services"])))
            return
        }
        
        // Create a new service with the provider ID
        var newService = service
        if (newService["id"] as? String)?.isEmpty ?? true {
            newService["id"] = UUID().uuidString
        }
        newService["providerId"] = currentUserId
        newService["createdAt"] = Date()
        newService["updatedAt"] = Date()
        
        // Mock successful save
        completion(.success(newService))
    }
    
    func updateService(service: [String: Any], completion: @escaping (Result<[String: Any], Error>) -> Void) {
        guard let currentUserId = AuthService.shared.getCurrentUserId() else {
            completion(.failure(NSError(domain: "com.skilled.error", 
                                      code: 401, 
                                      userInfo: [NSLocalizedDescriptionKey: "User must be logged in to update services"])))
            return
        }
        
        // Check that the service belongs to the current provider
        guard let providerId = service["providerId"] as? String, providerId == currentUserId else {
            completion(.failure(NSError(domain: "com.skilled.error", 
                                      code: 403, 
                                      userInfo: [NSLocalizedDescriptionKey: "You can only update your own services"])))
            return
        }
        
        // Update the service timestamps
        var updatedService = service
        updatedService["updatedAt"] = Date()
        
        // Mock successful save
        completion(.success(updatedService))
    }
    
    func deleteService(serviceId: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        guard let currentUserId = AuthService.shared.getCurrentUserId() else {
            completion(.failure(NSError(domain: "com.skilled.error", 
                                      code: 401, 
                                      userInfo: [NSLocalizedDescriptionKey: "User must be logged in to delete services"])))
            return
        }
        
        // Mock successful delete
        completion(.success(true))
    }
    
    // MARK: - Helper Methods
    
    // Helper to create mock data
    private func createMockServices() -> [[String: Any]] {
        let dateFormatter = ISO8601DateFormatter()
        let now = dateFormatter.string(from: Date())
        
        return [
            [
                "id": "1",
                "name": "Pipe Repair",
                "description": "Fix leaking pipes and drains",
                "providerId": "provider1",
                "category": "plumbing",
                "pricing": [
                    "pricingType": "hourly",
                    "basePrice": 120,
                    "hourlyRate": 120,
                    "minimumFee": 120
                ] as [String: Any],
                "estimatedDuration": 60,
                "isActive": true,
                "createdAt": now,
                "updatedAt": now
            ],
            
            [
                "id": "2",
                "name": "Electrical Wiring",
                "description": "Installation and repair of electrical systems",
                "providerId": "provider2",
                "category": "electrical",
                "pricing": [
                    "pricingType": "hourly",
                    "basePrice": 150,
                    "hourlyRate": 150,
                    "minimumFee": 150
                ] as [String: Any],
                "estimatedDuration": 90,
                "isActive": true,
                "createdAt": now,
                "updatedAt": now
            ],
            
            [
                "id": "3",
                "name": "Room Painting",
                "description": "Interior and exterior painting services",
                "providerId": "provider3",
                "category": "painting",
                "pricing": [
                    "pricingType": "flat",
                    "basePrice": 300,
                    "minimumFee": 300
                ] as [String: Any],
                "estimatedDuration": 180,
                "isActive": true,
                "createdAt": now,
                "updatedAt": now
            ]
        ]
    }
}