# format-text

This repository is a take-home test challenge. See [CHALLENGE.md](CHALLENGE.md) for the full
requirements.

## Setup

Requires Ruby 4.0 (see `.ruby-version`). If your `ruby` resolves to something older, install a
current Ruby (e.g. `brew install ruby`) and put it on your `PATH` ahead of the system Ruby.

```sh
bundle install
```

## Running the CLI

```sh
bin/format-text some-file.txt
bin/format-text --help   # or -h
```

`bin/format-text` implements all five formatting rules from `CHALLENGE.md`: 80-column word wrap
with the long-word exception, paragraph splitting on blank lines with exactly one blank line
between paragraphs in the output, and collapsing runs of spaces or blank lines to a single one.
Output matches `CHALLENGE.md`'s worked example exactly (pinned by a test). `--help`/`-h` prints
usage plus a summary of those rules and exits successfully; it takes precedence over any other
arguments, and running with no arguments at all still shows the plain usage error (exit 1), not
help. This is delivered following a "make it work, make it right, make it fast" / skateboard-to-car
approach; see the [wiki Roadmap](https://github.com/billeisenhauer/format-text/wiki/Roadmap) for
current status:

1. **Skateboard** -- a working, no-op CLI with the full test harness in place. ✅
2. **Bicycle** -- basic word-wrapping at 80 characters. ✅
3. **Motorcycle** -- full correctness: long-word exception, paragraph blank lines, whitespace
   collapsing. ✅
4. **Car** -- refactor for clarity and performance once the behavior is fully correct. ✅
5. **Limousine** -- `--help` text that documents usage and the formatting rules. ✅

## Testing

```sh
bundle exec rake test            # unit + CLI integration + property-based tests
bundle exec rake test:unit       # unit tests only
bundle exec rake test:integration
bundle exec rake test:property
bundle exec rake test:mutation   # mutation testing (see below)
bundle exec rake lint            # rubocop
bundle exec rake crap            # coverage + CRAP score analysis (see below)
```

`rake test` (the default rake task) is the fast inner-loop suite:

- **Unit tests** (`test/unit`) exercise `FormatText::CLI`, `FormatText::LineWrapper`,
  `FormatText::ParagraphSplitter`, and `FormatText::Formatter` directly, in-process --
  including a test pinned to `CHALLENGE.md`'s worked example, matched byte-for-byte.
- **CLI integration tests** (`test/integration`) shell out to the real `bin/format-text`
  executable via `Open3` and assert on stdout/stderr/exit status end-to-end.
- **Property-based tests** (`test/property`, using [rantly](https://github.com/rantly-rb/rantly))
  generate hundreds of random inputs to check invariants that should hold for *any* input, not
  just the examples in `CHALLENGE.md` -- targeted at `LineWrapper` and `Formatter` directly, since
  that's where the actual logic (and therefore the interesting edge cases) lives. Current
  invariants: no output line exceeds 80 characters unless it's a single unbreakable word; every
  word from the input survives, in order; paragraphs survive in order separated by exactly one
  blank line; and runs of spaces within a paragraph collapse to one.

### Mutation testing

```sh
bundle exec rake test:mutation
```

Uses [mutant](https://github.com/mbj/mutant) to mutate `lib/` and confirm the test suite actually
kills each mutation (rather than just achieving line coverage without asserting behavior).
`.mutant.yml` declares `usage: opensource`, which is free with no signup because this is a public
open-source repository -- see mutant's
[configuration docs](https://github.com/mbj/mutant/blob/main/docs/configuration.md) if that ever
changes. Test classes that exercise a `FormatText` class in-process declare a matching `cover`
(e.g. `cover "FormatText::LineWrapper"`) so mutant knows which tests to run per subject; the CLI
integration tests deliberately omit this, since they shell out to a fresh Ruby process and can
never observe an in-process mutation.

Not every mutation is killable: `ParagraphSplitter`'s blank-line check (`line.strip.empty?`) has
mutations to `.lstrip`/`.rstrip` that survive, because for the purpose of "is this string entirely
whitespace," `strip`, `lstrip`, and `rstrip` are mathematically equivalent -- if any non-whitespace
character exists, it survives all three; if none exists, all three go empty. This is a genuine
instance of the well-known "equivalent mutant problem" in mutation testing, not a coverage gap
(currently 2 of 339 mutations); see
[Testing Strategy](https://github.com/billeisenhauer/format-text/wiki/Testing-Strategy) for the
full reasoning.

### Coverage and CRAP analysis

```sh
bundle exec rake crap
```

Runs the full suite in a single process to collect [SimpleCov](https://github.com/simplecov-ruby/simplecov)
line coverage, combines it with per-method cyclomatic complexity from RuboCop, and prints a
[CRAP](https://testing.googleblog.com/2011/02/this-post-is-modified-version-of-post.html) (Change
Risk Anti-Patterns) score per method:

```
CRAP = complexity^2 * (1 - coverage)^3 + complexity
```

| CRAP score | Risk           |
|-----------:|----------------|
| ≤ 5        | Excellent      |
| 6–10       | Reasonable     |
| 11–20      | Worth reviewing|
| 21–30      | High risk      |
| > 30       | Unacceptable   |

The task fails (non-zero exit) if any method exceeds the threshold (default 30, override with
`CRAP_MAX`). There's no actively maintained CRAP gem for Ruby, so `script/crap_report.rb`
hand-rolls this from RuboCop's `Metrics/CyclomaticComplexity` cop output plus the SimpleCov
resultset.
