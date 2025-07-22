# Obsidian MCP Server 🧠

A Ruby-based Model Context Protocol (MCP) server for interacting with Obsidian vaults. Built with [fast-mcp](https://github.com/yjacquin/fast-mcp), this server allows AI models to search, read, and analyze your evergreen notes.

## Features

- **Search Notes**: Find notes by content, title, or tags
- **Read Individual Notes**: Get full note content including frontmatter and links
- **List All Notes**: Browse all notes with metadata
- **Tag-based Filtering**: Find notes by specific tags
- **Vault Statistics**: Get comprehensive statistics about your vault
- **Tag Cloud**: Analyze tag usage patterns

## Installation

1. Clone this repository:
```bash
git clone <repository-url>
cd obsidian-mcp-server
```

2. Install dependencies:
```bash
bundle install
```

3. Set your vault path (optional):
```bash
export OBSIDIAN_VAULT_PATH="/path/to/your/obsidian/vault"
```

## Usage

### Starting the Server

```bash
./obsidian_server.rb
```

The server will automatically discover your vault using these methods:
1. `OBSIDIAN_VAULT_PATH` environment variable
2. Default test notes in `../obsidian-test-notes/notes`
3. Other common relative paths

### Available Tools

#### 1. Search Notes
Search for notes by query text in titles, tags, or content.

#### 2. Read Note
Read the full content of a specific note by filename or title.

#### 3. List Notes
Get a list of all notes in the vault with basic metadata.

#### 4. Find by Tags
Find notes that contain specific tags with flexible matching options.

### Available Resources

#### 1. Vault Statistics
Access comprehensive statistics about your vault:
- Total notes and words
- Average words per note
- Unique tags count
- Internal and external link counts

#### 2. Tag Cloud
Get tag usage statistics and counts across your vault.

## Configuration

Set environment variables to customize the server:

- `OBSIDIAN_VAULT_PATH`: Path to your Obsidian vault
- `OBSIDIAN_MCP_SERVER_NAME`: Custom server name (default: "obsidian-vault-server")
- `OBSIDIAN_MCP_SERVER_VERSION`: Custom server version (default: "1.0.0")

## Architecture

The project follows a clean, modular architecture built on the [fast-mcp](https://github.com/yjacquin/fast-mcp) Ruby framework:

```
├── obsidian_server.rb         # Main executable server entry point
├── Gemfile                    # Dependencies (fast-mcp ~> 1.5, rspec, rubocop)
├── mise.toml                  # Development environment configuration
├── lib/                       # Main application code
│   ├── obsidian_mcp.rb        # Main module and server factory
│   └── obsidian_mcp/
│       ├── config.rb          # Environment-based configuration
│       ├── models/            # Domain models
│       │   ├── vault.rb       # Vault discovery and file operations
│       │   └── note.rb        # Note parsing and metadata extraction
│       ├── services/          # Business logic services
│       │   ├── search_service.rb  # Content and metadata search
│       │   └── stats_service.rb   # Vault statistics calculation
│       ├── base/              # Abstract base classes
│       │   ├── tool.rb        # MCP tool interface
│       │   └── resource.rb    # MCP resource interface
│       ├── tools/             # MCP tool implementations
│       │   ├── search_notes.rb    # Full-text search across notes
│       │   ├── read_note.rb       # Single note content retrieval
│       │   ├── list_notes.rb      # Vault-wide note listing
│       │   └── find_by_tags.rb    # Tag-based filtering
│       └── resources/         # MCP resource implementations
│           ├── vault_statistics.rb # Comprehensive vault metrics
│           └── tag_cloud.rb       # Tag usage analytics
└── spec/                      # Comprehensive test suite
    ├── spec_helper.rb         # RSpec configuration and setup
    ├── support/               # Test helpers and shared contexts
    │   └── test_vault_setup.rb # Comprehensive test vault fixture
    └── integration/           # Integration tests
        └── tools/             # Tool-specific integration tests
            └── list_notes_spec.rb # Complete ListNotes tool test
```

### Key Components

#### Production Code
- **Server Entry** (`obsidian_server.rb`): Executable script that initializes and starts the MCP server
- **Configuration** (`config.rb`): Manages vault discovery and environment variables
- **Models**: Domain objects representing vaults and individual notes with frontmatter parsing
- **Services**: Business logic for search operations and statistical analysis
- **Tools**: MCP tool implementations providing interactive capabilities
- **Resources**: MCP resource implementations providing read-only data access

#### Test Infrastructure
- **Test Suite** (`spec/`): Comprehensive RSpec-based testing with 270+ assertions
- **Test Vault Setup** (`spec/support/test_vault_setup.rb`): Creates realistic test scenarios with:
  - 11 different note types (simple, tagged, frontmatter-only, empty, malformed, etc.)
  - Subdirectory handling (`projects/project-alpha.md`)
  - Unicode and special character support
  - Predictable timestamps for consistent testing
  - Temporary vault cleanup
- **Integration Tests**: Full end-to-end testing of MCP tools with edge case coverage
- **Shared Contexts**: Reusable test fixtures with `:vault_setup` tag

### Vault Discovery Logic

The server automatically discovers vaults in this priority order:
1. `OBSIDIAN_VAULT_PATH` environment variable
2. `../obsidian-test-notes/notes` (development default)
3. Common relative paths for Obsidian vaults

### Data Flow

1. **Initialization**: Server discovers vault path and validates accessibility
2. **Tool Requests**: MCP client sends tool calls (search, read, list, filter)
3. **Processing**: Services handle business logic using models for data access
4. **Resource Requests**: MCP client requests statistical resources
5. **Response**: Formatted JSON responses with note content and metadata

### Testing Strategy

The project uses a comprehensive testing approach:

- **Integration Testing**: Tests complete MCP tool workflows from input to output
- **Realistic Fixtures**: Test vault with diverse note types and edge cases
- **Performance Testing**: Ensures sub-second response times
- **Error Handling**: Tests graceful handling of malformed data and missing paths
- **Unicode Support**: Validates proper handling of international characters and emojis
- **Consistency Testing**: Verifies identical results across multiple calls

## Testing with MCP Inspector

You can test the server using the official MCP inspector:

```bash
npx @modelcontextprotocol/inspector ./obsidian_server.rb
```

## Integration with Claude Desktop

Add to your Claude Desktop configuration:

**macOS**: `~/Library/Application Support/Claude/claude_desktop_config.json`
**Windows**: `%APPDATA%\\Claude\\claude_desktop_config.json`

```json
{
  "mcpServers": {
    "obsidian-vault": {
      "command": "ruby",
      "args": ["/path/to/obsidian-mcp-server/obsidian_server.rb"],
      "env": {
        "OBSIDIAN_VAULT_PATH": "/path/to/your/obsidian/vault"
      }
    }
  }
}
```

## Requirements

- Ruby 3.2+
- Bundler

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Built with [fast-mcp](https://github.com/yjacquin/fast-mcp)
- Test notes from [keikhcheung/notes](https://github.com/keikhcheung/notes)
- Inspired by the [Model Context Protocol](https://github.com/modelcontextprotocol) specification
