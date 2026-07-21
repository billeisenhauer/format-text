# frozen_string_literal: true

require_relative "../../test_helper"

module FormatText
  class FormatterTest < Minitest::Test
    include ChallengeExample

    cover "FormatText::Formatter"

    def test_returns_empty_string_for_empty_input
      assert_equal "", Formatter.call("")
    end

    def test_wraps_a_single_paragraph_at_eighty_characters
      long_word = "a" * 40
      result = Formatter.call("#{long_word} #{long_word}")

      assert_equal "#{long_word}\n#{long_word}", result
    end

    def test_separates_paragraphs_with_exactly_one_blank_line
      result = Formatter.call("first paragraph\n\nsecond paragraph")

      assert_equal "first paragraph\n\nsecond paragraph", result
    end

    def test_collapses_multiple_blank_lines_between_paragraphs_into_one
      result = Formatter.call("first paragraph\n\n\n\n\nsecond paragraph")

      assert_equal "first paragraph\n\nsecond paragraph", result
    end

    def test_collapses_runs_of_spaces_within_a_paragraph
      result = Formatter.call("This      is a second paragraph with extraneous whitespace.")

      assert_equal "This is a second paragraph with extraneous whitespace.", result
    end

    def test_leaves_a_single_word_longer_than_eighty_characters_intact_within_a_paragraph
      long_word = "a" * 90
      result = Formatter.call("short words #{long_word} more words")

      assert_equal "short words\n#{long_word}\nmore words", result
    end

    def test_matches_the_challenge_worked_example_exactly
      assert_equal challenge_expected_output, Formatter.call(challenge_worked_example)
    end
  end
end
