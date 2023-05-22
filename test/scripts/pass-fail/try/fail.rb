#!/usr/bin/ruby -w
require_relative './dir.rb'

Bryton::Lite::Tests.fail
Bryton::Lite::Tests.try_succeed

# succeed
puts Bryton::Lite::Tests.to_json