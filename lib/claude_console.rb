require "claude_console/version"
require "claude_console/configuration"
require "claude_console/session"
require "claude_console/railtie" if defined?(Rails)

module ClaudeConsole
  class << self
    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield(configuration)
    end
  end
end
