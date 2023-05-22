#!/usr/bin/ruby -w
require_relative './dir.rb'

Bryton::Lite::Tests.fail

# succeed
puts Bryton::Lite::Tests.to_json