# frozen_string_literal: true

require_relative "../test_helper"
require "rantly/minitest_extensions"

module FormatText
  class FormatterPropertyTest < Minitest::Test
    cover "FormatText::Formatter"

    # rubocop:disable Style/BlockDelimiters, Style/MultilineBlockChain
    # The braces-then-do-end chain is idiomatic for Rantly's
    # `property_of { generator }.check { |value| assertion }` DSL. Generator
    # blocks run instance_eval'd against a Rantly instance, so they can only
    # call Rantly's own primitives (array/range/sized/string) -- not private
    # test methods -- which is why paragraph/word generation is inlined
    # rather than extracted.

    # rubocop:disable Metrics/AbcSize
    # The nested array/range/sized/string generator combinators (paragraphs
    # of words, each word sized) inherently trip this on a plain line count;
    # it isn't sloppy code, it's what generating structured random input
    # looks like with Rantly.
    def test_paragraphs_survive_in_order_separated_by_exactly_one_blank_line
      property_of {
        paragraphs = array(range(1, 4)) {
          array(range(1, 4)) { sized(range(1, 8)) { string(:alpha) } }.join(" ")
        }
        [paragraphs, array(paragraphs.size - 1) { range(1, 4) }]
      }.check do |paragraphs, gaps|
        assert_equal paragraphs.join("\n\n"),
                     Formatter.call(join_with_blank_line_runs(paragraphs, gaps))
      end
    end
    # rubocop:enable Metrics/AbcSize

    def test_runs_of_spaces_within_a_paragraph_collapse_to_one
      property_of {
        words = array(range(1, 5)) { sized(range(1, 8)) { string(:alpha) } }
        gaps = array(words.size - 1) { range(2, 5) }
        [words, gaps]
      }.check do |words, gaps|
        input = join_with_space_runs(words, gaps)

        assert_equal words.join(" "), Formatter.call(input)
      end
    end

    def test_no_output_line_exceeds_the_width_unless_unbreakable
      property_of {
        array(range(1, 3)) {
          array(range(1, 4)) { sized(range(1, 8)) { string(:alpha) } }.join(" ")
        }
      }.check do |paragraphs|
        Formatter.call(paragraphs.join("\n\n")).each_line(chomp: true) do |line|
          assert_wrapped_line(line)
        end
      end
    end
    # rubocop:enable Style/BlockDelimiters, Style/MultilineBlockChain

    private

    def join_with_blank_line_runs(paragraphs, gaps)
      paragraphs.each_with_index.map do |paragraph, i|
        i.zero? ? paragraph : ("\n" * (gaps[i - 1] + 1)) + paragraph
      end.join
    end

    def join_with_space_runs(words, gaps)
      words.each_with_index.map do |word, i|
        i.zero? ? word : (" " * gaps[i - 1]) + word
      end.join
    end

    def assert_wrapped_line(line)
      assert(
        line.empty? || line.length <= LineWrapper::DEFAULT_WIDTH || !line.include?(" "),
        "expected #{line.inspect} to wrap at #{LineWrapper::DEFAULT_WIDTH} " \
        "characters or be left as a single unbreakable word"
      )
    end
  end
end
