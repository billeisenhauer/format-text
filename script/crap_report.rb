#!/usr/bin/env ruby
# frozen_string_literal: true

# Computes CRAP (Change Risk Anti-Patterns) scores for lib/ by combining:
#   - cyclomatic complexity per method, from RuboCop's Metrics/CyclomaticComplexity
#     cop (forced to report on every method by setting Max: 0 in a throwaway config)
#   - line coverage per method, from the SimpleCov resultset written by
#     `rake test:coverage`
#
# CRAP = complexity^2 * (1 - coverage)^3 + complexity
#
# There is no actively maintained CRAP gem for Ruby, so this hand-rolls the
# formula from the two data sources above rather than depending on either
# tool to compute it directly.

require "bundler/setup"
require "json"
require "tmpdir"

CRAP_MAX = Float(ENV.fetch("CRAP_MAX", "30"))
RESULTSET_PATH = File.join("coverage", ".resultset.json")

MESSAGE_PATTERN = %r{
  Cyclomatic\ complexity\ for\ `(?<method>[^`]+)`\ is\ too\ high\.\s*
  \[(?<complexity>\d+)/\d+\]
}x

def bucket_for(crap)
  return "Excellent" if crap <= 5
  return "Reasonable" if crap <= 10
  return "Worth reviewing" if crap <= 20
  return "High risk" if crap <= 30

  "Unacceptable"
end

def crap_score(complexity, coverage_ratio)
  ((complexity**2) * ((1 - coverage_ratio)**3)) + complexity
end

# --- Coverage ---------------------------------------------------------

def merge_line_hits(existing_hits, new_hits)
  existing_hits.zip(new_hits).map do |old_hit, new_hit|
    next old_hit if new_hit.nil?
    next new_hit if old_hit.nil?

    [old_hit, new_hit].max
  end
end

def record_coverage(files, path, hits)
  files[path] = files.key?(path) ? merge_line_hits(files[path], hits) : hits
end

def require_resultset!
  return if File.exist?(RESULTSET_PATH)

  abort "No coverage data found at #{RESULTSET_PATH}. Run `rake test:coverage` first."
end

def coverage_by_file
  require_resultset!

  resultset = JSON.parse(File.read(RESULTSET_PATH))
  files = {}

  resultset.each_value do |run|
    run.fetch("coverage").each do |path, data|
      hits = data.is_a?(Hash) ? data.fetch("lines") : data
      record_coverage(files, File.expand_path(path), hits)
    end
  end

  files
end

def coverage_ratio(hits, first_line, last_line)
  segment = (hits || [])[(first_line - 1)..(last_line - 1)] || []
  relevant = segment.compact
  return 1.0 if relevant.empty?

  relevant.count(&:positive?) / relevant.size.to_f
end

# --- Complexity ---------------------------------------------------------

def write_crap_rubocop_config(dir)
  config_path = File.join(dir, "crap_rubocop.yml")
  File.write(config_path, <<~YAML)
    inherit_from: #{File.expand_path('.rubocop.yml')}
    Metrics/CyclomaticComplexity:
      Max: 0
  YAML
  config_path
end

def run_rubocop_complexity_report(config_path)
  json = `bundle exec rubocop --format json --only Metrics/CyclomaticComplexity -c #{config_path} lib`
  JSON.parse(json)
end

def offense_to_complexity(offense, path)
  match = MESSAGE_PATTERN.match(offense.fetch("message"))
  return unless match

  location = offense.fetch("location")
  {
    file: path,
    method: match[:method],
    complexity: Integer(match[:complexity]),
    first_line: location.fetch("start_line"),
    last_line: location.fetch("last_line")
  }
end

def complexities_for_file(file)
  path = File.expand_path(file.fetch("path"))
  file.fetch("offenses").filter_map { |offense| offense_to_complexity(offense, path) }
end

def complexity_offenses
  Dir.mktmpdir do |dir|
    config_path = write_crap_rubocop_config(dir)
    report = run_rubocop_complexity_report(config_path)

    report.fetch("files").flat_map { |file| complexities_for_file(file) }
  end
end

# --- Report ---------------------------------------------------------

def crap_entry(offense, coverage)
  hits = coverage[offense[:file]]
  ratio = coverage_ratio(hits, offense[:first_line], offense[:last_line])
  crap = crap_score(offense[:complexity], ratio)

  offense.merge(coverage: ratio, crap: crap, bucket: bucket_for(crap))
end

def build_report
  coverage = coverage_by_file
  entries = complexity_offenses.map { |offense| crap_entry(offense, coverage) }
  entries.sort_by { |entry| -entry[:crap] }
end

HEADER_FORMAT = "%-45<file>s %-20<method>s %5<line>s %6<complexity>s %8<coverage>s %6<crap>s  %<risk>s"
ROW_FORMAT    = "%-45<file>s %-20<method>s %5<line>d %6<complexity>d %7<coverage>.1f%%  %6<crap>.2f  %<risk>s"

def print_entry(entry)
  puts format(
    ROW_FORMAT,
    file: entry[:file].sub("#{Dir.pwd}/", ""),
    method: entry[:method],
    line: entry[:first_line],
    complexity: entry[:complexity],
    coverage: entry[:coverage] * 100,
    crap: entry[:crap],
    risk: entry[:bucket]
  )
end

def print_report(entries)
  puts format(HEADER_FORMAT, file: "FILE", method: "METHOD", line: "LINE",
                             complexity: "CMPLX", coverage: "COV%", crap: "CRAP", risk: "RISK")

  entries.each { |entry| print_entry(entry) }
end

BUCKETS_IN_ORDER = ["Excellent", "Reasonable", "Worth reviewing", "High risk", "Unacceptable"].freeze

def print_summary(entries)
  counts = entries.group_by { |entry| entry[:bucket] }.transform_values(&:size)

  puts
  puts "Summary: #{entries.size} method(s) analyzed"
  BUCKETS_IN_ORDER.each do |label|
    next unless counts[label]

    puts "  #{label}: #{counts[label]}"
  end
end

def enforce_crap_threshold(entries)
  worst = entries.max_by { |entry| entry[:crap] }
  return if worst[:crap] <= CRAP_MAX

  warn ""
  warn "CRAP threshold exceeded (max #{CRAP_MAX}): " \
       "#{worst[:method]} at #{worst[:file]}:#{worst[:first_line]} scored #{worst[:crap].round(2)}"
  exit 1
end

entries = build_report

if entries.empty?
  puts "No methods found in lib/."
  exit 0
end

print_report(entries)
print_summary(entries)
enforce_crap_threshold(entries)
