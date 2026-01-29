import Foundation

/// Errors that can occur during Salesforce API operations
public enum SalesforceError: Error, CustomStringConvertible {
    case invalidURL(String)
    case authenticationFailed(String)
    case networkError(String)
    case invalidResponse(String)
    case apiError(code: String, message: String)
    case decodingError(String)
    
    public var description: String {
        switch self {
        case .invalidURL(let url):
            return "Invalid URL: \(url)"
        case .authenticationFailed(let reason):
            return "Authentication failed: \(reason)"
        case .networkError(let error):
            return "Network error: \(error)"
        case .invalidResponse(let details):
            return "Invalid response: \(details)"
        case .apiError(let code, let message):
            return "Salesforce API error [\(code)]: \(message)"
        case .decodingError(let details):
            return "Decoding error: \(details)"
        }
    }
}

/// Salesforce API error response
public struct SalesforceAPIError: Codable {
    public let message: String
    public let errorCode: String
    public let fields: [String]?
    
    enum CodingKeys: String, CodingKey {
        case message
        case errorCode
        case fields
    }
}
