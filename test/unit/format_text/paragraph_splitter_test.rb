# frozen_string_literal: true

require_relative "../../test_helper"

module FormatText
  class ParagraphSplitterTest < Minitest::Test
    cover "FormatText::ParagraphSplitter"

    def test_returns_no_paragraphs_for_empty_input
      assert_equal [], ParagraphSplitter.call("")
    end

    def test_returns_no_paragraphs_for_whitespace_only_input
      assert_equal [], ParagraphSplitter.call("\n\n   \n\t\n")
    end

    def test_a_single_line_is_a_single_paragraph
      assert_equal ["hello world"], ParagraphSplitter.call("hello world")
    end

    def test_lines_with_no_blank_line_between_them_are_one_paragraph
      result = ParagraphSplitter.call("line one\nline two\nline three")

      assert_equal ["line one\nline two\nline three"], result
    end

    def test_a_single_blank_line_separates_two_paragraphs
      result = ParagraphSplitter.call("first paragraph\n\nsecond paragraph")

      assert_equal ["first paragraph", "second paragraph"], result
    end

    def test_multiple_consecutive_blank_lines_still_separate_exactly_two_paragraphs
      result = ParagraphSplitter.call("first paragraph\n\n\n\n\nsecond paragraph")

      assert_equal ["first paragraph", "second paragraph"], result
    end

    def test_a_whitespace_only_line_counts_as_a_blank_line
      result = ParagraphSplitter.call("first paragraph\n   \t \nsecond paragraph")

      assert_equal ["first paragraph", "second paragraph"], result
    end

    def test_leading_and_trailing_blank_lines_are_dropped
      result = ParagraphSplitter.call("\n\nonly paragraph\n\n")

      assert_equal ["only paragraph"], result
    end

    def test_three_paragraphs_round_trip
      result = ParagraphSplitter.call("one\n\ntwo\n\nthree")

      assert_equal %w[one two three], result
    end
  end
end
