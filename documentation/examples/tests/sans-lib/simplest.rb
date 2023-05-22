#!/usr/bin/ruby -w
require 'json'

# some test
def some_test()
	return true
end

# results hash
results = {}

# run a test
results['success'] = some_test()

# output results
puts JSON.generate(results)