task :default => :run

desc "run"
task :run do
  sh "ruby lib/revenge.rb"
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
  sh "rspec tests/*.rb -f d -c"
end
