source 'https://rubygems.org'

# Core Rails
gem 'rails', '~> 8.1.2'

# Web server (Vercel uses Rack, but keep puma for local dev)
gem 'puma', '>= 5.0'

# API building
gem 'jbuilder'

# HTTP client
gem 'faraday'

# Required dependencies
gem 'public_suffix', '~> 6.0.2'
gem 'net-imap', '~> 0.5.8'

# IMPORTANT: Use older psych to avoid native extension build issues on Vercel
gem 'psych', '< 5.0' # or remove entirely, Rails will use bundled version

# Timezone data for non-Unix platforms
gem 'tzinfo-data', platforms: %i[ windows jruby ]

# Boot optimization
gem 'bootsnap', require: false

# Environment variables (only needed for local dev, but harmless in prod)
gem 'dotenv', require: 'dotenv/load'

# Rack (required for Vercel)
gem 'rack'

group :development, :test do
  gem 'apipie-rails'
  gem 'debug', platforms: %i[ mri windows ], require: 'debug/prelude'
  gem 'brakeman', require: false
  gem 'rubocop-rails-omakase', require: false
  gem 'rubocop-rspec'
  gem 'ruby-lsp'
  gem 'rspec-rails', '~> 6.0.0'
  gem 'webmock'
  gem 'rspec-expectations', '~> 3.13.4'
  gem 'rspec-mocks', '~> 3.13.3'
  gem 'rspec-support', '~> 3.13.3'
  gem 'sqlite3'
end

group :development do
  gem 'web-console'
end

group :test do
  gem 'capybara'
  gem 'selenium-webdriver', '~> 4.32.0'
end
