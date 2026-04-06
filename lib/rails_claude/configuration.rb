module RailsClaude
  class Configuration
    attr_accessor :api_key, :model, :max_tokens, :system_prompt, :safe_mode

    def initialize
      @api_key      = ENV["ANTHROPIC_API_KEY"]
      @model        = "claude-opus-4-6"
      @max_tokens   = 1024
      @safe_mode    = defined?(Rails) ? Rails.env.production? : true
      @system_prompt = nil # deferred until first access so safe_mode is settled
    end

    def system_prompt
      @system_prompt || default_system_prompt
    end

    def safe_mode?
      !!@safe_mode
    end

    private

    def default_system_prompt
      app_name = defined?(Rails) ? Rails.application.class.module_parent_name : "Rails"
      models   = defined?(ApplicationRecord) ? ApplicationRecord.descendants.map(&:name).join(", ") : "unknown"

      prompt = <<~PROMPT
        You are a Rails developer assistant embedded inside a live Rails console for the #{app_name} app.

        You help the user write ActiveRecord queries, debug issues, and explore the app.

        Known models: #{models}
        Rails environment: #{Rails.env}
        Ruby version: #{RUBY_VERSION}
        Rails version: #{Rails.version}

        Keep responses concise and practical. When suggesting code, prefer single-line expressions
        that work well in a REPL context. Remind the user if they need to run something manually.
      PROMPT

      if safe_mode?
        prompt += <<~SAFE

          IMPORTANT: Safe mode is ON. All executed code runs inside a read-only transaction
          that is automatically rolled back. Only generate read-only code — SELECT queries,
          inspections, and counts. Do NOT generate code that creates, updates, or deletes records,
          runs migrations, modifies files, or executes system commands. Any database writes will
          be rolled back and the user will be warned.
        SAFE
      end

      prompt
    end
  end
end
