require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "metastrano"
    gem.summary = %Q{Capistrno recipes for Passenger, MySQL Etc}
    gem.description = %Q{This is a gem that is suppose to help you automate all of your server deployment and project maintenance tasks}
    gem.email = "jnarowski@gmail.com"
    gem.files = [
      ".document",
       ".gitignore",
       "LICENSE",
       "README.rdoc",
       "Rakefile",
       Dir["{spec,lib}/**/*"],
       "test/helper.rb",
       "test/test_metastrano.rb"
    ]
    gem.homepage = "http://github.com/jnarowski/metastrano"
    gem.authors = ["John Paul Narowski"]
    gem.add_development_dependency "rspec", ">= 1.2.9"
    gem.add_development_dependency "capistrano", ">= 2.3.0"
    gem.add_development_dependency "erb"
  end
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: sudo gem install jeweler"
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
    test.verbose = true
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
  rdoc.title = "metastrano #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
