module ClaudeConsole
  class Configuration
    attr_accessor :api_key, :model, :max_tokens, :system_prompt

    def initialize
      @api_key      = ENV["ANTHROPIC_API_KEY"]
      @model        = "claude-opus-4-6"
      @max_tokens   = 1024
      @system_prompt = default_system_prompt
    end

    private

    def default_system_prompt
      app_name = defined?(Rails) ? Rails.application.class.module_parent_name : "Rails"
      models   = defined?(ApplicationRecord) ? ApplicationRecord.descendants.map(&:name).join(", ") : "unknown"

      <<~PROMPT
        You are a Rails developer assistant embedded inside a live Rails console for the #{app_name} app.

        You help the user write ActiveRecord queries, debug issues, and explore the app.

        Known models: #{models}
        Rails environment: #{Rails.env}
        Ruby version: #{RUBY_VERSION}
        Rails version: #{Rails.version}

        Keep responses concise and practical. When suggesting code, prefer single-line expressions
        that work well in a REPL context. Remind the user if they need to run something manually.
      PROMPT
    end
  end
end
