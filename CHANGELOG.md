# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- **Semantic Logging**: Added `lib/obsidian_mcp/logger.rb` with semantic_logger integration for structured logging
- **Vault Model Tests**: Comprehensive test coverage for Vault model in `spec/models/vault_spec.rb`
- **Enhanced Docker Support**: Improved Docker run mode for better container deployment

### Changed
- **Tool Naming**: Updated MCP tool names for better Claude compatibility
- **Time Parsing**: Enhanced frontmatter time parsing in Vault model for better date/time handling
- **Test Structure**: Expanded test organization with dedicated model tests

### Fixed
- **Frontmatter Processing**: Improved reliability of time parsing in YAML frontmatter
- **Code Style**: Applied RuboCop linting fixes across codebase

### Technical Details

#### Architecture Changes
- **New Component**: `logger.rb` provides centralized semantic logging configuration
- **Enhanced Models**: `vault.rb` now includes robust time parsing for frontmatter dates
- **Test Expansion**: Added unit tests for Vault model alongside existing integration tests
- **Logging Integration**: All components now use structured logging via semantic_logger

#### Dependencies
- Added `semantic_logger` for structured logging capabilities
- Updated development tooling for better code quality enforcement

## Previous Versions

*This changelog was introduced with recent architectural improvements. Previous version history is available in git commit messages.*