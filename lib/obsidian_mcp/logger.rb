require 'semantic_logger'

SemanticLogger.default_level = :debug
SemanticLogger.add_appender(io: STDERR)

$log = SemanticLogger['obsidian-mcp']
