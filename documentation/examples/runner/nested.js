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