#!/usr/bin/ruby -w
require_relative './dir.rb'
require 'tatum'

# init
tree = {}

def dir(hsh)
	hsh['nested'] = []
	
	Dir.entries('./').each do |entry|
		unless (entry == '.') or (entry == '..')
			nest = {}
			nest['path'] = entry
			hsh['nested'].push nest
			
			if File.directory?(entry)
				Dir.chdir(entry) do
					dir nest
				end
			end
		end
	end
end

# run tests
Dir.chdir('../test/scripts/pass-fail') do
	tree['path'] = './'
	dir tree
end

# output
puts JSON.pretty_generate(tree)