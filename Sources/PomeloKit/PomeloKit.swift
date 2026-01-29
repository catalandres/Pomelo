// PomeloKit - Salesforce API Client Library
//
// This library provides tools for interacting with Salesforce APIs:
// - SalesforceClient: High-level client for Salesforce operations
// - SalesforceHTTPClient: Low-level HTTP client using SwiftNIO
// - Models for authentication, errors, and data structures

// Re-export public types
@_exported import struct Foundation.Data
@_exported import struct Foundation.URL

// Client
public typealias Client = SalesforceClient
public typealias HTTPClient = SalesforceHTTPClient

// Models
public typealias Credentials = SalesforceCredentials
public typealias OAuthConfig = SalesforceOAuthConfig
public typealias OAuthResponse = SalesforceOAuthResponse
// Note: Use SalesforceError directly, not aliased to avoid conflict with Swift.Error
public typealias APIError = SalesforceAPIError
