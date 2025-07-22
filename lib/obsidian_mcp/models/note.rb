# frozen_string_literal: true

module ObsidianMcp
  module Models
    class Note
      attr_reader :path, :vault

      def initialize(path, vault)
        @path = path
        @vault = vault
      end

      def content
        @content ||= path.read
      end

      def frontmatter
        @frontmatter ||= begin
          fm, _body = vault.parse_frontmatter(content)
          fm
        end
      end

      def body
        @body ||= begin
          _fm, body = vault.parse_frontmatter(content)
          body
        end
      end

      def title
        @title ||= frontmatter&.dig('title') || path.basename('.md').to_s
      end

      def tags
        @tags ||= frontmatter&.dig('tags') || []
      end

      def links
        @links ||= vault.extract_links(body)
      end

      def word_count
        @word_count ||= body.split.length
      end

      def relative_path
        @relative_path ||= path.relative_path_from(vault.vault_path).to_s
      end

      def modified_time
        @modified_time ||= path.mtime
      end

      def to_hash(include_content: false)
        result = {
          path: relative_path,
          title: title,
          tags: tags,
          word_count: word_count,
          modified: modified_time.iso8601
        }

        if include_content
          result[:frontmatter] = frontmatter
          result[:content] = body
          result[:links] = links
        end

        result
      end

      def matches_query?(query)
        query_lower = query.downcase

        # Check title
        return true if title.downcase.include?(query_lower)

        # Check tags
        return true if tags.any? { |tag| tag.to_s.downcase.include?(query_lower) }

        # Check content
        body.downcase.include?(query_lower)
      end

      def has_tags?(search_tags, match_all: false)
        note_tags = tags.map(&:to_s)
        search_tags = search_tags.map(&:to_s)

        if match_all
          search_tags.all? { |tag| note_tags.include?(tag) }
        else
          search_tags.any? { |tag| note_tags.include?(tag) }
        end
      end
    end
  end
end
