# frozen_string_literal: true

source "https://rubygems.org"

ruby file: ".ruby-version"

gem "rake", "~> 13.0"

group :test do
  gem "minitest", "~> 5.25"
  gem "mutant", "~> 0.16"
  gem "mutant-minitest", "~> 0.16"
  gem "rantly", "~> 3.0"
  gem "simplecov", "~> 0.22", require: false
end

group :lint do
  gem "rubocop", "~> 1.75", require: false
  gem "rubocop-minitest", "~> 0.38", require: false
end
