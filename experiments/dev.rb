#!/usr/bin/ruby -w
require_relative '/home/miko/projects/ruby-lib/content/lib/cl-dev.rb'

# expected and actual
expected = { 'a'=>1, 'b'=>[{'c'=>2}] }
actual   = { 'a'=>1, 'b'=>[{'c'=>1}] }

puts(expected == actual)

# done
puts '[done]'
