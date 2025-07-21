# frozen_string_literal: true

require 'set'
require_relative '../models/note'

module ObsidianMcp
  module Services
    class StatsService
      def initialize(vault)
        @vault = vault
      end

      def vault_statistics
        total_notes = 0
        total_words = 0
        all_tags = Set.new
        total_internal_links = 0
        total_external_links = 0

        @vault.notes_glob.each do |note_path|
          note = ObsidianMcp::Models::Note.new(note_path, @vault)
          total_notes += 1
          total_words += note.word_count
          
          note.tags.each { |tag| all_tags.add(tag.to_s) }
          
          total_internal_links += note.links[:internal].length
          total_external_links += note.links[:external].length
        end

        {
          vault_path: @vault.vault_path.to_s,
          total_notes: total_notes,
          total_words: total_words,
          average_words_per_note: total_notes > 0 ? (total_words.to_f / total_notes).round(1) : 0,
          unique_tags: all_tags.size,
          all_tags: all_tags.to_a.sort,
          total_internal_links: total_internal_links,
          total_external_links: total_external_links,
          generated_at: Time.now.iso8601
        }
      end

      def tag_cloud
        tag_counts = Hash.new(0)

        @vault.notes_glob.each do |note_path|
          note = ObsidianMcp::Models::Note.new(note_path, @vault)
          note.tags.each { |tag| tag_counts[tag.to_s] += 1 }
        end

        {
          total_unique_tags: tag_counts.size,
          tag_counts: tag_counts.sort_by { |_tag, count| -count }.to_h,
          generated_at: Time.now.iso8601
        }
      end
    end
  end
end
