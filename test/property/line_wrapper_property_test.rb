# frozen_string_literal: true

require_relative "../test_helper"
require "rantly/minitest_extensions"

module FormatText
  class LineWrapperPropertyTest < Minitest::Test
    cover "FormatText::LineWrapper"

    # rubocop:disable Style/BlockDelimiters, Style/MultilineBlockChain
    # The braces-then-do-end chain is idiomatic for Rantly's
    # `property_of { generator }.check { |value| assertion }` DSL.
    def test_no_line_exceeds_the_width_unless_it_is_a_single_unbreakable_word
      property_of {
        sized(range(0, 500)) { string(:print) }
      }.check do |content|
        LineWrapper.call(content).each_line(chomp: true) { |line| assert_wrapped_line(line) }
      end
    end

    def test_every_word_survives_in_order
      property_of {
        sized(range(0, 500)) { string(:print) }
      }.check do |content|
        assert_equal content.split, LineWrapper.call(content).split
      end
    end
    # rubocop:enable Style/BlockDelimiters, Style/MultilineBlockChain

    private

    def assert_wrapped_line(line)
      assert(
        line.length <= LineWrapper::DEFAULT_WIDTH || !line.include?(" "),
        "expected #{line.inspect} to wrap at #{LineWrapper::DEFAULT_WIDTH} " \
        "characters or be left as a single unbreakable word"
      )
    end
  end
end
