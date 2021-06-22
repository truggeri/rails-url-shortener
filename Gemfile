source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.0.0'

# Only include the pieces of Rails that we're using
# -- Begin rails
# gem 'rails', '~> 6.1.3', '>= 6.1.3.2'
gem 'actionpack', '~> 6.1.3', '>= 6.1.3.2'
gem 'activemodel', '~> 6.1.3', '>= 6.1.3.2'
gem 'activerecord', '~> 6.1.3', '>= 6.1.3.2'
gem 'activesupport', '~> 6.1.3', '>= 6.1.3.2'
gem 'bundler', '>= 1.15.0'
gem 'railties', '~> 6.1.3', '>= 6.1.3.2'
# -- End rails

gem 'annotate', require: false
gem 'bootsnap', '>= 1.4.4', require: false
gem 'jbuilder', '~> 2.7'
gem 'pg', '~> 1.1'
gem 'puma', '~> 5.0'

group :development, :test do
  gem 'pry'
  gem 'rspec'
  gem 'rspec-rails'
  gem 'rubocop'
  gem 'rubocop-rails'
  gem 'rubocop-rspec'
  gem 'simplecov'
end

group :development do
  gem 'listen', '~> 3.3'
  gem 'spring'
end

gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]
