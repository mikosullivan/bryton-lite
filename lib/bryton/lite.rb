require 'open3'
require 'json'


#===============================================================================
# Bryton, Bryton::Lite
#

# Not much here. Just initializing the Bryton namespace.

module Bryton
end

# Not much here either. Just initializing the Bryton::Lite namespace.

module Bryton::Lite
end
#
# Bryton, Bryton::Lite
#===============================================================================


#===============================================================================
# Bryton::Lite::Runner
#

# Runs tests in the current directory tree.

module Bryton::Lite::Runner
	#---------------------------------------------------------------------------
	# run
	#
	
	# Run the tests. If you pass in a block, each test result is yielded with
	# the path to the file and the results hash.
	
	def self.run(&block)
		Bryton::Lite::Tests.reset
		dir('.', &block)
		Bryton::Lite::Tests.try_succeed
		Bryton::Lite::Tests.reorder_results
	end
	#
	# run
	#---------------------------------------------------------------------------
	
	
	#---------------------------------------------------------------------------
	# dir
	#
	
	# Runs the tests in a directory. Don't call this method directly.
	
	def self.dir(path, &block)
		entries = Dir.entries('./')
		entries = entries.reject {|entry| entry.match(/\A\.+\z/mu)}
		
		# note file and path
		Bryton::Lite::Tests['file'] = {}
		Bryton::Lite::Tests['file']['path'] = path
		Bryton::Lite::Tests['file']['dir'] = true
		
		# loop through entries
		entries.each do |entry|
			entry_path = "#{path}/#{entry}"
			
			# if directory, recurse into it
			if File.directory?(entry)
				Dir.chdir(entry) do
					Bryton::Lite::Tests.nest do
						self.dir(entry_path, &block)
					end
				end
			
			# elsif the file is executable then execute it
			elsif File.executable?(entry)
				results = execute(entry, entry_path)
				Bryton::Lite::Tests.add_to_nest results
				
				if block_given?
					yield entry_path, results
				end
			end
		end
	end
	#
	# dir
	#---------------------------------------------------------------------------
	
	
	#---------------------------------------------------------------------------
	# execute
	#
	
	# Executes a file, parses the results, and returns the results. Don't call
	# this method directly.
	
	def self.execute(name, path)
		# init
		rv = {}
		rv['file'] = {}
		rv['file']['path'] = path
		
		# execute script
		cap = Bryton::Lite::Runner::Capture.new("./#{name}")
		
		# if script crashed
		if not cap.success?
			rv['success'] = false
			rv['errors'] ||= []
			
			# build error
			error = {'id'=>'execution-failed'}
			error['id'] = 'execution-failed'
			error['stderr'] = cap.stderr
			
			# add error and return
			rv['errors'].push(error)
			return rv
		
		# if we get a non-blank line, attempt to parse it as JSON
		elsif non_blank = self.last_non_blank(cap.stdout)
			begin
				# retrieve and parse results
				results = JSON.parse( non_blank )
				rv = rv.merge(results)
				
				# ensure that if there are errors, success is false
				if rv['errors'] and rv['errors'].any?
					rv['success'] = false
				end
				
				# return
				return rv
			rescue
				rv['success'] = false
				rv['errors'] = []
				rv['errors'].push({'id'=>'invalid-json'})
				return rv
			end
		
		# did not get non-blank line
		else
			rv['success'] = false
			rv['errors'] = []
			rv['errors'].push({'id'=>'no-results'})
			return rv
		end
	end
	#
	# execute
	#---------------------------------------------------------------------------
	
	
	#---------------------------------------------------------------------------
	# last_non_blank
	#
	
	# Finds the last non-blank line in STDOUT from the file execution. Don't
	# call this method directly.
	
	def self.last_non_blank(str)
		str.lines.reverse.each do |line|
			if line.match(/\S/mu)
				return line
			end
		end
		
		# didn't find non-blank
		return nil
	end
	#
	# last_non_blank
	#---------------------------------------------------------------------------
	
	
	#---------------------------------------------------------------------------
	# success?
	#
	
	# Returns the success or failure of the test run.
	
	def self.success?
		return Bryton::Lite::Tests.success?
	end
	#
	# success?
	#---------------------------------------------------------------------------
end
#
# Bryton::Lite::Runner
#===============================================================================


#===============================================================================
# Bryton::Lite::Runner::Capture
# class for capturing the output of a script
#

# Executes the given command and captures the results.

class Bryton::Lite::Runner::Capture
	# Executes the command with Open3.capture3 and holds on to the results.
	def initialize(*cmd)
		@results = Open3.capture3(*cmd)
	end
	
	# Returns the content of STDOUT from the execution.
	# @return [String]
	def stdout
		return @results[0]
	end
	
	# Returns the content of STDERR from the execution.
	# @return [String]
	def stderr
		return @results[1]
	end
	
	# Returns the status of execution.
	# @return [Process::Status]
	def status
		return @results[2]
	end
	
	# Returns the success or failure of the execution.
	# @return [Boolean]
	def success?
		return status.success?
	end
