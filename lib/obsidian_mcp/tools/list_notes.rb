# frozen_string_literal: true

require_relative '../base/tool'
require_relative '../services/search_service'

module ObsidianMcp
  module Tools
    class ListNotes < ObsidianMcp::Base::Tool
      tool_name 'list_notes'
      description 'List all notes in the Obsidian vault with basic metadata'

      arguments do
        optional(:include_tags).filled(:bool).description('Whether to include tags in the listing (default: true)')
      end

      def call(include_tags: true)
        search_service = ObsidianMcp::Services::SearchService.new(vault)
        search_service.list_all_notes(include_tags: include_tags)
      end
    end
  end
end
