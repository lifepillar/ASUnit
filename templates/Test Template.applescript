(*!
	@header
	@abstract
		A template for unit testing.
	@discussion
		Copy this template in the folder containing the script to be tested and customize it as follows:
	
		1) Provide a description for this test suite and the name of the script to be tested.
		2) Write tests :)

	@charset macintosh
*)
---------------------------------------------------------------------------------------
property suitename : "The test suite description goes here"
property scriptName : "MyScript"
global MyScript -- The variable holding the script to be tested
---------------------------------------------------------------------------------------

property TopLevel : me
property parent : Â
	load script file (((path to library folder from user domain) as text) Â
		& "Script Libraries:ASUnit.scpt")
property suite : makeTestSuite(suitename)

set suite's loggers to {AppleScriptEditorLogger, ConsoleLogger}
tell AppleScriptEditorLogger
	set its defaultColor to {256 * 1, 256 * 102, 256 * 146}
	set its successColor to {256 * 0, 256 * 159, 256 * 120}
	set its defectColor to {256 * 137, 256 * 89, 256 * 168}
end tell
autorun(suite)

---------------------------------------------------------------------------------------
-- Tests
---------------------------------------------------------------------------------------

-- Don't change this test case!
-- We load the script in a test case, because this will work
-- when all the tests in the current folder are run together (using loadTestsFromFolder()).
-- Besides, this will make sure that we are using the latest version of the script
-- to be tested even if we do not recompile this script.
script |Load script|
	property parent : TestSet(me)
	
	script |Loading the script|
		property parent : UnitTest(me)
		try
			set MyScript to load script file Â
				((folder of file (path to TopLevel) of application "Finder" as text) Â
					& scriptName & ".scpt")
		on error
			set MyScript to run script file Â
				((folder of file (path to TopLevel) of application "Finder" as text) Â
					& scriptName & ".applescript")
		end try
		assert(MyScript's class = script, "The script was not loaded correctly.")
	end script
end script


script |A test set|
	property parent : TestSet(me)
	
	on setUp()
	end setUp
	
	on tearDown()
	end tearDown
	
	script |test something|
		property parent : UnitTest(me)
		assert(MyScript's class = script, "The script is not available to this test.")
	end script
	
end script
