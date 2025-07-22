# frozen_string_literal: true

require_relative '../base/resource'
require_relative '../services/stats_service'

module ObsidianMcp
  module Resources
    class VaultStatistics < ObsidianMcp::Base::Resource
      uri 'obsidian://vault/stats'
      resource_name 'Vault Statistics'
      description 'Overall statistics about the Obsidian vault'
      mime_type 'application/json'

      def content
        stats_service = ObsidianMcp::Services::StatsService.new(vault)
        JSON.generate(stats_service.vault_statistics)
      end
    end
  end
end
