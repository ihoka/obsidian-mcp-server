# frozen_string_literal: true

require 'pathname'
require 'yaml'

module ObsidianMcp
  module Models
    class Vault
      attr_reader :vault_path

      def initialize(vault_path = ObsidianMcp::Config.vault_path)
        @vault_path = Pathname.new(vault_path).expand_path
        raise ArgumentError, "Vault path does not exist: #{@vault_path}" unless @vault_path.exist?
      end

      def notes_glob
        @vault_path.glob('**/*.md')
      end

      def find_note(title_or_filename)
        # Try exact filename match first
        exact_match = @vault_path.glob("**/#{title_or_filename}")
        return exact_match.first if exact_match.any?

        # Try with .md extension
        md_match = @vault_path.glob("**/#{title_or_filename}.md")
        return md_match.first if md_match.any?

        # Try case-insensitive search
        notes_glob.find do |note|
          note.basename('.md').to_s.downcase == title_or_filename.downcase ||
            note.basename.to_s.downcase == title_or_filename.downcase
        end
      end

      def parse_frontmatter(content)
        return [nil, content] unless content.start_with?('---')

        parts = content.split('---', 3)
        return [nil, content] if parts.length < 3

        begin
          frontmatter = YAML.safe_load(parts[1])
          body = parts[2].strip
          [frontmatter, body]
        rescue Psych::SyntaxError
          [nil, content]
        end
      end

      def extract_links(content)
        # Extract [[Internal Links]]
        internal_links = content.scan(/\[\[([^\]]+)\]\]/).flatten
        
        # Extract [External Links](url)
        external_links = content.scan(/\[([^\]]+)\]\(([^)]+)\)/).map { |text, url| { text: text, url: url } }
        
        { internal: internal_links, external: external_links }
      end
    end
  end
end
