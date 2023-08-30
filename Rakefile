# frozen_string_literal: true

require "rake/testtask"
require "rubocop/rake_task"
require "bundler/gem_tasks"

namespace :tests do
  task all: %i[in_memory file_system]

  Rake::TestTask.new(:suite) do |t|
    t.libs << "test"
    t.libs << "lib"
    t.test_files = FileList["test/**/*_test.rb"]
  end

  desc("Runs the tests with InMemoryStorage")
  task :in_memory do
    ENV["THEME_STORAGE"] = 'InMemoryStorage'
    puts "Running tests with #{ENV.fetch('THEME_STORAGE', nil)}"
    Rake::Task['tests:suite'].execute
  end

  desc("Runs the tests with FileSystemStorage")
  task :file_system do
    ENV["THEME_STORAGE"] = 'FileSystemStorage'
    puts "Running tests with #{ENV.fetch('THEME_STORAGE', nil)}"
    Rake::Task['tests:suite'].execute
  end
end

desc("Runs all tests")
task(test: 'tests:all')

RuboCop::RakeTask.new

task default: %i[test rubocop]

desc("Builds all distribution packages of the CLI")
task(package: 'package:all')

desc("Update files in the repo to match new version")
task :prerelease, [:version] do |_t, args|
  require 'platformos_check/releaser'
  PlatformosCheck::Releaser.new.release(args.version)
end

desc("Download theme-liquid-docs")
task :download_theme_liquid_docs do
  require 'platformos_check/platformos_liquid/source_manager'

  PlatformosCheck::PlatformosLiquid::SourceManager.download
end

desc "Create a new check"
task :new_check, [:name] do |_t, args|
  require "platformos_check/string_helpers"
  class_name = args.name
  base_name = PlatformosCheck::StringHelpers.underscore(class_name)
  code_source = "lib/platformos_check/checks/#{base_name}.rb"
  doc_source = "docs/checks/#{base_name}.md"
  test_source = "test/checks/#{base_name}_test.rb"
  erb(
    "lib/platformos_check/checks/TEMPLATE.rb.erb", code_source,
    class_name:
  )
  erb(
    "test/checks/TEMPLATE.rb.erb", test_source,
    class_name:
  )
  erb(
    "docs/checks/TEMPLATE.md.erb", doc_source,
    class_name:,
    code_source:,
    doc_source:
  )
  sh "bundle exec ruby -Itest #{test_source}"
end

def erb(file, to, **args)
  require "erb"
  File.write(to, ERB.new(File.read(file)).result_with_hash(args))
  puts "Generated #{to}"
end
