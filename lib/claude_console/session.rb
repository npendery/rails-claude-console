require "anthropic"

module ClaudeConsole
  class Session
    attr_reader :history

    def initialize
      @config  = ClaudeConsole.configuration
      @client  = Anthropic::Client.new(api_key: @config.api_key)
      @history = []
    end

    def ask(message)
      @history << { role: "user", content: message }

      response = @client.messages.create(
        model:      @config.model,
        max_tokens: @config.max_tokens,
        system:     @config.system_prompt,
        messages:   @history
      )

      reply = response.content.first.text
      @history << { role: "assistant", content: reply }
      pretty_print(reply)
      nil
    end

    def ask_and_run(message, max_iterations: 3)
      @history << { role: "user", content: message }

      max_iterations.times do
        response = @client.messages.create(
          model:      @config.model,
          max_tokens: @config.max_tokens,
          system:     @config.system_prompt,
          messages:   @history
        )

        reply = response.content.first.text
        @history << { role: "assistant", content: reply }
        pretty_print(reply)

        code = extract_code(reply)
        break unless code

        run_label = @config.safe_mode? ? "\e[33m🔒 Running (safe mode):\e[0m" : "\e[33m⚡ Running:\e[0m"
        puts "#{run_label}\n#{code}\n"
        result = safe_eval(code)
        puts "\e[32m⮕ Result:\e[0m #{result}\n\n"

        @history << { role: "user", content: "Result of running that code: #{result}" }
      end

      nil
    end

    def load_model(model)
      klass = model.is_a?(Class) ? model : model.to_s.constantize
      path  = source_path_for(klass)
      raise "Could not find source file for #{klass}" unless path && File.exist?(path)
      inject_file(path, label: "Model: #{klass}")
    end

    def load_file(path)
      full_path = Rails.root.join(path)
      raise "File not found: #{full_path}" unless File.exist?(full_path)
      inject_file(full_path, label: path)
    end

    def reset!
      @history = []
      puts "→ Conversation history cleared."
      nil
    end

    def show_history
      if @history.empty?
        puts "No conversation history yet."
      else
        @history.each do |msg|
          label = msg[:role] == "user" ? "\e[36mYou\e[0m" : "\e[35mClaude\e[0m"
          puts "\n#{label}: #{msg[:content]}"
        end
      end
      nil
    end

    private

    def inject_file(path, label:)
      content = File.read(path)
      notice  = "I'm sharing this file for context — #{label}:\n\n```ruby\n#{content}\n```"
      @history << { role: "user", content: notice }
      puts "\e[36m→ Loaded #{label} into conversation context.\e[0m"
      puts "  Ask Claude about it: claude \"explain this model\" or claude \"find N+1 issues\"\n\n"
      nil
    end

    def extract_code(text)
      text[/```ruby\n(.*?)```/m, 1] || text[/```\n(.*?)```/m, 1]
    end

    def safe_eval(code)
      if @config.safe_mode?
        safe_eval_readonly(code)
      else
        result = eval(code) # rubocop:disable Security/Eval
        result.inspect
      end
    rescue StandardError => e
      err = "#{e.class}: #{e.message}"
      @history << { role: "user", content: "That code raised an error: #{err}" }
      "\e[31mError — #{err}\e[0m"
    end

    def safe_eval_readonly(code)
      output = nil
      ActiveRecord::Base.transaction do
        output = eval(code).inspect # rubocop:disable Security/Eval
        raise ActiveRecord::Rollback
      end
      output
    end

    def source_path_for(klass)
      m = klass.instance_methods(false).first
      if m
        file, = klass.instance_method(m).source_location
        return file if file
      end
      Rails.root.join("app", "models", "#{klass.name.underscore}.rb").to_s
    end

    def pretty_print(text)
      puts "\n\e[35mClaude:\e[0m #{text}\n\n"
    end
  end
end
