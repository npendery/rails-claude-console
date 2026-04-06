require_relative "lib/rails_claude/version"

Gem::Specification.new do |spec|
  spec.name        = "rails_claude"
  spec.version     = RailsClaude::VERSION
  spec.authors     = ["Nick Pendery"]
  spec.email       = ["npendery@homebot.ai"]
  spec.summary     = "Chat with Claude inside your Rails console"
  spec.description = "Provides an interactive Claude AI session directly in rails c, with Rails-aware context."
  spec.homepage    = "https://github.com/npendery/rails-claude-console"
  spec.license     = "MIT"

  spec.files            = Dir["lib/**/*", "README.md", "LICENSE.txt"]
  spec.require_paths    = ["lib"]

  spec.add_dependency "anthropic", ">= 0.3.0"
  spec.add_dependency "railties",  ">= 6.0"
end
