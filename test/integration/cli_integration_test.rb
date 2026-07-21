# frozen_string_literal: true

require_relative "../test_helper"
require "open3"

module FormatText
  class CLIIntegrationTest < Minitest::Test
    include TempFileHelper

    # No `cover` declaration: this test shells out to a fresh ruby process
    # (see BIN below), so it always exercises the unmutated code on disk and
    # can never kill a mutation. Leaving it out of mutant's subject coverage
    # avoids wasted subprocess spawns during `rake test:mutation`.
    BIN = File.expand_path("../../bin/format-text", __dir__)

    def test_running_the_executable_prints_file_contents
      with_temp_file("hello from the CLI\n") do |path|
        stdout, stderr, status = Open3.capture3(RbConfig.ruby, BIN, path)

        assert_equal "hello from the CLI\n", stdout
        assert_empty stderr
        assert_predicate status, :success?
      end
    end

    def test_running_the_executable_wraps_long_lines
      long_word = "a" * 40
      with_temp_file("#{long_word} #{long_word}") do |path|
        stdout, _stderr, = Open3.capture3(RbConfig.ruby, BIN, path)

        assert_equal "#{long_word}\n#{long_word}\n", stdout
      end
    end

    def test_running_the_executable_without_arguments_fails_with_usage
      stdout, stderr, status = Open3.capture3(RbConfig.ruby, BIN)

      assert_empty stdout
      assert_equal "usage: format-text FILENAME\n", stderr
      refute_predicate status, :success?
    end

    def test_running_the_executable_against_a_missing_file_reports_an_error
      stdout, stderr, status = Open3.capture3(RbConfig.ruby, BIN, "/no/such/file.txt")

      assert_empty stdout
      assert_equal "format-text: no such file -- /no/such/file.txt\n", stderr
      refute_predicate status, :success?
    end
  end
end
