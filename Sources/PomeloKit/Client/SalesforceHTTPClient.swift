import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import NIOCore
import NIOPosix
import NIOHTTP1
import NIOSSL

/// HTTP client for making requests to Salesforce APIs
public actor SalesforceHTTPClient {
    private let eventLoopGroup: MultiThreadedEventLoopGroup
    private var credentials: SalesforceCredentials?
    
    public init(credentials: SalesforceCredentials? = nil) {
        self.eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: System.coreCount)
        self.credentials = credentials
    }
    
    deinit {
        try? eventLoopGroup.syncShutdownGracefully()
    }
    
    /// Set authentication credentials
    public func setCredentials(_ credentials: SalesforceCredentials) {
        self.credentials = credentials
    }
    
    /// Get current credentials
    public func getCredentials() -> SalesforceCredentials? {
        return credentials
    }
    
    /// Make a GET request to Salesforce API
    public func get(path: String, queryParams: [String: String] = [:]) async throws -> Data {
        guard let credentials = credentials else {
            throw SalesforceError.authenticationFailed("No credentials set")
        }
        
        var urlString = "\(credentials.instanceURL)\(path)"
        if !queryParams.isEmpty {
            let queryString = queryParams.map { "\($0.key)=\($0.value)" }.joined(separator: "&")
            urlString += "?\(queryString)"
        }
        
        guard let url = URL(string: urlString) else {
            throw SalesforceError.invalidURL(urlString)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(credentials.accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        return try await performRequest(request)
    }
    
    /// Make a POST request to Salesforce API
    public func post(path: String, body: Data?) async throws -> Data {
        guard let credentials = credentials else {
            throw SalesforceError.authenticationFailed("No credentials set")
        }
        
        let urlString = "\(credentials.instanceURL)\(path)"
        guard let url = URL(string: urlString) else {
            throw SalesforceError.invalidURL(urlString)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(credentials.accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = body
        
        return try await performRequest(request)
    }
    
    /// Make a PATCH request to Salesforce API
    public func patch(path: String, body: Data?) async throws -> Data {
        guard let credentials = credentials else {
            throw SalesforceError.authenticationFailed("No credentials set")
        }
        
        let urlString = "\(credentials.instanceURL)\(path)"
        guard let url = URL(string: urlString) else {
            throw SalesforceError.invalidURL(urlString)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("Bearer \(credentials.accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = body
        
        return try await performRequest(request)
    }
    
    /// Make a DELETE request to Salesforce API
    public func delete(path: String) async throws -> Data {
        guard let credentials = credentials else {
            throw SalesforceError.authenticationFailed("No credentials set")
        }
        
        let urlString = "\(credentials.instanceURL)\(path)"
        guard let url = URL(string: urlString) else {
            throw SalesforceError.invalidURL(urlString)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("Bearer \(credentials.accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        return try await performRequest(request)
    }
    
    /// Perform the HTTP request using URLSession
    private func performRequest(_ request: URLRequest) async throws -> Data {
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw SalesforceError.invalidResponse("Not an HTTP response")
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            // Try to parse Salesforce error
            if let errorResponse = try? JSONDecoder().decode([SalesforceAPIError].self, from: data),
               let error = errorResponse.first {
                throw SalesforceError.apiError(code: error.errorCode, message: error.message)
            }
            
            let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw SalesforceError.networkError("HTTP \(httpResponse.statusCode): \(errorMessage)")
        }
        
        return data
    }
}
