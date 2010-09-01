require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "who-needs-wp"
    gem.summary = %Q{Who needs Wordpress? A static website generator based on Markdown and Git}
    gem.description = %Q{A static web site generator.}
    gem.email = "owen.griffin@gmail.com"
    gem.homepage = "http://github.com/owengriffin/who-needs-wp"
    gem.authors = ["Owen Griffin"]
    gem.add_dependency('haml', '>= 2.2.20')
    gem.add_dependency('twitter', '>= 0.8.4')
    gem.add_dependency('choice', '>= 0.1.4')
    gem.add_dependency('net-ssh', '>= 2.0.21')
    gem.add_dependency('net-sftp', '>= 2.0.4')
    gem.add_dependency('kramdown', '>= 0.6.0')
    gem.add_dependency('coderay', '>= 0.9.2')
    gem.files = ["lib/who-needs-wp.rb", "lib/who-needs-wp/*.rb", "lib/who-needs-wp/**/*"]
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

begin
  require 'rcov/rcovtask'
  Rcov::RcovTask.new do |test|
    test.libs << 'test'
    test.pattern = 'test/**/test_*.rb'
  end
rescue LoadError
  task :rcov do
    abort "RCov is not available. In order to run rcov, you must: sudo gem install spicycode-rcov"
  end
end

task :test => :check_dependencies

task :default => :test

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "who-needs-wp #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
