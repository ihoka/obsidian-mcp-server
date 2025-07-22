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

The project follows a clean, modular architecture:

```
lib/
├── obsidian_mcp/
│   ├── config.rb              # Configuration management
│   ├── models/
│   │   ├── vault.rb           # Vault operations
│   │   └── note.rb            # Individual note representation
│   ├── services/
│   │   ├── search_service.rb  # Search functionality
│   │   └── stats_service.rb   # Statistics calculation
│   ├── base/
│   │   ├── tool.rb            # Base tool class
│   │   └── resource.rb        # Base resource class
│   ├── tools/                 # Individual MCP tools
│   └── resources/             # MCP resources
└── obsidian_mcp.rb           # Main module
```

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
