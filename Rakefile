# coding: utf-8
require 'rubygems' if RUBY_VERSION < '1.9'
require 'rake/clean'

ASUNIT_VERSION = File.open('ASUnit.applescript').read.match(/property +version *: *"(.+)"/)[1]
DIST_DIR = 'ASUnit-' + ASUNIT_VERSION
DOC_DIR = 'Documentation'
SRC = FileList['*.applescript']
OBJ = SRC.ext('scpt')

CLEAN.include('*.scpt', '*.scptd')
CLOBBER.include(DOC_DIR, 'ASUnit-*', '*.tar.gz', 'Manual.html')

task :default => :build

rule '.scpt' => '.applescript' do |t|
  sh "osacompile -d -x -o '#{t.name}' '#{t.source}'"
end

task :default => [:build]

desc 'Build ASUnit.'
task :build => OBJ do; end

desc 'Build the documentation.'
task :doc => [:manual] do
  # Set LANG to get rid of warnings about missing default encoding
  sh "env LANG=en_US.UTF-8 headerdoc2html -q -o #{DOC_DIR} ASUnit.applescript"
  sh "env LANG=en_US.UTF-8 gatherheaderdoc #{DOC_DIR}"
  sh "open #{DOC_DIR}/ASUnit_applescript/index.html"
end

desc 'Build an HTML version of the manual.'
task :manual do
  unless `which multimarkdown 2>/dev/null`.chomp.empty?
    sh 'multimarkdown -o Manual.html Manual.mmd'
  end 
end

desc 'Prepare a directory for distribution.'
task :dist => [:clobber, :build, :manual] do
  mkdir DIST_DIR
  cp ['ASUnit.scpt', 'COPYING'], DIST_DIR
  if File.exist?('Manual.html')
    cp 'Manual.html', DIST_DIR
  end
end

desc 'Build a gzipped tar archive.'
task :gzip => [:dist] do
  sh "tar czf #{DIST_DIR}.tar.gz #{DIST_DIR}/*"
end

desc 'Run tests.'
task :test do
  sh "osascript 'Test ASUnit.applescript'"
end
