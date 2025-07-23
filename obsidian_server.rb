#!/usr/bin/env ruby
# frozen_string_literal: true

require 'bundler/setup'
require_relative 'lib/obsidian_mcp'

# Start the server if this file is run directly
if __FILE__ == $PROGRAM_NAME
  begin
    warn '[DEBUG] Starting Obsidian MCP Server...'
    warn "[DEBUG] Ruby version: #{RUBY_VERSION}"
    warn "[DEBUG] Working directory: #{Dir.pwd}"
    warn "[DEBUG] Environment variables:"
    warn "[DEBUG]   OBSIDIAN_VAULT_PATH: #{ENV['OBSIDIAN_VAULT_PATH'] || 'not set'}"
    warn "[DEBUG]   OBSIDIAN_MCP_SERVER_NAME: #{ENV['OBSIDIAN_MCP_SERVER_NAME'] || 'not set'}"
    warn "[DEBUG]   OBSIDIAN_MCP_SERVER_VERSION: #{ENV['OBSIDIAN_MCP_SERVER_VERSION'] || 'not set'}"
    warn '[DEBUG] Initializing server...'
    server = ObsidianMcp.create_server
    warn '[DEBUG] Server initialized.'

    warn '[DEBUG] Checking vault path: '
    vault_path = ObsidianMcp::Config.vault_path
    warn "[DEBUG] Vault path: #{vault_path}"
    warn "[DEBUG] Vault path exists: #{File.directory?(vault_path)}"
    warn "[DEBUG] Vault path readable: #{File.readable?(vault_path)}"
    if File.directory?(vault_path)
      notes_count = Dir.glob(File.join(vault_path, '**', '*.md')).count
      warn "[DEBUG] Found #{notes_count} markdown files in vault"
    end
    warn '[DEBUG] Starting server...'
    server.start
    warn '[DEBUG] Server started successfully.'
  rescue StandardError => e
    warn "[ERROR] Error starting server: #{e.message}"
    warn '[ERROR] Make sure your vault path exists and is accessible'
    exit 1
  end
end
