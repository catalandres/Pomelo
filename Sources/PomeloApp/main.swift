import ArgumentParser
import Foundation
import PomeloKit

@main
struct Pomelo: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "pomelo",
        abstract: "A command-line tool for Salesforce operations",
        discussion: """
        Pomelo provides tools for:
        - Set algebra operations on permission sets, permission set groups, and profiles
        - Data loading operations (like Salesforce Data Loader)
        - Managing Salesforce CLI authentication credentials
        """,
        version: "0.1.0",
        subcommands: [
            Query.self,
            Auth.self,
            PermissionSet.self,
        ],
        defaultSubcommand: nil
    )
}

// MARK: - Query Command

extension Pomelo {
    struct Query: AsyncParsableCommand {
        static let configuration = CommandConfiguration(
            abstract: "Execute SOQL queries"
        )
        
        @Option(name: .shortAndLong, help: "Instance URL")
        var instanceURL: String
        
        @Option(name: .shortAndLong, help: "Access token")
        var token: String
        
        @Argument(help: "SOQL query to execute")
        var query: String
        
        @Flag(name: .long, help: "Pretty print JSON output")
        var prettyPrint = false
        
        func run() async throws {
            let credentials = SalesforceCredentials(
                instanceURL: instanceURL,
                accessToken: token
            )
            
            let client = SalesforceClient(credentials: credentials)
            
            let result = try await client.query(query)
            
            if prettyPrint {
                if let json = try? JSONSerialization.jsonObject(with: result),
                   let prettyData = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted),
                   let prettyString = String(data: prettyData, encoding: .utf8) {
                    print(prettyString)
                } else {
                    print(String(data: result, encoding: .utf8) ?? "")
                }
            } else {
                print(String(data: result, encoding: .utf8) ?? "")
            }
        }
    }
}

// MARK: - Auth Command

extension Pomelo {
    struct Auth: AsyncParsableCommand {
        static let configuration = CommandConfiguration(
            abstract: "Manage Salesforce authentication",
            subcommands: [
                Info.self,
            ]
        )
        
        struct Info: AsyncParsableCommand {
            static let configuration = CommandConfiguration(
                abstract: "Display authentication information"
            )
            
            @Option(name: .shortAndLong, help: "Instance URL")
            var instanceURL: String
            
            @Option(name: .shortAndLong, help: "Access token")
            var token: String
            
            func run() async throws {
                let credentials = SalesforceCredentials(
                    instanceURL: instanceURL,
                    accessToken: token
                )
                
                let client = SalesforceClient(credentials: credentials)
                
                let versionsData = try await client.getVersions()
                let limitsData = try await client.getLimits()
                
                print("Authentication successful!")
                print("\nInstance URL: \(instanceURL)")
                print("\nAvailable API Versions:")
                if let versions = try? JSONSerialization.jsonObject(with: versionsData) as? [[String: Any]] {
                    for version in versions.suffix(5) {
                        if let label = version["label"] as? String,
                           let versionNum = version["version"] as? String {
                            print("  - \(label) (v\(versionNum))")
                        }
                    }
                }
                
                print("\nOrg Limits:")
                if let limits = try? JSONSerialization.jsonObject(with: limitsData) as? [String: Any] {
                    if let dailyApiRequests = limits["DailyApiRequests"] as? [String: Any],
                       let max = dailyApiRequests["Max"] as? Int,
                       let remaining = dailyApiRequests["Remaining"] as? Int {
                        print("  - Daily API Requests: \(remaining)/\(max)")
                    }
                }
            }
        }
    }
}

// MARK: - Permission Set Command

extension Pomelo {
    struct PermissionSet: AsyncParsableCommand {
        static let configuration = CommandConfiguration(
            abstract: "Manage permission sets and permission set groups",
            subcommands: [
                List.self,
            ]
        )
        
        struct List: AsyncParsableCommand {
            static let configuration = CommandConfiguration(
                abstract: "List permission sets or permission set groups"
            )
            
            @Option(name: .shortAndLong, help: "Instance URL")
            var instanceURL: String
            
            @Option(name: .shortAndLong, help: "Access token")
            var token: String
            
            @Option(help: "Type to list: permissionset or permissionsetgroup")
            var type: String = "permissionset"
            
            @Flag(name: .long, help: "Pretty print JSON output")
            var prettyPrint = false
            
            func run() async throws {
                let credentials = SalesforceCredentials(
                    instanceURL: instanceURL,
                    accessToken: token
                )
                
                let client = SalesforceClient(credentials: credentials)
                
                let result: Data
                switch type.lowercased() {
                case "permissionsetgroup", "psg":
                    result = try await client.queryPermissionSetGroups()
                default:
                    result = try await client.queryPermissionSets()
                }
                
                if prettyPrint {
                    if let json = try? JSONSerialization.jsonObject(with: result),
                       let prettyData = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted),
                       let prettyString = String(data: prettyData, encoding: .utf8) {
                        print(prettyString)
                    } else {
                        print(String(data: result, encoding: .utf8) ?? "")
                    }
                } else {
                    print(String(data: result, encoding: .utf8) ?? "")
                }
            }
        }
    }
}
