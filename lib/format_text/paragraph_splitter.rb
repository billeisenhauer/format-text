# frozen_string_literal: true

module FormatText
  # Splits text into paragraphs: runs of consecutive non-blank lines,
  # separated by one or more blank (or whitespace-only) lines. Runs of
  # multiple blank lines collapse to a single paragraph boundary, and
  # leading/trailing blank lines produce no empty paragraphs.
  class ParagraphSplitter
    def self.call(text)
      new(text).call
    end

    def initialize(text)
      @lines = text.each_line(chomp: true)
    end

    def call
      lines.each_with_object([[]]) { |line, paragraphs| accumulate(paragraphs, line) }
           .reject(&:empty?)
           .map { |paragraph_lines| paragraph_lines.join("\n") }
    end

    private

    attr_reader :lines

    def accumulate(paragraphs, line)
      if line.strip.empty?
        paragraphs << [] unless paragraphs.last.empty?
      else
        paragraphs.last << line
      end
    end
  end
end
