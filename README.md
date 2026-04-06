# ClaudeConsole

Chat with Claude AI directly inside your Rails console, with automatic Rails context.

## Installation

```ruby
group :development do
  gem "claude_console"
end
```

## Configuration

```bash
export ANTHROPIC_API_KEY=sk-ant-...
```

## Usage

```ruby
claude "find users who signed up in the last 7 days"
claude_run! "how many orders are in pending state?"
claude_load_model User
claude_load_file "app/services/billing_service.rb"
claude_history
claude_reset!
```

See the full documentation at https://github.com/npendery/rails-claude-console
