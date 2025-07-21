# frozen_string_literal: true

require_relative '../models/note'

module ObsidianMcp
  module Services
    class SearchService
      def initialize(vault)
        @vault = vault
      end

      def search_notes(query, include_content: false)
        results = []
        matches_found = []

        @vault.notes_glob.each do |note_path|
          note = ObsidianMcp::Models::Note.new(note_path, @vault)
          
          if note.matches_query?(query)
            match_details = determine_match_types(note, query)
            result = note.to_hash(include_content: include_content)
            result[:matches] = match_details
            results << result
            matches_found << match_details
          end
        end

        {
          query: query,
          total_results: results.length,
          results: results
        }
      end

      def find_notes_by_tags(tags, match_all: false, include_content: false)
        matching_notes = []

        @vault.notes_glob.each do |note_path|
          note = ObsidianMcp::Models::Note.new(note_path, @vault)
          
          next if note.tags.empty?
          
          if note.has_tags?(tags, match_all: match_all)
            matching_notes << note.to_hash(include_content: include_content)
          end
        end

        {
          search_tags: tags,
          match_all: match_all,
          total_matches: matching_notes.length,
          notes: matching_notes.sort_by { |n| n[:title] }
        }
      end

      def list_all_notes(include_tags: true)
        notes = []

        @vault.notes_glob.each do |note_path|
          note = ObsidianMcp::Models::Note.new(note_path, @vault)
          note_info = note.to_hash
          note_info.delete(:tags) unless include_tags
          notes << note_info
        end

        {
          total_notes: notes.length,
          vault_path: @vault.vault_path.to_s,
          notes: notes.sort_by { |n| n[:title] }
        }
      end

      private

      def determine_match_types(note, query)
        matches = []
        query_lower = query.downcase
        
        matches << 'title' if note.title.downcase.include?(query_lower)
        matches << 'tags' if note.tags.any? { |tag| tag.to_s.downcase.include?(query_lower) }
        matches << 'content' if note.body.downcase.include?(query_lower)
        
        matches
      end
    end
  end
end
