(*
ASUnit tests

copyright: (c) 2006 Nir Soffer <nirs@freeshell.org>
license: GNU GPL, see COPYING for details
*)

on _setpath()
	if current application's name is "AppleScript Editor" then
		(folder of file (document 1's path as POSIX file) of application "Finder") as text
	else if current application's name is in {"osacompile", "osascript"} then
		((POSIX file (do shell script "pwd")) as text) & ":"
	else
		error "This file can be compiled/run only with AppleScript Editor, osacompile or osascript"
	end if
end _setpath

-- Required ASUnit header
-- Load  ASUnit from current folder using text format during development
property ASUnitPath : _setpath() & "ASUnit.applescript" -- set at compile time
property parent : run script file ASUnitPath

property suite : makeTestSuite("ASUnit Tests")

script |should and shouldnt|
	property parent : registerFixture(me)
	
	script |should succeed with true|
		property parent : registerTestCase(me)
		should(true, name)
	end script
	
	script |shouldnt succeed with false|
		property parent : registerTestCase(me)
		shouldnt(false, name)
	end script
	
	script |should fail with false|
		property parent : registerTestCase(me)
		
		script |unregistered failure|
			property parent : makeTestCase()
			should(false, name)
		end script
		set aResult to |unregistered failure|'s test()
		should(aResult's hasPassed() is false, "should passed with false?!")
	end script
	
	script |shouldnt fail with true|
		property parent : registerTestCase(me)
		
		script |unregistered failure|
			property parent : makeTestCase()
			shouldnt(true, name)
		end script
		set aResult to |unregistered failure|'s test()
		shouldnt(aResult's hasPassed(), "shouldnt passed with true?!")
	end script
	
end script


script |skipping test helper|
	-- I'm a helper fixture for the skip tests..
	property parent : registerFixture(me)
	
	script test
		property parent : makeTestCase()
		skip("I feel skippy")
		should(true, name)
	end script
end script


script |skipping setup helper|
	-- I'm a helper fixture for the skip tests..
	property parent : registerFixture(me)
	
	on setUp()
		skip("I feel skippy")
	end setUp
	
	script test
		property parent : makeTestCase()
		should(true, name)
	end script
end script


script skipping
	property parent : registerFixture(me)
	
	script |skipping test|
		property parent : registerTestCase(me)
		set aResult to |skipping test helper|'s test's test()
		should(aResult's hasPassed(), "test failed")
		should(aResult's skipCount() = 1, "skipCount ­ 1")
	end script
	
	script |skipping setup|
		property parent : registerTestCase(me)
		set aResult to |skipping setup helper|'s test's test()
		should(aResult's hasPassed(), "test failed")
		should(aResult's skipCount() = 1, "skipCount ­ 1")
	end script
	
end script


script |errors setUp helper|
	-- I'm a helper for tearDown tests
	property parent : registerFixture(me)
	
	on setUp()
		error "setUp raised an error"
	end setUp
	
	script test
		property parent : makeTestCase()
		should(true, name)
	end script
	
end script


script |errors test case helper|
	-- I'm a helper for tearDown tests
	property parent : registerFixture(me)
	
	script test
		property parent : makeTestCase()
		error "I feel nasty"
	end script
	
end script


script |errors tearDown helper|
	-- I'm a helper for tearDown tests
	property parent : registerFixture(me)
	
	on tearDown()
		error "tearDown raised an error"
	end tearDown
	
	script test
		property parent : makeTestCase()
		should(true, name)
	end script
	
end script


script errors
	property parent : registerFixture(me)
	
	script |error in setup|
		property parent : registerTestCase(me)
		set aResult to |errors setUp helper|'s test's test()
		shouldnt(aResult's hasPassed(), "error in setup ignored")
		should(aResult's errorCount() = 1, "errorCount ­ 1")
	end script
	
	script |error in test case|
		property parent : registerTestCase(me)
		set aResult to |errors test case helper|'s test's test()
		shouldnt(aResult's hasPassed(), "error in test case ignored")
		should(aResult's errorCount() = 1, "errorCount ­ 1")
	end script
	
	script |error in tearDown|
		property parent : registerTestCase(me)
		set aResult to |errors tearDown helper|'s test's test()
		shouldnt(aResult's hasPassed(), "error in tearDown ignored")
		should(aResult's errorCount() = 1, "errorCount ­ 1")
	end script
	
end script


script setUp
	property parent : registerFixture(me)
	property setUpDidRun : false
	
	on setUp()
		set setUpDidRun to true
	end setUp
	
	script |setup run before test|
		property parent : registerTestCase(me)
		should(setUpDidRun, "setup did not run before the test")
	end script
	
end script


script |tearDown helper|
	-- I'm a helper to tearDown tests
	property parent : registerFixture(me)
	property tearDownDidRun : missing value
	
	on setUp()
		set tearDownDidRun to false
	end setUp
	
	on tearDown()
		set tearDownDidRun to true
	end tearDown
	
	script |failing test|
		property parent : makeTestCase()
		should(false, name)
	end script
	
	script |erroring test|
		property parent : makeTestCase()
		error "I feel nasty"
		should(true, name)
	end script
	
	script |skipping test|
		property parent : makeTestCase()
		skip("I feel skippy")
		should(true, name)
	end script
	
end script


script |skip in setUp helper|
	-- I'm a helper to tearDown tests
	property parent : registerFixture(me)
	property tearDownDidRun : missing value
	
	on setUp()
		set tearDownDidRun to false
		skip("I feel skippy")
	end setUp
	
	on tearDown()
		set tearDownDidRun to true
	end tearDown
	
	script test
		property parent : makeTestCase()
		should(true, name)
	end script
	
end script


script |error in setUp helper|
	-- I'm a helper for tearDown tests
	property parent : registerFixture(me)
	property tearDownDidRun : missing value
	
	on setUp()
		set tearDownDidRun to false
		error "I feel nasty"
	end setUp
	
	on tearDown()
		set tearDownDidRun to true
	end tearDown
	
	script test
		property parent : makeTestCase()
		should(true, name)
	end script
	
end script


script |tearDown|
	property parent : registerFixture(me)
	
	script |run after failed test|
		property parent : registerTestCase(me)
		set aResult to (|tearDown helper|'s |failing test|'s test())
		if aResult's hasPassed() then error "failing test did not fail, can't test tearDown"
		should(|tearDown helper|'s tearDownDidRun, name)
	end script
	
	script |run after error in test|
		property parent : registerTestCase(me)
		set aResult to (|tearDown helper|'s |erroring test|'s test())
		if aResult's hasPassed() then error "erroring test did not error, can't test tearDown"
		should(|tearDown helper|'s tearDownDidRun, name)
	end script
	
	script |run after skipping test|
		property parent : registerTestCase(me)
		set aResult to (|tearDown helper|'s |skipping test|'s test())
		if aResult's skipCount() ­ 1 then error "skipping test did not skip, can't test tearDown"
		should(|tearDown helper|'s tearDownDidRun, name)
	end script
	
	script |run after skip in setup|
		property parent : registerTestCase(me)
		set aResult to (|skip in setUp helper|'s test's test())
		if aResult's skipCount() ­ 1 then error "there was no skip, can't test tearDown"
		should(|skip in setUp helper|'s tearDownDidRun, name)
	end script
	
	script |run after error in setup|
		property parent : registerTestCase(me)
		set aResult to (|error in setUp helper|'s test's test())
		if aResult's hasPassed() then error "there was no error, can't test tearDown"
		should(|error in setUp helper|'s tearDownDidRun, name)
	end script
	
end script


script |invalid test case|
	property parent : registerFixture(me)
	
	script |unregistered test without run handler|
		property parent : makeTestCase()
	end script
	
	script |no run handler|
		property parent : registerTestCase(me)
		set aResult to |unregistered test without run handler|'s test()
		shouldnt(aResult's hasPassed(), "test passed with an error?!")
	end script
	
end script


script |analyze helper|
	-- I'm a helper fixture. All my tests are NOT registered in this suite
	property parent : registerFixture(me)
	
	script success
		property parent : makeTestCase()
		should(true, name)
	end script
	
	script skip
		property parent : makeTestCase()
		skip("I feel skippy")
	end script
	
	script failure
		property parent : makeTestCase()
		should(false, name)
	end script
	
	script |error|
		property parent : makeTestCase()
		error "I feel nasty"
	end script
	
end script


script |analyze results|
	-- Test hasPassed() and count() methods
	property parent : registerFixture(me)
	
	script |check counts|
		property parent : registerTestCase(me)
		set aSuite to makeTestSuite(name)
		aSuite's add(|analyze helper|'s success)
		aSuite's add(|analyze helper|'s success)
		aSuite's add(|analyze helper|'s skip)
		aSuite's add(|analyze helper|'s |error|)
		aSuite's add(|analyze helper|'s failure)
		set aResult to aSuite's test()
		should(aResult's runCount() = 5, "runCount ­ 5")
		should(aResult's passCount() = 2, "passCount ­ 2")
		should(aResult's skipCount() = 1, "skipCount ­ 1")
		should(aResult's failureCount() = 1, "failureCount ­ 1")
		should(aResult's errorCount() = 1, "errorCount ­ 1")
	end script
	
	script |suite with success should pass|
		property parent : registerTestCase(me)
		set aSuite to makeTestSuite(name)
		aSuite's add(|analyze helper|'s success)
		aSuite's add(|analyze helper|'s success)
		set aResult to aSuite's test()
		should(aResult's hasPassed(), "test failed without defects?!")
	end script
	
	script |suite with skips should pass|
		property parent : registerTestCase(me)
		set aSuite to makeTestSuite(name)
		aSuite's add(|analyze helper|'s success)
		aSuite's add(|analyze helper|'s skip)
		aSuite's add(|analyze helper|'s skip)
		set aResult to aSuite's test()
		should(aResult's hasPassed(), "test failed without defects?!")
	end script
	
	script |suite with a failure should fail|
		property parent : registerTestCase(me)
		set aSuite to makeTestSuite(name)
		aSuite's add(|analyze helper|'s success)
		aSuite's add(|analyze helper|'s skip)
		aSuite's add(|analyze helper|'s failure)
		set aResult to aSuite's test()
		shouldnt(aResult's hasPassed(), "test passed with defects?!")
	end script
	
	script |suite with an error should fail|
		property parent : registerTestCase(me)
		set aSuite to makeTestSuite(name)
		aSuite's add(|analyze helper|'s success)
		aSuite's add(|analyze helper|'s skip)
		aSuite's add(|analyze helper|'s |error|)
		set aResult to aSuite's test()
		shouldnt(aResult's hasPassed(), "test passed with defects?!")
	end script
	
end script


property properyOfMainScript : true

script scriptInMainScript
	return true
end script


script |access main script context|
	-- Test that test case can access some of main script context
	property parent : registerFixture(me)
	
	script |properties|
		property parent : registerTestCase(me)
		try
			should(properyOfMainScript, name)
		on error msg number errorNumber
			fail(msg & "(" & errorNumber & ")")
		end try
	end script
	
	script |scripts|
		property parent : registerTestCase(me)
		try
			should(run scriptInMainScript, name)
		on error msg number errorNumber
			fail(msg & "(" & errorNumber & ")")
		end try
	end script
	
end script


script |shouldRaise|
	(* To check for errors, the tested code should be closed inside a script object run 
	handler, and the script object should be sent to shouldRaise. *)
	property parent : registerFixture(me)
	
	-- blocks
	
	script |no error|
		set foo to "this can't fail"
	end script
	
	script |raise 500|
		error number 500
	end script
	
	script |raise 501|
		error number 501
	end script
	
	-- helper unregistered tests, to be run by the real tests
	
	script |shouldRaise fail with unexpected error|
		property parent : makeTestCase()
		shouldRaise(500, |raise 501|, name)
	end script
	
	script |shouldRaise fail with no error|
		property parent : makeTestCase()
		shouldRaise(500, |no error|, name)
	end script
	
	script |shouldntRaise fail|
		property parent : makeTestCase()
		shouldntRaise(500, |raise 500|, name)
	end script
	
	-- tests
	
	script |should raise with expected error|
		property parent : registerTestCase(me)
		shouldRaise(500, |raise 500|, name)
	end script
	
	script |shouldnt raise with no error|
		property parent : registerTestCase(me)
		shouldntRaise(500, |no error|, name)
	end script
	
	script |shouldnt raise with another error|
		property parent : registerTestCase(me)
		shouldntRaise(500, |raise 501|, name)
	end script
	
	script |should raise with unexpected error|
		property parent : registerTestCase(me)
		set aResult to |shouldRaise fail with unexpected error|'s test()
		shouldnt(aResult's hasPassed(), name)
	end script
	
	script |should raise with no error|
		property parent : registerTestCase(me)
		set aResult to |shouldRaise fail with no error|'s test()
		shouldnt(aResult's hasPassed(), name)
	end script
	
	script |shouldnt raise with an error|
		property parent : registerTestCase(me)
		set aResult to |shouldntRaise fail|'s test()
		shouldnt(aResult's hasPassed(), name)
	end script
	
end script


script |test case creation|
	-- Note: don't rename me or my tests will break!
	property parent : registerFixture(me)
	
	-- helpers
	
	script |makeTestCase helper|
		property parent : makeTestCase()
		should(true, name)
	end script
	
	-- tests
	
	script |registerTestCase make test case inherit from current fixture|
		property parent : registerTestCase(me)
		should(parent is |test case creation|, "test registration failed")
	end script
	
	script |makeTestCase make test case inherit from current fixture|
		property parent : registerTestCase(me)
		should(|makeTestCase helper|'s parent is |test case creation|, "wrong parent")
	end script
	
	(* TODO: how to test that registerTestCase add a test to the suite and makeTestCase 
	does not? *)
	
end script


script |fixture parent|
	(* A base class for fixture. May be used to share helper handles between different 
	fixtures. Each concrete fixture should register itself with registerFixtureWithParent(me, aParent) *)
	property parent : makeFixture()
	
	on sharedHandler()
		return true
	end sharedHandler
end script


script |concrete fixture|
	property parent : registerFixtureOfKind(me, |fixture parent|)
	
	script |inheriting from user defined fixture|
		property parent : registerTestCase(me)
		should(sharedHandler(), "why?!")
	end script
	
end script


-- Running the tests

run makeTextTestRunner(suite)
