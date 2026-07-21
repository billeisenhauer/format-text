# frozen_string_literal: true

require_relative "../../test_helper"

module FormatText
  class CLITest < Minitest::Test
    include TempFileHelper

    cover "FormatText::CLI"

    def test_prints_formatted_file_contents_to_stdout
      with_temp_file("hello world") do |path|
        stdout = StringIO.new

        status = CLI.run([path], stdout: stdout, stderr: StringIO.new)

        assert_equal "hello world\n", stdout.string
        assert_equal CLI::SUCCESS, status
      end
    end

    def test_wraps_lines_longer_than_eighty_characters
      long_word = "a" * 40
      with_temp_file("#{long_word} #{long_word}") do |path|
        stdout = StringIO.new

        CLI.run([path], stdout: stdout, stderr: StringIO.new)

        assert_equal "#{long_word}\n#{long_word}\n", stdout.string
      end
    end

    def test_defaults_to_the_global_stdout
      with_temp_file("hello world") do |path|
        out, err = capture_io { CLI.run([path]) }

        assert_equal "hello world\n", out
        assert_empty err
      end
    end

    def test_defaults_to_the_global_stderr
      _out, err = capture_io { CLI.run([]) }

      assert_equal "usage: format-text FILENAME\n", err
    end

    def test_reports_usage_when_no_filename_given
      stderr = StringIO.new

      status = CLI.run([], stdout: StringIO.new, stderr: stderr)

      assert_equal "usage: format-text FILENAME\n", stderr.string
      assert_equal CLI::FAILURE, status
    end

    def test_reports_error_when_file_does_not_exist
      stderr = StringIO.new

      status = CLI.run(["/no/such/file.txt"], stdout: StringIO.new, stderr: stderr)

      assert_equal "format-text: no such file -- /no/such/file.txt\n", stderr.string
      assert_equal CLI::FAILURE, status
    end
  end
end
