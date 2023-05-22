#!/usr/bin/ruby -w
require_relative './dir.rb'

# errors
Bryton::Lite::Tests['errors'] = []
Bryton::Lite::Tests['errors'].push({})

# try to succeed
Bryton::Lite::Tests.try_succeed

# succeed
puts Bryton::Lite::Tests.to_json