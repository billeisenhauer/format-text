# frozen_string_literal: true

module FormatText
  # Greedily wraps whitespace-separated words onto lines no longer than
  # `width`, breaking at the closest previous word boundary. A single word
  # longer than `width` is left intact, alone on its own (too-long) line --
  # since wrapping only ever breaks between words, this falls out naturally
  # rather than needing special-case handling.
  class LineWrapper
    DEFAULT_WIDTH = 80

    def self.call(text, width: DEFAULT_WIDTH)
      new(text, width: width).call
    end

    def initialize(text, width:)
      @words = text.split
      @width = width
    end

    def call
      lines = []
      current = nil

      words.each { |word| current = accumulate(lines, current, word) }
      lines << current

      # current stays nil for empty input; join stringifies nil as "", so
      # this needs no separate empty-input guard.
      lines.join("\n")
    end

    private

    attr_reader :words, :width

    def accumulate(lines, current, word)
      return word if current.nil?

      if fits?(current, word)
        "#{current} #{word}"
      else
        lines << current
        word
      end
    end

    def fits?(current, word)
      current.length + 1 + word.length <= width
    end
  end
end
