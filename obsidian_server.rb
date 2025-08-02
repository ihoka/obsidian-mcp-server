#!/usr/bin/env ruby
# frozen_string_literal: true

require 'bundler/setup'
require_relative 'lib/obsidian_mcp'

# Start the server if this file is run directly
if __FILE__ == $PROGRAM_NAME
  begin
    $log.trace 'Starting Obsidian MCP Server...'
    $log.debug "Ruby version: #{RUBY_VERSION}"
    $log.debug "Working directory: #{Dir.pwd}"
    $log.debug 'Environment variables:'
    $log.debug "  OBSIDIAN_VAULT_PATH: #{ENV['OBSIDIAN_VAULT_PATH'] || 'not set'}"

    $log.trace 'Initializing server...'
    server = ObsidianMcp.create_server

    vault_path = ObsidianMcp::Config.vault_path

    $log.debug "Vault path: #{vault_path}"
    $log.debug "Vault path exists: #{File.directory?(vault_path)}"
    $log.debug "Vault path readable: #{File.readable?(vault_path)}"

    if File.directory?(vault_path)
      notes_count = Dir.glob(File.join(vault_path, '**', '*.md')).count
      $log.debug " Found #{notes_count} markdown files in vault"
    end

    $log.trace 'Starting server...'
    server.start
  rescue StandardError => e
    $log.error "Error starting server: #{e.message}"
    $log.error 'Make sure your vault path exists and is accessible'
    exit 1
  end
end
