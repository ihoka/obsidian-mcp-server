#!/usr/bin/env ruby
# frozen_string_literal: true

require 'bundler/setup'
require_relative 'lib/obsidian_mcp'

logger = SemanticLogger['main']

# Start the server if this file is run directly
if __FILE__ == $PROGRAM_NAME
  begin
    logger.trace 'Starting Obsidian MCP Server...'
    logger.debug "Ruby version: #{RUBY_VERSION}"
    logger.debug "Working directory: #{Dir.pwd}"
    logger.debug 'Environment variables:'
    logger.debug "  OBSIDIAN_VAULT_PATH: #{ENV['OBSIDIAN_VAULT_PATH'] || 'not set'}"

    logger.trace 'Initializing server...'
    server = ObsidianMcp.create_server

    vault_path = ObsidianMcp::Config.vault_path

    logger.debug "Vault path: #{vault_path}"
    logger.debug "Vault path exists: #{File.directory?(vault_path)}"
    logger.debug "Vault path readable: #{File.readable?(vault_path)}"

    if File.directory?(vault_path)
      notes_count = Dir.glob(File.join(vault_path, '**', '*.md')).count
      logger.debug " Found #{notes_count} markdown files in vault"
    end

    logger.trace 'Starting server...'
    server.start
  rescue StandardError => e
    logger.error "Error starting server: #{e.message}"
    logger.error 'Make sure your vault path exists and is accessible'
    exit 1
  end
end
