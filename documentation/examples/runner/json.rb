#!/usr/bin/ruby -w
require_relative './dir.rb'
require 'bryton/lite'

Dir.chdir '../tests'
Bryton::Lite::Runner.run

puts JSON.pretty_generate(Bryton::Lite::Tests.hsh) ## {"line":"json"}