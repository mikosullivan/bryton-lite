# bryton-lite
Bare bones Ruby implementation of the Bryton testing protocol

## Install

The usual:

```sh
gem install bryton-lite
```

## Overview

Bryton is a file-based testing protocol. The point of Bryton is to allow you to
write your tests without constraints on how they need to be organized. All your
test scripts have to do is output a JSON object as the last line of STDOUT. At
a minimum, the JSON object should have a "success" element set to true or false:

```json
{"success":true}
{"success":false}
```

Bryton allows you to start simple, with just a few tests scripts that you can
run manually to see the results. As you progress to automated testing you can
use a Bryton runner to run all your tests.
   
A Bryton runner (i.e. the routine running the tests) calls each executable file
in a directory, collecting the results. Those executables can be written in any
language, Ruby or otherwise. It also recurses into subdirectories. The runner
then reports the results back to you in either a human readable or machine
readable format.

Bryton (which is currently under development) will be a full featured testing
system with a large array of options. Bryton::Lite only implements a few of the
features. In fact, Bryton::Lite is to be used for testing Bryton.


## Use

This gem has two modules, one for building tests and one for running tests. The
two modules don't depend on each other. You can use one or the other or both.

### Bryton::Lite::Tests

#### Basic example

Bryton is designed to be simple. You don't need any special tools to implement
the basic protocol. For example, consider the following script:

```ruby
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
```

Notice that you don't even need this gem to run that script. Bryton is designed
to be simple and easy to implement. That test outputs a JSON object as either
`{"success":true}` or `{"success":false}`. Now let's take a look at a script
in which a test fails.

```ruby
#!/usr/bin/ruby -w
require 'json'

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

# output results
puts JSON.generate(results)
```

In this example one of the tests fails. The script could have simply set
`success` to false, but instead it gives a little more information by creating
the `errors` array and adding a message to it. Notice that `success` is never
explicitly set. That's because the presence of an error implies failure.

#### Bryton::Lite::Tests.assert

Bryton::Lite::Tests provides several tools for building and outputting test
results. Consider this script:

```ruby
#!/usr/bin/ruby -w
require 'bryton/lite'

# some test
def some_test
   return false
end

# test a function
Bryton::Lite::Tests.assert some_test()

# done
Bryton::Lite::Tests.try_succeed
Bryton::Lite::Tests.done
```

In this test, we create a function that, in this case, always returns false.
Then we use Bryton::Lite::Tests.assert to check the result of that function.
If the test fails, then an error is added to the output hash.

Next we call Bryton::Lite::Tests.try_succeed. That function marks the test
script as successful, but only if there are not errors. Remember that a test run
is only considered successful if the output explicitly sets `success` as true.


Finally, we call Bryton::Lite::Tests.done, which outputs the the results and
exits. Bryton::Lite::Tests.done should be called as the last line of your
script.

Here's the output for that run.

```json
{"errors":[{"line":12,"file":"./basic.rb"}]}
```

By default, `assert` notes the file name and line number of the error. You can
also add an id for the error:

```ruby
Bryton::Lite::Tests.assert some_test(), 'running some_test()'
```

which outputs

```json
{"errors":[{"line":11,"file":"./id.rb","id":"running some_test()"}]}
```

If you want to manually add information to the error, use a do block. `assert`
yields the error hash:

```ruby
Bryton::Lite::Tests.assert(some_test()) do |error|
   error['notes'] = 'failure of some_test'
end
```

which outputs a JSON object with whatever you added:

```json
{"errors":[{"line":12,"file":"./block.rb","notes":"failure of some_test"}]}
```

#### Bryton::Lite::Tests.fail

`fail` works much like `assert`, but it unconditionally adds an error. `fail`
has syntax similar to `assert`.

```ruby
Bryton::Lite::Tests.fail() do |error|
   error['notes'] = 'failed db test'
end
```

which outputs JSON like this:

```json
{"errors":[{"line":6,"file":"./no-id.rb","notes":"failed db test"}]}
```

### Bryton::Lite::Runner

Bryton::Lite::Runner runs all the tests in a directory tree. The full Bryton
protocol will allow you to pick and choose which tests to run and what to do
on success or failure. Bryton::Lite::Runner just implements the basic concept of
running all the tests.

To run tests, your script should go to the root of the directory where you have
your test files. Then just run `Bryton::Lite::Runner.run`.

```ruby
#!/usr/bin/ruby -w
require 'bryton/lite'

Dir.chdir '../tests'
Bryton::Lite::Runner.run
puts Bryton::Lite::Runner.success?
```

If you just want to know the success or failure of the tests, output
`Bryton::Lite::Runner.success?`. If you want more information, you can output
all the results from the entire test run:

```ruby
puts JSON.pretty_generate(Bryton::Lite::Tests.hsh)
```

Notice that we use `Bryton::Lite::Tests.hsh` to get the results. The runner
stores results with Bryton::Lite::Tests because the run itself is a test. There
are main three elements to a results hash.

| key     | data type           | explanation                                                                                                                                                                               |
|---------|---------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| success | true, false, or nil | Indicates success of failure of a test. Nil is considered false.                                                                                                                          |
| file    | hash                | Hash of information about the fiule being tested. Should at least contain the path to the file relative to the root directory of the test. If `dir` is true then the file is a directory. |
| errors  | array               | Each element of the array give details about an error. If any elements are present in the errors array then `success` should not be true.                                                 |
| nested  | array               | Array of nested test results. Every nested result must be successful or the entire test run is considered to have failed.                                                                 |

As with any hash, you can add your own custom elements.

Here is a sample output from a script run. (JSON doesn't allow comments, but
I've added some here for clarity.

```javascript
// root directory for tests
{
   // indicates that the test run failed
   "success": false,
   
   // file information about this directory
   "file": {
      "path": ".",
      "dir": true
   },
   
   // nested list of subtests
   // directories always have an array of nested tests
   "nested": [
      {
         "file": {
            "path": "./load-tests",
            "dir": true
         },
         
         "nested": [
            {
               // indicates that this file test failed
               "success": false,
               
               // file information about ./load-tests/crash.rb
               "file": {
                  "path": "./load-tests/crash.rb"
               },
               
               // array of error messages
               "errors": [
                  {
                     // indicates that execution of the script failed
                     "id": "execution-failed",
                     
                     // STDERR from the execution
                     "stderr": "./crash.rb:5:in `/': divided by 0 (ZeroDivisionError)\n\tfrom ./crash.rb:5:in `<main>'\n"
                  }
               ]
            },
            
            {
               // indicates that the script succeeded
               "success": true,
               
               // file information
               "file": {
                  "path": "./load-tests/success.rb"
               }
            }
         ]
      },
      
      {
         "success": true,
         "file": {
            "path": "./test-a.rb"
         }
      }
   ]
}
```

## History

| date         | version | notes                                       |
|--------------|---------|---------------------------------------------|
| May 22, 2023 | 1.0     | Initial upload                              |
| May 22, 2023 | 1.1     | Added refute, assert_equal and refute_equal |