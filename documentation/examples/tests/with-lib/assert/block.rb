#!/usr/bin/ruby -w
require_relative './dir' ## {"skip":true}
require 'bryton/lite'

# some test
def some_test
	return false
end

# test a function
## {"start":"assert"}
Bryton::Lite::Tests.assert(some_test()) do |error|
	error['notes'] = 'failure of some_test'
end
## {"end":"assert"}

# done
Bryton::Lite::Tests.try_succeed
Bryton::Lite::Tests.done