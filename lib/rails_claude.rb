require "rails_claude/version"
require "rails_claude/configuration"
require "rails_claude/session"
require "rails_claude/railtie" if defined?(Rails)

module RailsClaude
  class << self
    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield(configuration)
    end
  end
end
