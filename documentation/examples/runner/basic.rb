#!/usr/bin/ruby -w
require_relative './dir.rb' ## {"skip":true}
require 'bryton/lite'

Dir.chdir '../tests'
Bryton::Lite::Runner.run
puts Bryton::Lite::Runner.success?