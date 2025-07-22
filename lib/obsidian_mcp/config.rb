# frozen_string_literal: true

module ObsidianMcp
  class Config
    class << self
      def vault_path
        @vault_path ||= ENV['OBSIDIAN_VAULT_PATH'] || default_vault_path
      end

      attr_writer :vault_path

      def server_name
        @server_name ||= ENV['OBSIDIAN_MCP_SERVER_NAME'] || 'obsidian-vault-server'
      end

      def server_version
        @server_version ||= ENV['OBSIDIAN_MCP_SERVER_VERSION'] || '1.0.0'
      end

      def reset!
        @vault_path = nil
        @server_name = nil
        @server_version = nil
      end

      private

      def default_vault_path
        # Try to find the test notes relative to the current working directory
        candidates = [
          '../obsidian-test-notes/notes',
          './obsidian-test-notes/notes',
          '../../obsidian-test-notes/notes'
        ]

        candidates.each do |path|
          expanded_path = File.expand_path(path)
          return expanded_path if File.directory?(expanded_path)
        end

        raise 'No vault found. Please set OBSIDIAN_VAULT_PATH environment variable'
      end
    end
  end
end
