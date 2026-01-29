import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/// High-level client for interacting with Salesforce APIs
public actor SalesforceClient {
    private let httpClient: SalesforceHTTPClient
    public let apiVersion: String
    
    public init(credentials: SalesforceCredentials? = nil, apiVersion: String = "v59.0") {
        self.httpClient = SalesforceHTTPClient(credentials: credentials)
        self.apiVersion = apiVersion
    }
    
    /// Set authentication credentials
    public func setCredentials(_ credentials: SalesforceCredentials) async {
        await httpClient.setCredentials(credentials)
    }
    
    /// Get current credentials
    public func getCredentials() async -> SalesforceCredentials? {
        return await httpClient.getCredentials()
    }
    
    // MARK: - Query Operations
    
    /// Execute a SOQL query
    public func query(_ soql: String) async throws -> Data {
        let encodedQuery = soql.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? soql
        return try await httpClient.get(path: "/services/data/\(apiVersion)/query", queryParams: ["q": encodedQuery])
    }
    
    /// Execute a SOQL query and decode the result
    public func query<T: Decodable>(_ soql: String, as type: T.Type) async throws -> T {
        let data = try await query(soql)
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw SalesforceError.decodingError(error.localizedDescription)
        }
    }
    
    // MARK: - Metadata Operations
    
    /// Describe global metadata
    public func describeGlobal() async throws -> Data {
        return try await httpClient.get(path: "/services/data/\(apiVersion)/sobjects")
    }
    
    /// Describe a specific SObject
    public func describeSObject(_ objectName: String) async throws -> Data {
        return try await httpClient.get(path: "/services/data/\(apiVersion)/sobjects/\(objectName)/describe")
    }
    
    // MARK: - CRUD Operations
    
    /// Create a new record
    public func createRecord(objectName: String, fields: [String: Any]) async throws -> Data {
        let jsonData = try JSONSerialization.data(withJSONObject: fields)
        return try await httpClient.post(path: "/services/data/\(apiVersion)/sobjects/\(objectName)", body: jsonData)
    }
    
    /// Get a record by ID
    public func getRecord(objectName: String, id: String, fields: [String]? = nil) async throws -> Data {
        var path = "/services/data/\(apiVersion)/sobjects/\(objectName)/\(id)"
        if let fields = fields, !fields.isEmpty {
            let fieldsParam = fields.joined(separator: ",")
            path += "?fields=\(fieldsParam)"
        }
        return try await httpClient.get(path: path)
    }
    
    /// Update a record
    public func updateRecord(objectName: String, id: String, fields: [String: Any]) async throws {
        let jsonData = try JSONSerialization.data(withJSONObject: fields)
        _ = try await httpClient.patch(path: "/services/data/\(apiVersion)/sobjects/\(objectName)/\(id)", body: jsonData)
    }
    
    /// Delete a record
    public func deleteRecord(objectName: String, id: String) async throws {
        _ = try await httpClient.delete(path: "/services/data/\(apiVersion)/sobjects/\(objectName)/\(id)")
    }
    
    // MARK: - Permission Set Operations
    
    /// Query permission sets
    public func queryPermissionSets(whereClause: String? = nil) async throws -> Data {
        var soql = "SELECT Id, Name, Label, Description FROM PermissionSet"
        if let whereClause = whereClause {
            soql += " WHERE \(whereClause)"
        }
        return try await query(soql)
    }
    
    /// Query permission set groups
    public func queryPermissionSetGroups(whereClause: String? = nil) async throws -> Data {
        var soql = "SELECT Id, DeveloperName, MasterLabel, Description FROM PermissionSetGroup"
        if let whereClause = whereClause {
            soql += " WHERE \(whereClause)"
        }
        return try await query(soql)
    }
    
    /// Query profiles
    public func queryProfiles(whereClause: String? = nil) async throws -> Data {
        var soql = "SELECT Id, Name, Description FROM Profile"
        if let whereClause = whereClause {
            soql += " WHERE \(whereClause)"
        }
        return try await query(soql)
    }
    
    // MARK: - Utility Methods
    
    /// Get API versions
    public func getVersions() async throws -> Data {
        return try await httpClient.get(path: "/services/data")
    }
    
    /// Get limits
    public func getLimits() async throws -> Data {
        return try await httpClient.get(path: "/services/data/\(apiVersion)/limits")
    }
}
