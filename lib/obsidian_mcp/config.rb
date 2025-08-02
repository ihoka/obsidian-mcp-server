# frozen_string_literal: true

module ObsidianMcp
  class Config
    class << self
      def vault_path
        @vault_path ||= ENV.fetch('OBSIDIAN_VAULT_PATH', '/vault')
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
    end
  end
end
