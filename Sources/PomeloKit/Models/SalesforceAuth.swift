import Foundation

/// Represents Salesforce authentication credentials
public struct SalesforceCredentials: Codable {
    public let instanceURL: String
    public let accessToken: String
    public let refreshToken: String?
    
    public init(instanceURL: String, accessToken: String, refreshToken: String? = nil) {
        self.instanceURL = instanceURL
        self.accessToken = accessToken
        self.refreshToken = refreshToken
    }
}

/// OAuth configuration for Salesforce
public struct SalesforceOAuthConfig: Codable {
    public let clientId: String
    public let clientSecret: String
    public let loginURL: String
    public let redirectURI: String
    
    public init(clientId: String, clientSecret: String, loginURL: String = "https://login.salesforce.com", redirectURI: String = "http://localhost:8080/callback") {
        self.clientId = clientId
        self.clientSecret = clientSecret
        self.loginURL = loginURL
        self.redirectURI = redirectURI
    }
}

/// OAuth response from Salesforce
public struct SalesforceOAuthResponse: Codable {
    public let accessToken: String
    public let refreshToken: String?
    public let instanceURL: String
    public let id: String
    public let tokenType: String
    public let issuedAt: String
    public let signature: String
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
        case instanceURL = "instance_url"
        case id
        case tokenType = "token_type"
        case issuedAt = "issued_at"
        case signature
    }
}
