#!/usr/bin/ruby -w
require_relative './dir.rb'

# add an error, then call succeed, which should fail.
Bryton::Lite::Tests.errors.push({})
Bryton::Lite::Tests.succeed

# output
puts Bryton::Lite::Tests.to_json