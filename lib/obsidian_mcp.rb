# frozen_string_literal: true

require 'json'

# Logging
require_relative 'obsidian_mcp/logger'

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
    logger.debug "Creating MCP server: #{Config.server_name} v#{Config.server_version}"
    server = FastMcp::Server.new(
      name: Config.server_name,
      version: Config.server_version
    )

    # Register tools
    logger.trace 'Registering tools...'

    server.register_tool(Tools::SearchNotes)
    logger.trace 'Registered SearchNotes tool'

    server.register_tool(Tools::ReadNote)
    logger.trace 'Registered ReadNote tool'

    server.register_tool(Tools::ListNotes)
    logger.trace 'Registered ListNotes tool'

    server.register_tool(Tools::FindByTags)
    logger.trace 'Registered FindByTags tool'

    # Register resources
    logger.trace 'Registering resources...'

    server.register_resource(Resources::VaultStatistics)
    logger.trace 'Registered VaultStatistics resource'

    server.register_resource(Resources::TagCloud)
    logger.trace 'Registered TagCloud resource'

    logger.trace 'Server creation complete'
    server
  end

  def self.logger
    @logger ||= SemanticLogger['obsidian_mcp']
  end
end
