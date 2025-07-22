# frozen_string_literal: true

require_relative '../base/tool'

module ObsidianMcp
  module Tools
    class ReadNote < ObsidianMcp::Base::Tool
      description 'Read the content of a specific note from the Obsidian vault'

      arguments do
        required(:note_identifier).filled(:string).description('Note filename or title to read')
      end

      def call(note_identifier:)
        note_path = vault.find_note(note_identifier)
        return { error: "Note not found: #{note_identifier}" } unless note_path

        note = ObsidianMcp::Models::Note.new(note_path, vault)
        note.to_hash(include_content: true)
      end
    end
  end
end
