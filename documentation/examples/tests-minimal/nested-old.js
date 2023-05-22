// root directory for tests
{
	// file information about this directory
	"file": {
		// path to file - the root directory for the tests is always "."
		"path": ".",
		
		// indicates that this file is a directory
		"dir": true
	},
	
	// nested list of subtests
	// directories always have an array of nested tests
	"nested": [
		// results for the tests in ./load-tests
		{
			// file information about ./load-tests
			"file": {
				"path": "./load-tests",
				"dir": true
			},
			
			// tests nested in ./load-tests
			"nested": [
				// file information about ./load-tests/crash.rb
				{ 
					"file": {
						"path": "./load-tests/crash.rb"
					},
					
					// test test script failed
					"success": false,
					
					// an array of failure messages
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
					"file": {
						"path": "./load-tests/success.rb"
					},
					
					// indicates that the script succeeded
					"success": true
				}
			]
		},
		
		{
			"file": {
				"path": "./test-a.rb"
			},
			"success": true
		}
	]
}
