task :default => :run

desc "run"
task :run do
  sh "ruby src/main.rb"
end

desc "edit"
task :edit do
  sh "ruby editor/editor.rb"
end

desc "documentation"
task :doc do
  sh "rdoc src"
end

desc "test"
task :test do
  sh "rspec tests/*.rb -f d -c"
end
