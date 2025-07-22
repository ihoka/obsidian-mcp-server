# frozen_string_literal: true

RSpec.describe ObsidianMcp::Tools::ListNotes, :vault_setup do
  let(:tool) { described_class.new }
  
  describe '#call' do
    context 'with default parameters (include_tags: true)' do
      let(:result) { tool.call }
      
      it 'returns the correct top-level structure' do
        expect(result).to be_a(Hash)
        expect(result).to have_key(:total_notes)
        expect(result).to have_key(:vault_path)
        expect(result).to have_key(:notes)
      end
      
      it 'returns the correct total count' do
        expect(result[:total_notes]).to eq(11) # Based on our test fixture count
        expect(result[:notes].length).to eq(result[:total_notes])
      end
      
      it 'returns the correct vault path' do
        expect(result[:vault_path]).to eq(test_vault_dir.to_s)
        expect(Pathname.new(result[:vault_path])).to be_directory
      end
      
      it 'includes all expected notes' do
        note_paths = result[:notes].map { |note| note[:path] }
        
        # Check for specific test notes we created
        expect(note_paths).to include('simple-note.md')
        expect(note_paths).to include('tagged-note.md')
        expect(note_paths).to include('custom-title.md')
        expect(note_paths).to include('empty-note.md')
        expect(note_paths).to include('projects/project-alpha.md')
        expect(note_paths).to include('special-chars.md')
      end
      
      it 'sorts notes alphabetically by title' do
        titles = result[:notes].map { |note| note[:title] }
        expect(titles).to eq(titles.sort)
      end
      
      describe 'note structure' do
        let(:sample_note) { result[:notes].find { |note| note[:path] == 'tagged-note.md' } }
        
        it 'includes all required fields' do
          expect(sample_note).to have_key(:path)
          expect(sample_note).to have_key(:title)
          expect(sample_note).to have_key(:tags)
          expect(sample_note).to have_key(:word_count)
          expect(sample_note).to have_key(:modified)
        end
        
        it 'uses relative paths from vault root' do
          expect(sample_note[:path]).to eq('tagged-note.md')
          expect(sample_note[:path]).not_to start_with('/')
        end
        
        it 'extracts title from frontmatter when available' do
          expect(sample_note[:title]).to eq('My Tagged Note')
        end
        
        it 'includes tags as an array' do
          expect(sample_note[:tags]).to be_an(Array)
          expect(sample_note[:tags]).to contain_exactly('project', 'important', 'work')
        end
        
        it 'includes word count as integer' do
          expect(sample_note[:word_count]).to be_an(Integer)
          expect(sample_note[:word_count]).to be > 0
        end
        
        it 'includes modification time in ISO 8601 format' do
          expect(sample_note[:modified]).to match(/^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(Z|[+-]\d{2}:\d{2})$/)
          expect { Time.parse(sample_note[:modified]) }.not_to raise_error
        end
        
        it 'does not include content by default' do
          expect(sample_note).not_to have_key(:content)
          expect(sample_note).not_to have_key(:frontmatter)
          expect(sample_note).not_to have_key(:links)
        end
      end
      
      describe 'title resolution' do
        it 'uses frontmatter title when available' do
          custom_title_note = result[:notes].find { |note| note[:path] == 'custom-title.md' }
          expect(custom_title_note[:title]).to eq('Custom Title Different From Filename')
        end
        
        it 'falls back to filename when no frontmatter title' do
          simple_note = result[:notes].find { |note| note[:path] == 'simple-note.md' }
          expect(simple_note[:title]).to eq('simple-note')
        end
      end
      
      describe 'tag handling' do
        it 'includes tags when present' do
          tagged_note = result[:notes].find { |note| note[:path] == 'tagged-note.md' }
          expect(tagged_note[:tags]).to contain_exactly('project', 'important', 'work')
        end
        
        it 'returns empty array when no tags' do
          no_tags_note = result[:notes].find { |note| note[:path] == 'no-tags.md' }
          expect(no_tags_note[:tags]).to eq([])
        end
        
        it 'handles notes without frontmatter' do
          simple_note = result[:notes].find { |note| note[:path] == 'simple-note.md' }
          expect(simple_note[:tags]).to eq([])
        end
      end
      
      describe 'subdirectory handling' do
        let(:subdir_note) { result[:notes].find { |note| note[:path] == 'projects/project-alpha.md' } }
        
        it 'includes notes from subdirectories' do
          expect(subdir_note).not_to be_nil
        end
        
        it 'uses correct relative path' do
          expect(subdir_note[:path]).to eq('projects/project-alpha.md')
        end
        
        it 'processes frontmatter correctly in subdirectories' do
          expect(subdir_note[:title]).to eq('Project Alpha')
          expect(subdir_note[:tags]).to contain_exactly('project', 'alpha', 'active')
        end
      end
      
      describe 'edge cases' do
        it 'handles empty notes' do
          empty_note = result[:notes].find { |note| note[:path] == 'empty-note.md' }
          expect(empty_note).not_to be_nil
          expect(empty_note[:word_count]).to eq(0)
          expect(empty_note[:tags]).to eq([])
          expect(empty_note[:title]).to eq('empty-note')
        end
        
        it 'handles notes with only frontmatter' do
          frontmatter_only = result[:notes].find { |note| note[:path] == 'frontmatter-only.md' }
          expect(frontmatter_only).not_to be_nil
          expect(frontmatter_only[:title]).to eq('Frontmatter Only Note')
          expect(frontmatter_only[:tags]).to contain_exactly('meta')
          expect(frontmatter_only[:word_count]).to eq(0)
        end
        
        it 'handles malformed frontmatter gracefully' do
          malformed_note = result[:notes].find { |note| note[:path] == 'malformed-frontmatter.md' }
          expect(malformed_note).not_to be_nil
          expect(malformed_note[:title]).to eq('malformed-frontmatter') # Falls back to filename
          expect(malformed_note[:tags]).to eq([])
        end
        
        it 'handles special characters correctly' do
          special_note = result[:notes].find { |note| note[:path] == 'special-chars.md' }
          expect(special_note).not_to be_nil
          expect(special_note[:title]).to eq('Special Characters: Émojis 🚀 & Symbols ™️')
          expect(special_note[:tags]).to contain_exactly('unicode', 'special-chars')
        end
      end
    end
    
    context 'with include_tags: false' do
      let(:result) { tool.call(include_tags: false) }
      
      it 'returns the same top-level structure' do
        expect(result).to be_a(Hash)
        expect(result).to have_key(:total_notes)
        expect(result).to have_key(:vault_path)
        expect(result).to have_key(:notes)
      end
      
      it 'returns the same number of notes' do
        expect(result[:total_notes]).to eq(11)
        expect(result[:notes].length).to eq(11)
      end
      
      it 'excludes tags from all notes' do
        result[:notes].each do |note|
          expect(note).not_to have_key(:tags)
        end
      end
      
      it 'still includes all other fields' do
        sample_note = result[:notes].first
        expect(sample_note).to have_key(:path)
        expect(sample_note).to have_key(:title)
        expect(sample_note).to have_key(:word_count)
        expect(sample_note).to have_key(:modified)
      end
      
      it 'maintains the same sorting order' do
        with_tags_result = tool.call(include_tags: true)
        without_tags_titles = result[:notes].map { |note| note[:title] }
        with_tags_titles = with_tags_result[:notes].map { |note| note[:title] }
        
        expect(without_tags_titles).to eq(with_tags_titles)
      end
    end
    
    context 'with explicit include_tags: true' do
      let(:result) { tool.call(include_tags: true) }
      
      it 'behaves the same as default behavior' do
        default_result = tool.call
        expect(result).to eq(default_result)
      end
    end
  end
  
  describe 'performance and scalability' do
    it 'processes notes efficiently' do
      start_time = Time.now
      result = tool.call
      end_time = Time.now
      
      expect(result[:total_notes]).to be > 0
      expect(end_time - start_time).to be < 1.0 # Should complete within 1 second
    end
    
    it 'produces consistent results across multiple calls' do
      result1 = tool.call
      result2 = tool.call
      
      expect(result1).to eq(result2)
    end
  end
  
  describe 'error handling' do
    context 'when vault path does not exist' do
      before do
        ObsidianMcp::Config.vault_path = '/nonexistent/path'
      end
      
      it 'raises an appropriate error' do
        expect { tool.call }.to raise_error(ArgumentError, /Vault path does not exist/)
      end
    end
    
    context 'when vault path is not readable' do
      let(:unreadable_vault_dir) { Dir.mktmpdir('unreadable_vault') }
      
      before do
        # Create the directory but make it unreadable
        File.chmod(0000, unreadable_vault_dir)
        ObsidianMcp::Config.vault_path = unreadable_vault_dir
      end
      
      after do
        # Restore permissions and clean up
        File.chmod(0755, unreadable_vault_dir)
        FileUtils.remove_entry(unreadable_vault_dir)
      end
      
      # Note: This test might behave differently on different systems
      it 'handles permission errors gracefully', skip: 'May not work on all systems' do
        expect { tool.call }.to raise_error
      end
    end
  end
  
  describe 'integration with vault model' do
    it 'uses the configured vault properly' do
      expect(vault).to be_an_instance_of(ObsidianMcp::Models::Vault)
      expect(vault.vault_path.to_s).to eq(test_vault_dir)
    end
    
    it 'discovers all markdown files in vault' do
      markdown_files = vault.notes_glob
      expect(markdown_files.length).to eq(11)
      
      result = tool.call
      expect(result[:total_notes]).to eq(markdown_files.length)
    end
  end
end
