# frozen_string_literal: true

require_relative '../base/tool'
require_relative '../services/search_service'

module ObsidianMcp
  module Tools
    class SearchNotes < ObsidianMcp::Base::Tool
      tool_name 'search_notes'
      description 'Search for notes in the Obsidian vault by query text'

      arguments do
        required(:query).filled(:string).description('Search query to find in note titles, tags, or content')
        optional(:include_content).filled(:bool).description('Whether to include note content in results (default: false)')
      end

      def call(query:, include_content: false)
        search_service = ObsidianMcp::Services::SearchService.new(vault)
        search_service.search_notes(query, include_content: include_content)
      end
    end
  end
end
