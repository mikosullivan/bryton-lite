# bryton-lite
Bare bones Ruby implementation of the Bryton testing protocol

## Install

The usual:

```
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

### Bryton::Lite::Runner

Bryton::Lite::Runner runs all the tests in a directory tree. The full Bryton
protocol will allow you to pick and choose which tests to run and what to do
on success or failure. Bryton::Lite::Runner just implements the basic concept of
running all the tests.

### Bryton::Lite::Tests

#### Basic example

Bryton is designed to be simple. You don't need any special tools to implement
the basic protocol. For example, consider the following script:

[import]: {"path": "doc-examples/tests/sans-lib/basic.rb"}

Notice that you don't even need this gem to run that script. Bryton is designed
to be simple and easy to implement. That test outputs a JSON object as wither
`{"success":true}` or `{"success":false}`.

#### Example using Bryton::Lite::Tests