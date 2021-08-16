source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.6.3'

gem 'rails',          '~> 6.1.4'
gem 'mysql2'
gem 'puma',           '~> 5.0'
gem 'sass-rails',     '>= 6'
gem 'webpacker',      '~> 5.0'
gem 'turbolinks',     '~> 5'
gem 'jbuilder',       '~> 2.7'
gem 'bootsnap',       '>= 1.4.4', require: false
gem 'bootstrap-sass', '3.4.1'
gem 'devise',         '>=4.7.1'
gem 'kaminari'

group :development, :test do
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'rspec-rails', '~> 4.0.1'
  gem 'factory_bot_rails'
  gem 'rails-controller-testing'
end

group :development do
  gem 'web-console',        '>= 4.1.0'
  gem 'rack-mini-profiler', '~> 2.0'
  gem 'listen',             '~> 3.3'
  gem 'spring'
end

group :test do
  gem 'capybara', '>= 3.26'
  gem 'selenium-webdriver'
  gem 'webdrivers'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
