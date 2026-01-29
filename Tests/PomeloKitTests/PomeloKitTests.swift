import XCTest
@testable import PomeloKit

final class PomeloKitTests: XCTestCase {
    
    // MARK: - Model Tests
    
    func testSalesforceCredentialsInitialization() {
        let credentials = SalesforceCredentials(
            instanceURL: "https://example.salesforce.com",
            accessToken: "test-token",
            refreshToken: "test-refresh-token"
        )
        
        XCTAssertEqual(credentials.instanceURL, "https://example.salesforce.com")
        XCTAssertEqual(credentials.accessToken, "test-token")
        XCTAssertEqual(credentials.refreshToken, "test-refresh-token")
    }
    
    func testSalesforceOAuthConfigInitialization() {
        let config = SalesforceOAuthConfig(
            clientId: "test-client-id",
            clientSecret: "test-client-secret"
        )
        
        XCTAssertEqual(config.clientId, "test-client-id")
        XCTAssertEqual(config.clientSecret, "test-client-secret")
        XCTAssertEqual(config.loginURL, "https://login.salesforce.com")
        XCTAssertEqual(config.redirectURI, "http://localhost:8080/callback")
    }
    
    func testSalesforceErrorDescription() {
        let invalidURLError = SalesforceError.invalidURL("bad-url")
        XCTAssertEqual(invalidURLError.description, "Invalid URL: bad-url")
        
        let authError = SalesforceError.authenticationFailed("Invalid token")
        XCTAssertEqual(authError.description, "Authentication failed: Invalid token")
        
        let apiError = SalesforceError.apiError(code: "INVALID_FIELD", message: "Field does not exist")
        XCTAssertEqual(apiError.description, "Salesforce API error [INVALID_FIELD]: Field does not exist")
    }
    
    // MARK: - Client Tests
    
    func testClientInitialization() async {
        let credentials = SalesforceCredentials(
            instanceURL: "https://example.salesforce.com",
            accessToken: "test-token"
        )
        
        let client = SalesforceClient(credentials: credentials)
        let retrievedCredentials = await client.getCredentials()
        
        XCTAssertNotNil(retrievedCredentials)
        XCTAssertEqual(retrievedCredentials?.instanceURL, "https://example.salesforce.com")
        XCTAssertEqual(retrievedCredentials?.accessToken, "test-token")
    }
    
    func testClientWithoutCredentials() async {
        let client = SalesforceClient()
        let credentials = await client.getCredentials()
        
        XCTAssertNil(credentials)
    }
    
    func testSetCredentials() async {
        let client = SalesforceClient()
        
        let credentials = SalesforceCredentials(
            instanceURL: "https://test.salesforce.com",
            accessToken: "new-token"
        )
        
        await client.setCredentials(credentials)
        let retrievedCredentials = await client.getCredentials()
        
        XCTAssertNotNil(retrievedCredentials)
        XCTAssertEqual(retrievedCredentials?.instanceURL, "https://test.salesforce.com")
        XCTAssertEqual(retrievedCredentials?.accessToken, "new-token")
    }
    
    func testHTTPClientInitialization() async {
        let credentials = SalesforceCredentials(
            instanceURL: "https://example.salesforce.com",
            accessToken: "test-token"
        )
        
        let httpClient = SalesforceHTTPClient(credentials: credentials)
        let retrievedCredentials = await httpClient.getCredentials()
        
        XCTAssertNotNil(retrievedCredentials)
        XCTAssertEqual(retrievedCredentials?.instanceURL, "https://example.salesforce.com")
    }
}
