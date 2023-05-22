#!/usr/bin/ruby -w
require_relative './dir.rb'
require 'bryton/lite'

Dir.chdir '../tests-minimal'
Bryton::Lite::Runner.run

puts JSON.pretty_generate(Bryton::Lite::Tests.hsh)