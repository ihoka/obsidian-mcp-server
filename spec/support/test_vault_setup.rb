# frozen_string_literal: true

require 'fileutils'
require 'tmpdir'
require 'pathname'

RSpec.shared_context 'test vault setup' do
  let(:test_vault_dir) { @test_vault_dir }
  let(:vault) { ObsidianMcp::Models::Vault.new(test_vault_dir) }

  before do
    # Create a temporary directory for the test vault
    @test_vault_dir = Dir.mktmpdir('obsidian_test_vault')

    # Override the config to use our test vault
    ObsidianMcp::Config.vault_path = test_vault_dir

    create_test_notes
  end

  after do
    # Clean up the temporary directory
    FileUtils.remove_entry(test_vault_dir) if test_vault_dir && File.exist?(test_vault_dir)
  end

  private

  def create_test_notes
    # Create a variety of test notes with different structures

    # Simple note without frontmatter
    write_note('simple-note.md', <<~CONTENT)
      This is a simple note without frontmatter.
      It has some basic content for testing.
    CONTENT

    # Note with frontmatter and tags
    write_note('tagged-note.md', <<~CONTENT)
      ---
      title: "My Tagged Note"
      tags: ["project", "important", "work"]
      ---

      This note has frontmatter with tags.
      It's useful for testing tag functionality.
    CONTENT

    # Note with custom title in frontmatter
    write_note('custom-title.md', <<~CONTENT)
      ---
      title: "Custom Title Different From Filename"
      tags: ["personal"]
      ---

      This note demonstrates custom titles.
      The title in frontmatter overrides the filename.
    CONTENT

    # Empty note
    write_note('empty-note.md', '')

    # Note with only frontmatter, no body
    write_note('frontmatter-only.md', <<~CONTENT)
      ---
      title: "Frontmatter Only Note"
      tags: ["meta"]
      ---
    CONTENT

    # Note with malformed frontmatter
    write_note('malformed-frontmatter.md', <<~CONTENT)
      ---
      title: "Broken YAML
      tags: [unclosed
      ---

      This note has malformed frontmatter that should be handled gracefully.
    CONTENT

    # Note in a subdirectory
    create_subdirectory('projects')
    write_note('projects/project-alpha.md', <<~CONTENT)
      ---
      title: "Project Alpha"
      tags: ["project", "alpha", "active"]
      ---

      This is a project note in a subdirectory.
      It tests directory traversal functionality.
    CONTENT

    # Note with no tags
    write_note('no-tags.md', <<~CONTENT)
      ---
      title: "Note Without Tags"
      ---

      This note has frontmatter but no tags.
      It should handle the absence of tags gracefully.
    CONTENT

    # Note with internal links
    write_note('linked-note.md', <<~CONTENT)
      ---
      title: "Linked Note"
      tags: ["linking"]
      ---

      This note contains [[simple-note]] and [[tagged-note]] as internal links.
      It also has a link to [[non-existent-note]] that doesn't exist.
    CONTENT

    # Large note for testing word count
    write_note('large-note.md', <<~CONTENT)
      ---
      title: "Large Note for Testing"
      tags: ["testing", "large"]
      ---

      #{'This is a large note with many words. ' * 50}

      It has multiple paragraphs to test word counting functionality.

      #{'Word counting should work correctly across paragraphs. ' * 30}
    CONTENT

    # Note with special characters in title and content
    write_note('special-chars.md', <<~CONTENT)
      ---
      title: "Special Characters: Émojis 🚀 & Symbols ™️"
      tags: ["unicode", "special-chars"]
      ---

      This note contains special characters: áéíóú, 中文, 🎉, and symbols like ™️ & ©.
      It tests Unicode handling in various parts of the system.
    CONTENT
  end

  def create_subdirectory(name)
    dir_path = File.join(test_vault_dir, name)
    FileUtils.mkdir_p(dir_path)
  end

  def write_note(filename, content)
    file_path = File.join(test_vault_dir, filename)
    FileUtils.mkdir_p(File.dirname(file_path))
    File.write(file_path, content)

    # Set a predictable modification time for consistent testing
    # Use different times for different files to test sorting
    base_time = Time.parse('2024-01-01 12:00:00 UTC')
    file_index = filename.hash.abs % 100
    mod_time = base_time + (file_index * 60) # Each file gets a different minute
    File.utime(mod_time, mod_time, file_path)
  end
end
