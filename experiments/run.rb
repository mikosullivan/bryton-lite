#!/usr/bin/ruby -w
require_relative './dir.rb'
require 'tatum'

# run tests
# Dir.chdir('../test/scripts/all-success') do
Dir.chdir('../test/scripts/pass-fail') do
	Bryton::Lite::Runner.run do |path, results|
		if results.empty?
			puts 'empty results'
			puts path
			exit
		end
	end
end

# output json to results.json
File.write( './results.json', JSON.pretty_generate(Bryton::Lite::Tests.hsh) )

# TTM.show Bryton::Lite::Tests.hsh

# done
# puts '[done]'