require 'bundler/gem_tasks'
require 'rake'
if !defined?(sh) && defined?(Rake::DSL)
  include Rake::DSL
end

begin
  require 'yard'
  YARD::Rake::YardocTask.new
rescue LoadError
  task :yard do
    abort "YARD is not available. In order to run yardoc, you must: sudo gem install yard"
  end
end