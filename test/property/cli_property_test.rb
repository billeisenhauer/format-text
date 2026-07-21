# frozen_string_literal: true

require_relative "../test_helper"
require "rantly/minitest_extensions"

module FormatText
  # While the CLI is a pass-through, the only invariant that holds for any
  # input is "output equals input". Once formatting rules are implemented,
  # this property evolves into checking output invariants instead (e.g. no
  # line exceeds 80 characters, no run of blank lines survives) rather than
  # strict identity.
  class CLIPropertyTest < Minitest::Test
    include TempFileHelper

    cover "FormatText::CLI"

    # rubocop:disable Style/BlockDelimiters, Style/MultilineBlockChain
    # The braces-then-do-end chain is idiomatic for Rantly's
    # `property_of { generator }.check { |value| assertion }` DSL.
    def test_output_matches_input_content_for_any_text
      property_of {
        sized(range(0, 500)) { string(:print) }
      }.check do |content|
        with_temp_file(content) do |path|
          stdout = StringIO.new

          CLI.run([path], stdout: stdout, stderr: StringIO.new)

          assert_equal content, stdout.string
        end
      end
    end
    # rubocop:enable Style/BlockDelimiters, Style/MultilineBlockChain
  end
end
