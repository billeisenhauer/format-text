# frozen_string_literal: true

module FormatText
  # Formats raw text into paragraphs per CHALLENGE.md: splits on blank-line
  # boundaries (ParagraphSplitter), wraps each paragraph independently at 80
  # columns (LineWrapper), and rejoins paragraphs with exactly one blank line.
  class Formatter
    def self.call(text)
      ParagraphSplitter.call(text)
                       .map { |paragraph| LineWrapper.call(paragraph) }
                       .join("\n\n")
    end
  end
end
