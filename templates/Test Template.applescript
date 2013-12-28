(*!
	@header
	@abstract
		A template for unit testing.
	@discussion
		Copy this template in the folder containing <tt>MyScript.scpt</tt> (the script to be tested) and customize it as follows:
	
		1) Provide a description for this test suite and the name of the script.
		2) Write tests :)

	@charset macintosh
*)
---------------------------------------------------------------------------------------
property suitename : "The test suite description goes here"
property scriptName : "MyScript"
global MyScript -- The variable holding the script to be tested
---------------------------------------------------------------------------------------

property TopLevel : me
property parent : ASUnit of Â
	(load script file (((path to library folder from user domain) as text) Â
		& "Script Libraries:ASUnit.scpt"))
property suite : makeTestSuite(suitename)

try -- to load the script to be tested
	set MyScript to load script file Â
		((folder of file (path to me) of application "Finder" as text) & scriptName & ".scpt")
on error errMsg
	return errMsg
end try
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
