import Foundation

struct TradeService: Codable {
    var id: String
    var name: String
    var description: String
    var providerId: String
    var category: TradeCategory
    var pricing: ServicePricing
    var estimatedDuration: Int? // In minutes
    var imageUrls: [String]?
    var isActive: Bool
    var createdAt: Date
    var updatedAt: Date
}

struct ServicePricing: Codable {
    var pricingType: PricingType
    var basePrice: Double
    var hourlyRate: Double?
    var minimumFee: Double?
    var estimatedCostRange: CostRange?
}

struct CostRange: Codable {
    var minimum: Double
    var maximum: Double
}

enum PricingType: String, Codable {
    case flat
    case hourly
    case estimate
}

enum TradeCategory: String, Codable, CaseIterable {
    case plumbing
    case electrical
    case carpentry
    case painting
    case landscaping
    case roofing
    case hvac
    case cleaning
    case handyman
    case masonry
    case flooring
    case moving
    case pest
    case appliance
    case other
    
    var displayName: String {
        switch self {
        case .hvac:
            return "HVAC"
        case .pest:
            return "Pest Control"
        default:
            // Capitalize first letter and use raw value
            let firstChar = self.rawValue.prefix(1).uppercased()
            let remainingChars = self.rawValue.dropFirst()
            return firstChar + remainingChars
        }
    }
    
    var iconName: String {
        switch self {
        case .plumbing:
            return "drop.fill"
        case .electrical:
            return "bolt.fill"
        case .carpentry:
            return "hammer.fill"
        case .painting:
            return "paintbrush.fill"
        case .landscaping:
            return "leaf.fill"
        case .roofing:
            return "house.fill"
        case .hvac:
            return "thermometer.sun.fill"
        case .cleaning:
            return "sparkles"
        case .handyman:
            return "wrench.fill"
        case .masonry:
            return "brick.fill"
        case .flooring:
            return "square.grid.3x3.fill"
        case .moving:
            return "shippingbox.fill"
        case .pest:
            return "ant.fill"
        case .appliance:
            return "refrigerator.fill"
        case .other:
            return "ellipsis.circle.fill"
        }
    }
}