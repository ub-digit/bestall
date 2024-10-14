source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '7.2.1'

# Use Puma as the app server
gem 'puma', '~> 3.0'

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

gem 'pg'
gem 'jquery-rails'
gem "rest-client", '~> 2.0.1'
gem 'prawn'
gem 'barby'
gem 'rack-cors'
gem 'jwt'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platform: :mri
  gem 'listen', '~> 3.0.5'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  #gem 'spring'
  #gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'rspec-rails', '~> 3.5'
  gem 'factory_bot_rails'
  gem 'database_cleaner'
end

group :test do
  gem 'webmock'
  gem 'shoulda'
end

group :development do
end
