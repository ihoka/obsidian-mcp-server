# frozen_string_literal: true

require_relative '../base/tool'
require_relative '../services/search_service'

module ObsidianMcp
  module Tools
    class FindByTags < ObsidianMcp::Base::Tool
      description 'Find notes that have specific tags'

      arguments do
        required(:tags).filled(:array).description('Array of tags to search for')
        optional(:match_all).filled(:bool).description('Whether to match all tags (true) or any tag (false, default)')
        optional(:include_content).filled(:bool).description('Whether to include note content in results (default: false)')
      end

      def call(tags:, match_all: false, include_content: false)
        search_service = ObsidianMcp::Services::SearchService.new(vault)
        search_service.find_notes_by_tags(tags, match_all: match_all, include_content: include_content)
      end
    end
  end
end
