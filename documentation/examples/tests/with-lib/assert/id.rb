#!/usr/bin/ruby -w
require_relative './dir' ## {"skip":true}
require 'bryton/lite'
	
# some test
def some_test
	return false
end

# test a function
Bryton::Lite::Tests.assert some_test(), 'running some_test()' ## {"line":"assert"}

# done
Bryton::Lite::Tests.try_succeed
Bryton::Lite::Tests.done