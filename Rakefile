task :default => :run

desc "run"
task :run do
  sh "rm -f *.gem"
  sh "gem build revenge.gemspec"
  sh "gem install revenge"
  line = "require 'revenge'"
  sh "ruby -e \"#{line}\""
end

desc "edit"
task :edit do
  sh "ruby editor/editor.rb"
end

desc "documentation"
task :doc do
  sh "rdoc lib/revenge"
end

desc "test"
task :test do
  sh "rspec test/*.rb -f d -c"
end
