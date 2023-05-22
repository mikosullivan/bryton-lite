require 'minitest/autorun'
Dir.chdir File.dirname(__FILE__)
require_relative './dir.rb'

# test class
class BrytonLiteTest < Minitest::Test
	# tests successes and failures
	def test_pass_file
		Dir.chdir('./scripts/pass-fail') do
			Bryton::Lite::Runner.run do |path, results|
				basename = File.basename(path)
				
				# should have a file name
				if results.empty?
					fail 'empty-results'
				end
				
				# success
				if basename == 'succeed.rb'
					assert results['success'], path
					
				# failure
				elsif basename == 'fail.rb'
					refute results['success'], path
					
				# crash
				elsif basename == 'crash.rb'
					refute results['success'], path
					assert_equal 'execution-failed', results['errors'][0]['id']
				
				# nil
				elsif basename == 'nil.rb'
					assert results['success'].nil?, path
					
				# invalid
				elsif basename == 'invalid.rb'
					refute results['success'], path
					assert_equal 'invalid-json', results['errors'][0]['id']
					
				# empty
				elsif basename == 'empty.rb'
					refute results['success'], path
					assert_equal 'no-results', results['errors'][0]['id']
					
				# errors
				elsif basename == 'errors.rb'
					refute results['success'], path
					assert_equal 1, results['errors'].length
					
				# else raise exception
				else
					raise 'unknown-file-name: ' + path
				end
			end
		end
		
		# should not be successful
		refute Bryton::Lite::Tests.success?
		
		# every entry should have a file element and a path
		dir_check Bryton::Lite::Tests.hsh
	end
	
	# check that directory has file hash
	def dir_check(hsh)
		assert hsh['file']
		assert hsh['file']['path']
		assert hsh['file']['dir']
		
		# loop through entries
		# This terst is a little funky because it assumes that there's a file
		# hash. I.e., it crashes before it tests the condition. I'm open to a
		# more graceful way to do this.
		if hsh['nested']
			hsh['nested'].each do |nest|
				if nest['file']['dir']
					dir_check nest
				else
					file_check nest
				end
			end
		end
	end
	
	# check that file has a file hash
	def file_check(hsh)
		assert hsh['file']
		assert hsh['file']['path']
	end
	
	# tests successful run
	def test_success
		Dir.chdir('./scripts/all-success') do
			Bryton::Lite::Runner.run
			assert Bryton::Lite::Tests.success?
		end
	end
	
	# test the reset method
	def test_reset
		Bryton::Lite::Tests.errors.push({})
		Bryton::Lite::Tests.reset()
		refute Bryton::Lite::Tests['errors']
	end
	
	# Tests the reorder_results method
	def test_reorder_results
		# reset
		Bryton::Lite::Tests.reset()
		Bryton::Lite::Tests.hsh['errors'] = []
		
		# add some nested test results
		Bryton::Lite::Tests.hsh['nested'] = [
			{
				'nested'=>[
					{
						'errors'=>[],
						'nested'=>[
							{
								'errors'=>[{}],
								'nested'=>[],
								'success'=> false
							}
						],
		            
						'success'=> true
					},
				],
		    
				'success'=> false
			}
		];
		
		# set success last
		Bryton::Lite::Tests.hsh['success'] = false
		
		# call success_first
		Bryton::Lite::Tests.reorder_results()
		
		# test that success is first in all nested hashes
		check_key_order Bryton::Lite::Tests.hsh
	end
	
	# Recursive function for testing reorder_results in each nested hash.
	def check_key_order(hsh)
		# "success" key should be first
		if hsh.has_key?('success')
			assert_equal hsh.keys[0], 'success'
		end
		
		# "nested" key should be last
		if hsh.has_key?('nested')
			assert_equal hsh.keys[-1], 'nested'
		end
		
		# recurse through nested results
		if hsh['nested']
			hsh['nested'].each do |child|
				check_key_order child
			end
		end
	end
	
	# Test equality and inequality of hashes and arrays.
	def test_structue_equality
		# two hashes the same
		expected = { 'a'=>true}
		actual = { 'a'=>true}
		Bryton::Lite::Tests.assert_equal expected, actual
		
		# two hashes different
		expected = { 'a'=>true}
		actual = { 'a'=>false}
		Bryton::Lite::Tests.refute_equal expected, actual
		
		# two arrays the same
		expected = ['a']
		actual = ['a']
		Bryton::Lite::Tests.assert_equal expected, actual
		
		# two arrays different
		expected = ['a']
		actual = ['b']
		Bryton::Lite::Tests.refute_equal expected, actual
		
		# hashes, nested, the same
		expected = { 'a'=>{'a.a'=>true, 'a.b'=>{}}}
		actual = { 'a'=>{'a.a'=>true, 'a.b'=>{}}}
		Bryton::Lite::Tests.assert_equal expected, actual
		
		# hashes, nested, different
		expected = { 'a'=>{'a.a'=>true, 'a.b'=>{'a.b.a'=>1}}}
		actual = { 'a'=>{'a.a'=>true, 'a.b'=>{}}}
		Bryton::Lite::Tests.refute_equal expected, actual
		
		# hashes, nested with arrays, the same
		expected = { 'a'=>{'a.a'=>[1,2,3]} }
		actual = { 'a'=>{'a.a'=>[1,2,3]} }
		Bryton::Lite::Tests.assert_equal expected, actual
		
		# hashes, nested with arrays, different
		expected = { 'a'=>{'a.a'=>[1,2,3]} }
		actual = { 'a'=>{'a.a'=>[1,3,2]} }
		Bryton::Lite::Tests.refute_equal expected, actual
	end
end