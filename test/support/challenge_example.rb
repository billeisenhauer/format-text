# frozen_string_literal: true

# The worked example from CHALLENGE.md, shared by any test that pins output
# to it exactly (currently FormatterTest and CLIIntegrationTest).
module ChallengeExample
  def challenge_worked_example
    <<~TEXT
      This is
      a badly formatted file. This line is pretty long! It's way more than 80 characters! I feel a
      line wrap coming on!

      This      is a second paragraph with extraneous whitespace.
    TEXT
  end

  def challenge_expected_output
    <<~TEXT.chomp
      This is a badly formatted file. This line is pretty long! It's way more than 80
      characters! I feel a line wrap coming on!

      This is a second paragraph with extraneous whitespace.
    TEXT
  end
end
