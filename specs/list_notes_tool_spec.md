# ListNotes Tool Specification

## Overview
The ListNotes tool is an MCP (Model Context Protocol) tool that provides a comprehensive listing of all notes within an Obsidian vault, returning basic metadata for each note in a structured format.

## Purpose
- **Primary Function**: Enumerate all markdown notes in an Obsidian vault
- **Use Cases**: 
  - Getting an overview of vault contents
  - Building indexes or catalogs of available notes
  - Discovering notes for further processing or analysis
  - Providing context for other tools that need to know what notes exist

## Tool Identity
- **Name**: `ObsidianMcp::Tools::ListNotes`
- **MCP Tool Name**: `ObsidianMcp::Tools::ListNotes`
- **Description**: "List all notes in the Obsidian vault with basic metadata"

## Input Parameters

### Arguments Schema
```json
{
  "properties": {
    "include_tags": {
      "description": "Whether to include tags in the listing (default: true)",
      "type": "boolean"
    }
  },
  "type": "object"
}
```

### Parameter Details
- **include_tags** (optional, boolean, default: true)
  - When `true`: Tags are included in each note's metadata
  - When `false`: Tags are excluded from the response to reduce payload size
  - Useful for performance optimization when tags are not needed

## Output Format

### Response Structure
```json
{
  "total_notes": integer,
  "vault_path": string,
  "notes": [
    {
      "path": string,
      "title": string,
      "tags": array,
      "word_count": integer,
      "modified": string
    }
  ]
}
```

### Response Fields

#### Top Level
- **total_notes**: Count of notes found in the vault
- **vault_path**: Absolute path to the Obsidian vault directory
- **notes**: Array of note objects, sorted alphabetically by title

#### Note Object
- **path**: Relative path from vault root (e.g., "folder/note.md")
- **title**: Note title (from frontmatter or filename if no frontmatter title)
- **tags**: Array of tags associated with the note (only if `include_tags: true`)
- **word_count**: Number of words in the note content (excluding frontmatter)
- **modified**: ISO 8601 timestamp of last modification

## Behavior Specifications

### Discovery Process
1. **File Discovery**: Recursively traverses the vault directory using glob patterns
2. **File Filtering**: Only processes `.md` files (Markdown format)
3. **Metadata Extraction**: For each note, extracts:
   - Title from YAML frontmatter or filename
   - Tags from frontmatter
   - Word count from body content
   - File modification timestamp

### Data Processing
- **Frontmatter Parsing**: YAML frontmatter is parsed to extract structured metadata
- **Content Separation**: Distinguishes between frontmatter and note body
- **Title Resolution**: Uses frontmatter title if available, falls back to filename
- **Tag Extraction**: Reads tags from frontmatter `tags` field

### Sorting and Organization
- **Default Sort**: Notes are sorted alphabetically by title
- **Case Sensitivity**: Sort is case-insensitive
- **Consistent Ordering**: Same input always produces same order

## Performance Characteristics

### Scalability
- **File System Dependent**: Performance scales with vault size and file system speed
- **Memory Usage**: Processes notes one at a time to minimize memory footprint
- **I/O Optimization**: Each note file is read once during processing

### Optimization Features
- **Conditional Tags**: `include_tags` parameter allows reducing response size
- **Lazy Loading**: Note content is only parsed when accessed
- **Efficient Traversal**: Uses file system glob patterns for discovery

## Integration Points

### Dependencies
- **Vault Model**: Requires configured Obsidian vault instance
- **SearchService**: Delegates core listing logic to search service
- **Note Model**: Uses Note model for metadata extraction and formatting

### MCP Integration
- **Tool Registration**: Automatically registered with MCP server
- **Schema Validation**: Input parameters validated against JSON schema
- **Error Handling**: Integrates with MCP error reporting mechanisms

## Error Conditions

### Expected Errors
- **Vault Not Found**: When vault path doesn't exist or isn't accessible
- **Permission Denied**: When file system permissions prevent access
- **Malformed Files**: When markdown files contain invalid frontmatter
- **File System Errors**: I/O errors during file traversal or reading

### Error Handling Strategy
- **Graceful Degradation**: Continues processing other notes if individual notes fail
- **Error Logging**: Records parsing errors for debugging
- **Partial Results**: Returns successfully processed notes even if some fail

## Security Considerations

### Access Control
- **Vault Boundary**: Only accesses files within configured vault directory
- **File Type Restriction**: Only processes `.md` files, ignoring other formats
- **Path Traversal Protection**: Uses relative paths to prevent directory traversal

### Data Privacy
- **Content Exclusion**: By default excludes note content from response
- **Metadata Only**: Only exposes basic metadata, not sensitive content
- **Optional Tags**: Tags can be excluded if they contain sensitive information

## Future Considerations

### Extensibility
- **Additional Metadata**: Could be extended to include creation time, file size, etc.
- **Filtering Options**: Could add parameters for filtering by modification date, tags, etc.
- **Pagination**: Could support pagination for very large vaults
- **Custom Sorting**: Could allow different sort criteria

### Performance Enhancements
- **Caching**: Could implement caching for frequently accessed vault listings
- **Incremental Updates**: Could support detecting only changed notes
- **Parallel Processing**: Could process notes in parallel for large vaults
