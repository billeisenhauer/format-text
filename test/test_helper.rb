# frozen_string_literal: true

require "simplecov"
SimpleCov.start do
  add_filter "/test/"
end

require "minitest/autorun"
require "mutant/minitest/coverage"
require "stringio"
require "tempfile"

require_relative "support/temp_file_helper"
require_relative "../lib/format_text"
