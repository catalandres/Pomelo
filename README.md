# Pomelo

A Swift-based command-line tool and library for Salesforce operations on macOS.

## Features

- **Set Algebra Operations**: Perform operations on permission sets, permission set groups, and profiles
- **Data Loading**: Everything Salesforce Data Loader does
- **Auth Management**: Manage and use authentication credentials from Salesforce CLI
- **Native Swift**: Built with Swift and SwiftNIO for high performance
- **CLI & Library**: Use as a command-line tool or integrate as a Swift package

## Architecture

Pomelo is structured as two main components:

1. **PomeloKit**: A Swift library providing the Salesforce API client
2. **pomelo**: A command-line interface built with ArgumentParser

### PomeloKit Library

The library includes:

- `SalesforceClient`: High-level API client for common Salesforce operations
- `SalesforceHTTPClient`: Low-level HTTP client built on SwiftNIO
- Models for authentication, errors, and data structures
- Support for:
  - SOQL queries
  - CRUD operations (Create, Read, Update, Delete)
  - Permission set and permission set group queries
  - Metadata operations
  - Profile management

### CLI Tool

The `pomelo` command-line tool provides subcommands for:

- `query`: Execute SOQL queries
- `auth`: Manage Salesforce authentication
- `permission-set`: Work with permission sets and permission set groups

## Installation

### Prerequisites

- macOS 13.0 or later
- Swift 5.9 or later
- Xcode 15.0 or later

### Building from Source

```bash
# Clone the repository
git clone https://github.com/catalandres/Pomelo.git
cd Pomelo

# Build the project
swift build -c release

# The executable will be at .build/release/pomelo
```

## Usage

### Command-Line Tool

```bash
# Execute a SOQL query
pomelo query \
  --instance-url "https://your-instance.salesforce.com" \
  --token "your-access-token" \
  "SELECT Id, Name FROM Account LIMIT 10" \
  --pretty-print

# Get authentication info
pomelo auth info \
  --instance-url "https://your-instance.salesforce.com" \
  --token "your-access-token"

# List permission sets
pomelo permission-set list \
  --instance-url "https://your-instance.salesforce.com" \
  --token "your-access-token" \
  --type permissionset \
  --pretty-print

# Get help
pomelo --help
pomelo query --help
```

### As a Swift Package

Add Pomelo to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/catalandres/Pomelo.git", from: "0.1.0")
]
```

Then import and use it in your code:

```swift
import PomeloKit

// Create credentials
let credentials = SalesforceCredentials(
    instanceURL: "https://your-instance.salesforce.com",
    accessToken: "your-access-token"
)

// Create a client
let client = SalesforceClient(credentials: credentials)

// Execute a query
let result = try await client.query("SELECT Id, Name FROM Account LIMIT 10")

// Query permission sets
let permSets = try await client.queryPermissionSets()

// Create a record
try await client.createRecord(
    objectName: "Contact",
    fields: [
        "FirstName": "John",
        "LastName": "Doe",
        "Email": "john.doe@example.com"
    ]
)
```

## Authentication

Pomelo supports OAuth authentication with Salesforce. You'll need:

- Instance URL (e.g., `https://yourorg.salesforce.com`)
- Access Token (from Salesforce CLI or OAuth flow)
- Optionally: Refresh Token for token renewal

### Getting Credentials

You can obtain credentials using:

1. **Salesforce CLI**: Use `sf org display --verbose` to see access tokens
2. **OAuth Web Flow**: Implement OAuth flow to get tokens
3. **Connected App**: Create a Salesforce Connected App for OAuth

## Dependencies

- [SwiftNIO](https://github.com/apple/swift-nio): Async networking framework
- [SwiftNIO SSL](https://github.com/apple/swift-nio-ssl): SSL/TLS support
- [Swift Argument Parser](https://github.com/apple/swift-argument-parser): CLI argument parsing

## Development

### Running Tests

```bash
swift test
```

### Building for Development

```bash
swift build
```

### Running the CLI

```bash
swift run pomelo --help
```

## Project Structure

```
Pomelo/
├── Package.swift                 # Swift Package Manager manifest
├── Sources/
│   ├── PomeloKit/               # Library code
│   │   ├── Client/              # API clients
│   │   │   ├── SalesforceClient.swift
│   │   │   └── SalesforceHTTPClient.swift
│   │   ├── Models/              # Data models
│   │   │   ├── SalesforceAuth.swift
│   │   │   └── SalesforceError.swift
│   │   └── PomeloKit.swift      # Public interface
│   └── PomeloApp/               # CLI application
│       └── main.swift           # CLI entry point
└── Tests/
    └── PomeloKitTests/          # Unit tests
        └── PomeloKitTests.swift
```

## Roadmap

### Current Features (v0.1.0)
- ✅ Basic Salesforce API client with SwiftNIO
- ✅ CLI with ArgumentParser
- ✅ SOQL query execution
- ✅ Permission set and permission set group queries
- ✅ Basic authentication support

### Planned Features
- [ ] Set algebra operations on permission sets and profiles
- [ ] Full Data Loader functionality (bulk import/export)
- [ ] Salesforce CLI credential integration
- [ ] Metadata API support
- [ ] OAuth flow implementation
- [ ] Credential storage and management
- [ ] Profile comparison and diff tools
- [ ] Bulk API 2.0 support

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

See LICENSE file for details.