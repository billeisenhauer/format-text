# frozen_string_literal: true

module FormatText
  # Entry point invoked by bin/format-text.
  class CLI
    SUCCESS = 0
    FAILURE = 1

    def self.run(argv, stdout: $stdout, stderr: $stderr)
      new(argv, stdout: stdout, stderr: stderr).run
    end

    def initialize(argv, stdout:, stderr:)
      @argv = argv
      @stdout = stdout
      @stderr = stderr
    end

    def run
      return usage_error if filename.nil?

      stdout.puts(LineWrapper.call(File.read(filename)))
      SUCCESS
    rescue Errno::ENOENT
      stderr.puts("format-text: no such file -- #{filename}")
      FAILURE
    end

    private

    attr_reader :argv, :stdout, :stderr

    def filename
      argv.first
    end

    def usage_error
      stderr.puts("usage: format-text FILENAME")
      FAILURE
    end
  end
end
