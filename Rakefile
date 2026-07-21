# frozen_string_literal: true

require "rake/testtask"

Rake::TestTask.new(:"test:unit") do |t|
  t.libs << "test"
  t.test_files = FileList["test/unit/**/*_test.rb"]
  t.warning = false
end

Rake::TestTask.new(:"test:integration") do |t|
  t.libs << "test"
  t.test_files = FileList["test/integration/**/*_test.rb"]
  t.warning = false
end

Rake::TestTask.new(:"test:property") do |t|
  t.libs << "test"
  t.test_files = FileList["test/property/**/*_test.rb"]
  t.warning = false
end

desc "Run unit, integration, and property tests"
task test: %i[test:unit test:integration test:property]

task default: :test

desc "Run every test layer in a single process and collect coverage for rake crap"
Rake::TestTask.new(:"test:coverage") do |t|
  t.libs << "test"
  t.test_files = FileList[
    "test/unit/**/*_test.rb",
    "test/integration/**/*_test.rb",
    "test/property/**/*_test.rb"
  ]
  t.warning = false
end

desc "Run mutation tests (requires the `opensource` usage declared in .mutant.yml)"
task :"test:mutation" do
  sh "bundle exec mutant run"
end

desc "Run rubocop style checks"
task :lint do
  sh "bundle exec rubocop"
end

desc "Compute CRAP scores for lib/ from the last coverage run + cyclomatic complexity"
task crap: :"test:coverage" do
  ruby "script/crap_report.rb"
end
