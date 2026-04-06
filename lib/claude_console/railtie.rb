module ClaudeConsole
  class Railtie < Rails::Railtie
    console do
      Rails.application.eager_load!

      session = ClaudeConsole::Session.new

      Object.define_method(:claude)            { |msg|   session.ask(msg) }
      Object.define_method(:claude_run!)       { |msg, **opts| session.ask_and_run(msg, **opts) }
      Object.define_method(:claude_load_model) { |model| session.load_model(model) }
      Object.define_method(:claude_load_file)  { |path|  session.load_file(path) }
      Object.define_method(:claude_reset!)     { session.reset! }
      Object.define_method(:claude_history)    { session.show_history }
      Object.define_method(:claude_session)    { session }
      Object.define_method(:claude_safe_mode!) { |enabled = true| session.set_safe_mode(enabled) }
      Object.define_method(:claude_unsafe_mode!) { session.set_safe_mode(false) }

      mode = ClaudeConsole.configuration.safe_mode? ? "\e[32m(safe mode)\e[0m" : "\e[33m(unrestricted)\e[0m"
      puts "\e[35m✦ ClaudeConsole ready.\e[0m #{mode}"
      puts "  \e[36mclaude\e[0m \"question\"           — chat"
      puts "  \e[36mclaude_run!\e[0m \"question\"       — chat + auto-eval code"
      puts "  \e[36mclaude_load_model\e[0m User         — load a model for analysis"
      puts "  \e[36mclaude_load_file\e[0m \"path/to/f\" — load any file for analysis"
      puts "  \e[36mclaude_safe_mode!\e[0m / \e[36mclaude_unsafe_mode!\e[0m"
      puts "  \e[36mclaude_history\e[0m / \e[36mclaude_reset!\e[0m\n\n"
    end
  end
end
