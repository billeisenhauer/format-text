# frozen_string_literal: true

module FormatText
  # Splits text into paragraphs: runs of consecutive non-blank lines,
  # separated by one or more blank (or whitespace-only) lines. Runs of
  # multiple blank lines collapse to a single paragraph boundary, and
  # leading/trailing blank lines produce no empty paragraphs.
  class ParagraphSplitter
    def self.call(text)
      text.each_line(chomp: true)
          .chunk { |line| line.strip.empty? }
          .reject { |blank, _lines| blank }
          .map { |_blank, lines| lines.join("\n") }
    end
  end
end
