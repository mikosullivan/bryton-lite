#!/usr/bin/ruby -w
require_relative './dir'
require 'bryton/lite'

## {"start":"fail"}
Bryton::Lite::Tests.fail() do |error|
	error['notes'] = 'failed db test'
end
## {"end":"fail"}

# done
Bryton::Lite::Tests.done