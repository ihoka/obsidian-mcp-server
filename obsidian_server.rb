#!/usr/bin/env ruby
# frozen_string_literal: true

require 'bundler/setup'
require_relative 'lib/obsidian_mcp'

# Start the server if this file is run directly
if __FILE__ == $PROGRAM_NAME
  begin
    server = ObsidianMcp.create_server
    server.start
  rescue StandardError => e
    warn "Error starting server: #{e.message}"
    warn 'Make sure your vault path exists and is accessible'
    exit 1
  end
end
