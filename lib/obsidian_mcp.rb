# frozen_string_literal: true

require 'json'

# Configuration
require_relative 'obsidian_mcp/config'

# Models
require_relative 'obsidian_mcp/models/vault'
require_relative 'obsidian_mcp/models/note'

# Services
require_relative 'obsidian_mcp/services/search_service'
require_relative 'obsidian_mcp/services/stats_service'

# Base classes
require_relative 'obsidian_mcp/base/tool'
require_relative 'obsidian_mcp/base/resource'

# Tools
require_relative 'obsidian_mcp/tools/search_notes'
require_relative 'obsidian_mcp/tools/read_note'
require_relative 'obsidian_mcp/tools/list_notes'
require_relative 'obsidian_mcp/tools/find_by_tags'

# Resources
require_relative 'obsidian_mcp/resources/vault_statistics'
require_relative 'obsidian_mcp/resources/tag_cloud'

module ObsidianMcp
  def self.create_server
    server = FastMcp::Server.new(
      name: Config.server_name,
      version: Config.server_version
    )

    # Register tools
    server.register_tool(Tools::SearchNotes)
    server.register_tool(Tools::ReadNote)
    server.register_tool(Tools::ListNotes)
    server.register_tool(Tools::FindByTags)

    # Register resources
    server.register_resource(Resources::VaultStatistics)
    server.register_resource(Resources::TagCloud)

    server
  end
end
