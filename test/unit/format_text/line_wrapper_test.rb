# frozen_string_literal: true

require_relative "../../test_helper"

module FormatText
  class LineWrapperTest < Minitest::Test
    cover "FormatText::LineWrapper"

    def test_returns_empty_string_for_empty_input
      assert_equal "", LineWrapper.call("")
    end

    def test_leaves_short_text_on_a_single_line
      assert_equal "hello world", LineWrapper.call("hello world", width: 20)
    end

    def test_wraps_when_the_next_word_would_exceed_the_width
      result = LineWrapper.call("one two three", width: 7)

      assert_equal "one two\nthree", result
    end

    def test_fits_a_word_exactly_at_the_width_boundary
      result = LineWrapper.call("aaa bb", width: 6)

      assert_equal "aaa bb", result
    end

    def test_wraps_a_word_one_character_past_the_width_boundary
      result = LineWrapper.call("aaa bbb", width: 6)

      assert_equal "aaa\nbbb", result
    end

    def test_leaves_a_single_word_longer_than_the_width_intact_on_its_own_line
      result = LineWrapper.call("supercalifragilisticexpialidocious", width: 10)

      assert_equal "supercalifragilisticexpialidocious", result
    end

    def test_treats_existing_newlines_and_whitespace_runs_as_ordinary_word_boundaries
      result = LineWrapper.call("one\n\n  two   three", width: 20)

      assert_equal "one two three", result
    end

    def test_defaults_to_an_eighty_character_width
      long_word = "a" * 40
      text = "#{long_word} #{long_word} x"

      result = LineWrapper.call(text)

      assert_equal "#{long_word}\n#{long_word} x", result
    end
  end
end
