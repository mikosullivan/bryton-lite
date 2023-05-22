#!/usr/bin/ruby -w
require_relative './dir.rb'

# succeed before adding errors
# Don't do this.
Bryton::Lite::Tests.succeed

# add errors
Bryton::Lite::Tests.errors.push({})

# succeed
puts Bryton::Lite::Tests.to_json