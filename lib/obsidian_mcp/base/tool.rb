# frozen_string_literal: true

require 'fast_mcp'
require_relative '../models/vault'
require_relative '../models/note'

module ObsidianMcp
  module Base
    class Tool < FastMcp::Tool
      private

      def vault
        @vault ||= ObsidianMcp::Models::Vault.new
      end
    end
  end
end
