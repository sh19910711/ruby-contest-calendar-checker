source 'https://rubygems.org'

ruby '2.0.0'

group :production, :development do
  gem 'mechanize'
  gem 'nokogiri'
  gem 'sinatra'
end

group :test do
  gem 'rake'
  gem 'rspec'
  gem 'rack-test', require: 'rack/test'
  gem 'webmock'

  gem 'spork'
  gem 'simplecov', require: false
  gem 'simplecov-rcov'
  gem 'ci_reporter'
end

