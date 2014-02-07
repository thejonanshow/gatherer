desc "Open a console with Gatherer"
task :console do
  require 'pry'
  require 'gatherer'
  ARGV.clear
  Pry.start
end
