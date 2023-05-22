#!/usr/bin/ruby -w
require 'json'

## {"start":"full"}
# some test
def some_test()
	return false
end

# results hash
results = {}

# run a test
if some_test()
	results['success'] = true
else
	results['errors'] ||= []
	results['errors'].push({'id'=>'some_test_failure'})
end
## {"end":"full"}

# output results
puts JSON.generate(results)