end
#
# Bryton::Lite::Runner::Capture
#===============================================================================


#===============================================================================
# Bryton::Lite::Tests
#

# Utilities for use in the test script.

module Bryton::Lite::Tests
	# accessors
	class << self
		# @return [Hash]
		attr_reader :hsh
	end
	
	# reset
	def self.reset()
		@hsh = {}
	end
	
	# call reset
	reset()
	
	# Get the element with the given key.
	def self.[](k)
		return @hsh[k]
	end
	
	# Set the element with the given key and value.
	def self.[]=(k, v)
		return @hsh[k] = v
	end
	
	# Set to success. Raises an exception if any errors exist. You probably want
	# to use try_succeed() instead.
	def self.succeed
		if not allow_success?
			raise 'cannot-set-to-success'
		end
		
		return @hsh['success'] = true
	end
	
	# Returns true if ['success'] is true, false otherwise. Always returns true
	# or false.
	# @return [Boolean]
	def self.success?
		return @hsh['success'] ? true : false
	end
	
	# Try to set to success, but will not do so if there are errors or if the
	# test is already set as fail. Does not raise an exception if the success
	# cannot be set to true.
	# @return [Boolean]
	def self.try_succeed
		return @hsh['success'] = allow_success?()
	end
	
	# Test if try_succeed can set success. You probably don't need to call this
	# method directly.
	# @return [Boolean]
	def self.allow_success?
		return allow_success_recurse(@hsh)
	end
	
	# Tests each nested result. If any of the nested results are set to failure,
	# return false. Otherwise returns true.
	def self.allow_success_recurse(test_hsh)
		# if any errors
		if test_hsh['errors'] and test_hsh['errors'].any?
			return false
		end
		
		# recurse into nested elements
		if test_hsh['nested']
			test_hsh['nested'].each do |child|
				if not allow_success_recurse(child)
					return false
				end
			end
		end
		
		# at this point it should be successful
		return true
	end
	
	# Returns the errors array, creating it if necessary.
	def self.errors
		@hsh['errors'] ||= []
		return @hsh['errors']
	end
	
	# Creates (if necessary) an array with the key "nested". Creates a results
	# hash that is nested in that array. In the do block,
	# Bryton::Lite::Tests.hsh is set to that child results hash.
	def self.nest()
		@hsh['nested'] ||= []
		child = {}
		@hsh['nested'].push child
		hold_hsh = @hsh
		@hsh = child
		
		begin
			yield
		ensure
			@hsh = hold_hsh
		end
	end
	
	# Created the "nested" array and adds the given results to that array
	def self.add_to_nest(child)
		@hsh['nested'] ||= []
		@hsh['nested'].push child
	end
	
	# done
	def self.done
		try_succeed()
		reorder_results()
		STDOUT.puts JSON.generate(@hsh)
		exit
	end
	
	# to_json
	def self.to_json
		return JSON.generate(@hsh)
	end
	
	# Asserts a condition as true. Fails if condition is not true
	def self.assert(bool, id=nil, level=0, &block)
		if not bool
			fail id, 1, &block
		end
	end
	
	# Asserts a condition as false. Fails if condition is true.
	def self.refute(bool, id=nil, level=0, &block)
		if bool
			fail id, 1, &block
		end
	end
	
	# Asserts that two objects are equal according to ==. Fails if they are not.
	def self.assert_equal(expected, actual, id=nil, level=0, &block)
		if not (expected == actual)
			fail id, 1, &block
		end
	end
	
	# Asserts that two objects are not equal according to ==. Fails if they are.
	def self.refute_equal(expected, actual, id=nil, level=0, &block)
		if (expected == actual)
			fail id, 1, &block
		end
	end
	
	# Mark the test as failed.
	def self.fail(id=nil, level=0, &block)
		loc = caller_locations[level]
		
		# create error object
		error = {}
		error['line'] = loc.lineno
		id and error['id'] = id
		
		# add to errors
		@hsh['errors'] ||= []
		@hsh['errors'].push error
		
		# if block
		if block_given?
			yield error
		end
	end
	
	# reorder_results
	# This method is for improving the readability of a result by putting the
	# "success" element first and "nested" last.
	def self.reorder_results
		@hsh = reorder_results_recurse(@hsh)
	end
	
	# reorder_results_recurse
	# This method rcurses through test results, putting "success" first and
	# "nested" last.
	def self.reorder_results_recurse(old_hsh)
		new_hsh = {}
		nested = old_hsh.delete('nested')
		
		# add success if it exists
		if old_hsh.has_key?('success')
			new_hsh['success'] = old_hsh.delete('success')
		end
		
		# add every other element
		new_hsh = new_hsh.merge(old_hsh)
		
		# add nested last
		if nested
			new_hsh['nested'] = nested
			
			# recurse through nested results
			new_hsh['nested'].map! do |child|
				reorder_results_recurse child
			end
		end
		
		# return reformatted hash
		return new_hsh
	end
end
#
# Bryton::Lite::Tests
#===============================================================================