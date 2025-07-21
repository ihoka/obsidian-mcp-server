# frozen_string_literal: true

require_relative '../base/resource'
require_relative '../services/stats_service'

module ObsidianMcp
  module Resources
    class TagCloud < ObsidianMcp::Base::Resource
      uri "obsidian://vault/tags"
      resource_name "Tag Cloud"
      description "All tags used in the vault with usage counts"
      mime_type "application/json"

      def content
        stats_service = ObsidianMcp::Services::StatsService.new(vault)
        JSON.generate(stats_service.tag_cloud)
      end
    end
  end
end
