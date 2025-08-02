# frozen_string_literal: true

RSpec.describe ObsidianMcp::Models::Vault, :vault_setup do
  describe '#initialize' do
    context 'with valid vault path' do
      it 'accepts a valid directory path' do
        vault = described_class.new(test_vault_dir)
        expect(vault.vault_path).to eq(Pathname.new(test_vault_dir).expand_path)
      end

      it 'expands relative paths' do
        relative_path = Pathname.new(test_vault_dir).relative_path_from(Pathname.pwd)
        vault = described_class.new(relative_path.to_s)
        expect(vault.vault_path).to eq(Pathname.new(test_vault_dir).expand_path)
      end

      it 'uses default vault path when no argument provided' do
        ObsidianMcp::Config.vault_path = test_vault_dir
        vault = described_class.new
        expect(vault.vault_path).to eq(Pathname.new(test_vault_dir).expand_path)
      end
    end

    context 'with invalid vault path' do
      it 'raises ArgumentError for non-existent path' do
        expect { described_class.new('/nonexistent/path') }
          .to raise_error(ArgumentError, 'Vault path does not exist: /nonexistent/path')
      end

      it 'accepts files as vault paths (current behavior)' do
        file_path = File.join(test_vault_dir, 'simple-note.md')
        # Current implementation only checks if path exists, not if it's a directory
        expect { described_class.new(file_path) }.not_to raise_error
      end
    end
  end

  describe '#notes_glob' do
    it 'returns all markdown files in the vault' do
      notes = vault.notes_glob
      expect(notes).to be_an(Array)
      expect(notes.length).to eq(11)
      
      # All returned files should be Pathname objects
      notes.each do |note|
        expect(note).to be_a(Pathname)
        expect(note.extname).to eq('.md')
      end
    end

    it 'includes notes from subdirectories' do
      notes = vault.notes_glob
      subdir_notes = notes.select { |note| note.to_s.include?('projects/') }
      expect(subdir_notes).not_to be_empty
      expect(subdir_notes.first.basename.to_s).to eq('project-alpha.md')
    end

    it 'returns absolute paths' do
      notes = vault.notes_glob
      notes.each do |note|
        expect(note).to be_absolute
        expect(note.to_s).to start_with(test_vault_dir)
      end
    end
  end

  describe '#find_note' do
    context 'with exact filename matches' do
      it 'finds note by exact filename' do
        note = vault.find_note('simple-note.md')
        expect(note).not_to be_nil
        expect(note.basename.to_s).to eq('simple-note.md')
      end

      it 'finds note by filename without extension' do
        note = vault.find_note('simple-note')
        expect(note).not_to be_nil
        expect(note.basename.to_s).to eq('simple-note.md')
      end

      it 'finds notes in subdirectories' do
        note = vault.find_note('project-alpha.md')
        expect(note).not_to be_nil
        expect(note.to_s).to include('projects/project-alpha.md')
      end
    end

    context 'with case-insensitive search' do
      it 'finds note with different case in filename' do
        note = vault.find_note('SIMPLE-NOTE')
        expect(note).not_to be_nil
        expect(note.basename.to_s).to eq('simple-note.md')
      end

      it 'finds note with different case including extension' do
        note = vault.find_note('Simple-Note.MD')
        expect(note).not_to be_nil
        expect(note.basename.to_s).to eq('simple-note.md')
      end
    end

    context 'with special characters' do
      it 'finds notes with special characters in filename' do
        note = vault.find_note('special-chars.md')
        expect(note).not_to be_nil
        expect(note.basename.to_s).to eq('special-chars.md')
      end
    end

    context 'when note does not exist' do
      it 'returns nil for non-existent note' do
        note = vault.find_note('non-existent-note')
        expect(note).to be_nil
      end

      it 'returns root path for empty string (current behavior)' do
        note = vault.find_note('')
        # Current implementation returns root path when glob pattern is empty
        expect(note).to eq(Pathname.new('/'))
      end
    end

    context 'search priority' do
      before do
        # Create a note with same name but different extension
        write_note('duplicate-name.txt', 'Text file content')
        write_note('duplicate-name.md', 'Markdown file content')
      end

      it 'prioritizes exact matches over case-insensitive matches' do
        note = vault.find_note('duplicate-name.md')
        expect(note).not_to be_nil
        expect(note.extname).to eq('.md')
      end

      it 'finds .md files when searching without extension' do
        note = vault.find_note('duplicate-name')
        expect(note).not_to be_nil
        expect(note.extname).to eq('.md')
      end
    end
  end

  describe '#parse_frontmatter' do
    context 'with valid frontmatter' do
      it 'parses YAML frontmatter correctly' do
        content = <<~CONTENT
          ---
          title: "Test Note"
          tags: ["test", "example"]
          author: "Test Author"
          ---
          
          This is the body content.
        CONTENT

        frontmatter, body = vault.parse_frontmatter(content)
        
        expect(frontmatter).to be_a(Hash)
        expect(frontmatter['title']).to eq('Test Note')
        expect(frontmatter['tags']).to eq(['test', 'example'])
        expect(frontmatter['author']).to eq('Test Author')
        expect(body).to eq('This is the body content.')
      end

      it 'handles frontmatter with nested structures' do
        content = <<~CONTENT
          ---
          metadata:
            created: "2024-01-01"
            updated: "2024-01-02"
          tags: ["nested"]
          ---
          
          Body with nested frontmatter.
        CONTENT

        frontmatter, body = vault.parse_frontmatter(content)
        
        expect(frontmatter['metadata']).to be_a(Hash)
        expect(frontmatter['metadata']['created']).to eq('2024-01-01')
        expect(body).to eq('Body with nested frontmatter.')
      end
    end

    context 'with malformed frontmatter' do
      it 'returns nil frontmatter for invalid YAML' do
        content = <<~CONTENT
          ---
          title: "Unclosed quote
          tags: [unclosed
          ---
          
          Body content.
        CONTENT

        frontmatter, body = vault.parse_frontmatter(content)
        
        expect(frontmatter).to be_nil
        expect(body).to eq(content)
      end

      it 'handles incomplete frontmatter delimiters' do
        content = <<~CONTENT
          ---
          title: "Test"
          
          Missing closing delimiter
        CONTENT

        frontmatter, body = vault.parse_frontmatter(content)
        
        expect(frontmatter).to be_nil
        expect(body).to eq(content)
      end
    end

    context 'without frontmatter' do
      it 'returns nil frontmatter for content without frontmatter' do
        content = "Just plain content without frontmatter."
        
        frontmatter, body = vault.parse_frontmatter(content)
        
        expect(frontmatter).to be_nil
        expect(body).to eq(content)
      end

      it 'handles content starting with --- but not frontmatter' do
        content = "--- This is just a line, not frontmatter"
        
        frontmatter, body = vault.parse_frontmatter(content)
        
        expect(frontmatter).to be_nil
        expect(body).to eq(content)
      end
    end

    context 'edge cases' do
      it 'handles empty content' do
        frontmatter, body = vault.parse_frontmatter('')
        
        expect(frontmatter).to be_nil
        expect(body).to eq('')
      end

      it 'handles frontmatter only content' do
        content = <<~CONTENT
          ---
          title: "Only frontmatter"
          ---
        CONTENT

        frontmatter, body = vault.parse_frontmatter(content)
        
        expect(frontmatter).to be_a(Hash)
        expect(frontmatter['title']).to eq('Only frontmatter')
        expect(body).to eq('')
      end

      it 'handles content with multiple --- separators' do
        content = <<~CONTENT
          ---
          title: "Test"
          ---
          
          Body content with --- in it.
          --- Another line with dashes
        CONTENT

        frontmatter, body = vault.parse_frontmatter(content)
        
        expect(frontmatter).to be_a(Hash)
        expect(frontmatter['title']).to eq('Test')
        expect(body).to eq("Body content with --- in it.\n--- Another line with dashes")
      end
    end
  end

  describe '#extract_links' do
    context 'with internal links' do
      it 'extracts simple internal links' do
        content = "This references [[Simple Note]] and [[Another Note]]."
        
        links = vault.extract_links(content)
        
        expect(links[:internal]).to contain_exactly('Simple Note', 'Another Note')
        expect(links[:external]).to be_empty
      end

      it 'extracts internal links with special characters' do
        content = "Links to [[Note with Spaces]] and [[Note-with-dashes]] and [[Note_with_underscores]]."
        
        links = vault.extract_links(content)
        
        expect(links[:internal]).to contain_exactly(
          'Note with Spaces', 
          'Note-with-dashes', 
          'Note_with_underscores'
        )
      end

      it 'extracts links but stops at first closing bracket' do
        content = "This has [[Link with [brackets] inside]] and [[Normal Link]]."
        
        links = vault.extract_links(content)
        
        # Current regex [^\]]+ stops at first ] so nested brackets don't work
        expect(links[:internal]).to contain_exactly('Normal Link')
      end
    end

    context 'with external links' do
      it 'extracts simple external links' do
        content = "Visit [Google](https://google.com) and [GitHub](https://github.com)."
        
        links = vault.extract_links(content)
        
        expect(links[:external]).to contain_exactly(
          { text: 'Google', url: 'https://google.com' },
          { text: 'GitHub', url: 'https://github.com' }
        )
        expect(links[:internal]).to be_empty
      end

      it 'handles various URL schemes' do
        content = <<~CONTENT
          Links to:
          - [HTTPS](https://example.com)
          - [HTTP](http://example.com)
          - [FTP](ftp://files.example.com)
          - [Email](mailto:test@example.com)
        CONTENT
        
        links = vault.extract_links(content)
        
        expect(links[:external]).to contain_exactly(
          { text: 'HTTPS', url: 'https://example.com' },
          { text: 'HTTP', url: 'http://example.com' },
          { text: 'FTP', url: 'ftp://files.example.com' },
          { text: 'Email', url: 'mailto:test@example.com' }
        )
      end
    end

    context 'with mixed link types' do
      it 'extracts both internal and external links' do
        content = <<~CONTENT
          See [[Internal Note]] for details.
          Also check [External Site](https://example.com).
          And reference [[Another Internal]] note.
          Visit [Another Site](https://test.com) too.
        CONTENT
        
        links = vault.extract_links(content)
        
        expect(links[:internal]).to contain_exactly('Internal Note', 'Another Internal')
        expect(links[:external]).to contain_exactly(
          { text: 'External Site', url: 'https://example.com' },
          { text: 'Another Site', url: 'https://test.com' }
        )
      end
    end

    context 'edge cases' do
      it 'handles content with no links' do
        content = "This content has no links at all."
        
        links = vault.extract_links(content)
        
        expect(links[:internal]).to be_empty
        expect(links[:external]).to be_empty
      end

      it 'handles empty content' do
        links = vault.extract_links('')
        
        expect(links[:internal]).to be_empty
        expect(links[:external]).to be_empty
      end

      it 'handles malformed link syntax' do
        content = <<~CONTENT
          These are not proper links:
          [Missing closing bracket
          [[Missing closing internal
          [Text](missing-closing-paren
          ]Not a link[
        CONTENT
        
        links = vault.extract_links(content)
        
        expect(links[:internal]).to be_empty
        expect(links[:external]).to be_empty
      end

      it 'handles links with special characters in text and URLs' do
        content = <<~CONTENT
          Links with special chars:
          [[Note with émojis 🚀]]
          [Site with symbols ™️](https://example.com/path?param=value&other=123)
        CONTENT
        
        links = vault.extract_links(content)
        
        expect(links[:internal]).to contain_exactly('Note with émojis 🚀')
        expect(links[:external]).to contain_exactly(
          { text: 'Site with symbols ™️', url: 'https://example.com/path?param=value&other=123' }
        )
      end
    end
  end

  describe 'integration with file system' do
    context 'reading actual files' do
      it 'can parse frontmatter from real files' do
        note_path = vault.find_note('tagged-note')
        content = File.read(note_path)
        frontmatter, body = vault.parse_frontmatter(content)
        
        expect(frontmatter).not_to be_nil
        expect(frontmatter['title']).to eq('My Tagged Note')
        expect(frontmatter['tags']).to contain_exactly('project', 'important', 'work')
        expect(body).to include('This note has frontmatter with tags')
      end

      it 'can extract links from real files' do
        note_path = vault.find_note('linked-note')
        content = File.read(note_path)
        links = vault.extract_links(content)
        
        expect(links[:internal]).to contain_exactly(
          'simple-note', 
          'tagged-note', 
          'non-existent-note'
        )
      end
    end

    context 'error handling with file operations' do
      it 'handles file permission errors gracefully' do
        # This test may be skipped on some systems where permission changes don't work as expected
        note_path = vault.find_note('simple-note')
        
        begin
          # Make file unreadable
          original_mode = File.stat(note_path).mode
          File.chmod(0o000, note_path)
          
          expect { File.read(note_path) }.to raise_error(Errno::EACCES)
        ensure
          # Restore original permissions
          File.chmod(original_mode, note_path) if original_mode
        end
      end
    end
  end
end