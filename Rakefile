# frozen_string_literal: true

require "bundler/gem_tasks"
require "rake/testtask"

# Simple compile task without rake-compiler
desc "Compile the extension"
task :compile do
  Dir.chdir("ext/veb_tree") do
    ruby "extconf.rb"
    sh "make"
  end
  
  # Copy the compiled extension to lib
  ext_file = Dir["ext/veb_tree/veb_tree.{so,bundle}"].first
  if ext_file
    FileUtils.mkdir_p "lib/veb_tree"
    FileUtils.cp ext_file, "lib/veb_tree/"
    puts "Extension compiled and copied to lib/veb_tree/"
  else
    puts "Warning: No compiled extension found"
  end
end

Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.libs << "lib"
  t.test_files = FileList["test/**/*_test.rb"]
end

task test: :compile
task default: [:compile, :test]

desc "Clean compiled files"
task :clean do
  rm_rf "lib/veb_tree/veb_tree.so"
  rm_rf "lib/veb_tree/veb_tree.bundle"
  rm_rf "ext/veb_tree/*.o"
  rm_rf "ext/veb_tree/*.so"
  rm_rf "ext/veb_tree/*.bundle"
  rm_rf "ext/veb_tree/Makefile"
  rm_rf "tmp"
end
