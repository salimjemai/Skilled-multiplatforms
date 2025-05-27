// Common types and protocols used throughout the app
import Foundation

typealias EmptyCompletion = (Bool) -> Void
typealias ErrorCompletion = (Error?) -> Void

struct EmptyResponse: Codable {}