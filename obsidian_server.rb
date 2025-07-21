#!/usr/bin/env ruby
# frozen_string_literal: true

require 'bundler/setup'
require_relative 'lib/obsidian_mcp'

# Start the server if this file is run directly
if __FILE__ == $0
  puts "🧠 Starting Obsidian Vault MCP Server..."
  puts "📁 Vault path: #{ObsidianMcp::Config.vault_path}"
  puts "🔧 Server: #{ObsidianMcp::Config.server_name} v#{ObsidianMcp::Config.server_version}"
  puts "💡 Set OBSIDIAN_VAULT_PATH environment variable to use a different vault"
  puts
  
  begin
    server = ObsidianMcp.create_server
    server.start
  rescue => e
    puts "❌ Error starting server: #{e.message}"
    puts "   Make sure your vault path exists and is accessible"
    exit 1
  end
end
