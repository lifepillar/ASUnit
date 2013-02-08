(*
ASUnit - AppleScript testing framework

copyright: (c) 2006 Nir Soffer <nirs@freeshell.org>
license: GNU GPL, see COPYING for details
*)

property version : "0.4.1"

-- Save the current fixture while compiling test cases in a fixture
property _currentFixture : missing value

script ASUnitSentinel
	-- Sentinel object used to mark missing values
end script

(* Catch missing suite property in a test script. It a test script define its own suite property, my property will be shadowed. *)
property suite : ASUnitSentinel

-- Errors

property TestCaseFailed : 1000
property TestCaseSkipped : 1001


(* Test Composite

Test suites are a composite of components. The basic unit is a single TestCase, which may be tested as is. Several TestCases are grouped in a TestSuite, which can test all its tests. A TestSuite may contain other TestSuites, which may contain other suites.

Testing a composite return a TestResult object.
*)

script TestComponent
	(* I'm the base class for test components *)
	
	on test()
		set aTestResult to makeTestResult(name)
		aTestResult's runTest(me)
		return aTestResult
	end test
	
	on isComposite()
		(* Allow transparent handling of compontents, avoiding try ... on error 
		e.g. if a's isComposite() then a's add(foo) *)
		return false
	end isComposite
	
	on accept(aVisitor)
		-- implemented by sub classes
	end accept
	
end script


script TestCase
	(* I'm a certain configuration of the system being tested  *)
	
	property parent : TestComponent
	
	-- Visiting
	
	on accept(aVisitor)
		aVisitor's visitTestCase(me)
	end accept
	
	-- Configuration
	
	on setUp()
		-- may be implemented by a subclass
	end setUp
	
	on tearDown()
		-- may be implemented by a subclass
	end tearDown
	
	-- Aborting
	
	on skip(why)
		error why number TestCaseSkipped
	end skip
	
	on fail(why)
		error why number TestCaseFailed
	end fail
	
	-- Running
	
	on runCase()
		(* Ensure that tearDown run, even if an error was raised. Errors are  
		passed to the caller. *)
		try
			setUp()
			run
			tearDown()
		on error message number errorNumber
			tearDown()
			error message number errorNumber
		end try
	end runCase
	
	-- Validation
	
	on run
		-- Make sure the user test script have a run method
		error "test script does not contain any test code"
	end run
	
	-- checking
	
	on should(value, message)
		if value is false then fail(message)
	end should
	
	on shouldnt(value, message)
		if value is true then fail(message)
	end shouldnt
	
	on shouldRaise(expectedErrorNumber, aScript, message)
		(* Fail unless expectedErrorNumber is raise by running aScript  
		
		Fail if unexpected error was raised or no error was raised. *)
		try
			run aScript
		on error why number errorNumber
			if errorNumber is not expectedErrorNumber then fail(message & ": " & why)
			return
		end try
		fail(message)
	end shouldRaise
	
	on shouldntRaise(expectedErrorNumber, aScript, message)
		(* Fail if expectedErrorNumber is raise by running aScript  *)
		try
			run aScript
		on error why number errorNumber
			if errorNumber is expectedErrorNumber then fail(message & ": " & why)
		end try
	end shouldntRaise
	
	-- accessing
	
	on fullName()
		return parent's name & " - " & name
	end fullName
	
end script


(* Creating fixtures and tests cases

A user test case inherits from the user fixture, which inherit from TestCase. Test cases 
are automatically registered while compiling a script, using two simple rules:

1. Each fixture should call registerFixture to register the fixture and set its parent to 
   TestCase.
2. Each tests case should call registerTestCase to register the test case and set its parent 
   to the current fixture.
   
To create a fixture inheriting from a user defined TestCase, create a script inheriting 
from TestCase, then create the concrerte fixture script inheriting from your custom 
TestCase script::

	script |user defined TestCase|
		property parent: makeFixture()
		
		-- define your custom handlers here		
	end
	
	script |concrete fixture|
		property parent: registerFixtureOfKind(me, |user defined TestCase|)
		
		-- define your test cases here
	end	
*)

on makeFixture()
	(* Create an unregistered fixture inheriting from TestCase *)
	return TestCase
end makeFixture

on registerFixtureOfKind(aUserFixture, aParent)
	(* Primitive registration handler, may be used to register a fixture inheriting 
	from a TestCase subclass *)
	set _currentFixture to aUserFixture
	return aParent
end registerFixtureOfKind

on registerFixture(aUserFixture)
	(* Convenience  handler for registering fixture inheriting from TestCase *)
	return registerFixtureOfKind(aUserFixture, TestCase)
end registerFixture

on makeTestCase()
	(* Create an unregistered text case inheriting from the curernt fixture. You can 
	run the test case or add it manually to a suite. This feature is essential for ASUnit 
	own unit tests. *)
	return _currentFixture
end makeTestCase

on registerTestCase(aUserTestCase)
	(* Create a test case and register it with the main script suite. This test will run 
	atomatically when you run the suite. *)
	set aSuite to aUserTestCase's parent's suite
	if aSuite is not ASUnitSentinel then aSuite's add(aUserTestCase)
	return makeTestCase()
end registerTestCase


(* Creating test suites

Each test script should define a suite property to support automatic registration of 
test cases. If a suite is not defined, tests will have to be regitered with a suite 
manually. You may define your own suite class, inheriting from TestSuite.

* Each test script should define a suite property and initialize it with makeTestSuite(), 
  or with a TestSuite subclass.
*)

on makeTestSuite(aName)
	
	script TestSuite
		(* I'm a composite of test cases and test suites. *)
		
		property parent : TestComponent
		property name : aName
		property tests : {}
		
		-- Visiting
		
		on accept(aVisitor)
			aVisitor's visitTestSuite(me)
			repeat with aTest in tests
				aTest's accept(aVisitor)
			end repeat
		end accept
		
		-- Accessing
		
		on isComposite()
			return true
		end isComposite
		
		on add(aTest)
			(* aTest may be a TestCase or another TestSuite containing other TestCases 
			and TestSuites ... *)
			set end of tests to aTest
		end add
		
	end script
	
	return TestSuite
	
end makeTestSuite


(* Visitors

To operate on a suite, you call the suite accept() with a visitor. The framework define only one visitor, TestResult, which run all the tests in a suite. You may create other visitors to do filtered testing, custom reporting and like.

Your custom visitor should inherit from one of the framework visitors or from Visitor.
*)

script Visitor
	(* I visit components and do nothing. Subclass may override some handlers. *)
	
	on visitTestSuite(aTestSuite)
	end visitTestSuite
	
	on visitTestCase(TestCase)
	end visitTestCase
	
end script


on makeTestResult(aName)
	
	script TestResult
		(* I run test cases and collect the results *)
		
		property parent : Visitor
		property name : aName
		
		-- An observer will be notified on visiting progress
		property observer : missing value
		
		property startDate : missing value
		property stopDate : missing value
		property passed : {}
		property skips : {}
		property failures : {}
		property errors : {}
		
		-- Configuring
		
		on setObserver(anObject)
			set observer to anObject
		end setObserver
		
		-- Running
		
		on runTest(aTest)
			-- aTest may be a test case or a test suite.
			try
				startTest()
				aTest's accept(me)
				stopTest()
			on error msg number n
				stopTest()
				error msg number n
			end try
		end runTest
		
		-- Events
		
		on startTest()
			set startDate to current date
			notify({name:"start"})
		end startTest
		
		on stopTest()
			set stopDate to current date
			notify({name:"stop"})
		end stopTest
		
		on startTestCase(aTestCase)
			notify({name:"start test case", test:aTestCase})
		end startTestCase
		
		-- Visiting
		
		on visitTestCase(aTestCase)
			(* Run aTestCase and collect results. *)
			
			startTestCase(aTestCase)
			try
				aTestCase's runCase()
				addSuccess(aTestCase)
			on error message number errorNumber
				if errorNumber is TestCaseSkipped then
					addSkip(aTestCase, message)
				else if errorNumber is TestCaseFailed then
					addFailure(aTestCase, message)
				else
					addError(aTestCase, message & " (" & errorNumber & ")")
				end if
			end try
		end visitTestCase
		
		-- Collecting results
		
		on addSuccess(aTestCase)
			set end of passed to aTestCase
			notify({name:"success", test:aTestCase})
		end addSuccess
		
		on addSkip(aTestCase, message)
			set end of skips to {test:aTestCase, message:message}
			notify({name:"skip", test:aTestCase})
		end addSkip
		
		on addFailure(aTestCase, message)
			set end of failures to {test:aTestCase, message:message}
			notify({name:"fail", test:aTestCase})
		end addFailure
		
		on addError(aTestCase, message)
			set end of errors to {test:aTestCase, message:message}
			notify({name:"error", test:aTestCase})
		end addError
		
		on notify(anEvent)
			if observer is not missing value then observer's update(anEvent)
		end notify
		
		-- Testing
		
		on hasPassed()
			return (failures's length) + (errors's length) = 0
		end hasPassed
		
		-- Accessing
		
		on runCount()
			return (passed's length) + (skips's length) + (failures's length) + (errors's length)
		end runCount
		
		on passCount()
			return count of passed
		end passCount
		
		on skipCount()
			return count of skips
		end skipCount
		
		on errorCount()
			return count of errors
		end errorCount
		
		on failureCount()
			return count of failures
		end failureCount
		
		on runSeconds()
			return stopDate - startDate
		end runSeconds
		
	end script
	
	return TestResult
	
end makeTestResult


(* Running tests

Test runner make it easier to run test and view progress and test results. The framework supply a TextTestRunner that display progress and results in a new Script Editor document window.
*)

on makeTextTestRunner(aSuite)
	script TextTestRunner
		(* I display test results in a new Script Editor document *)
		
		property suite : aSuite
		property _TestResult : missing value
		property textView : make new document with properties {name:aSuite's name}
		property separator : "----------------------------------------------------------------------"
		property successColor : "green"
		property defectColor : "red"
		
		-- Configuring
		
		on setTestResult(aTestResult)
			set _TestResult to aTestResult
		end setTestResult
		
		-- Running
		
		on run
			-- Create TestResult and set me as its observer
			if _TestResult is missing value then set _TestResult to makeTestResult(suite's name)
			_TestResult's setObserver(me)
			
			-- Test the suite and print results.
			_TestResult's runTest(suite)
			printDefects("ERRORS", _TestResult's errors)
			printDefects("FAILURES", _TestResult's failures)
			printCounts()
			printResult()
		end run
		
		-- Updating
		
		on update(anEvent)
			set eventName to anEvent's name
			if eventName is "start" then
				printTitle()
			else if eventName is "start test case" then
				printTestCase(anEvent's test)
			else if eventName is "success" then
				printSuccess()
			else if eventName is "skip" then
				printSkip()
			else if eventName is "fail" then
				printFail()
			else if eventName is "error" then
				printError()
			end if
		end update
		
		-- Printing
		
		on printTitle()
			printLine((_TestResult's startDate) as string)
			printLine("")
			printLine(_TestResult's name)
			printLine("")
		end printTitle
		
		on printTestCase(aTestCase)
			printString(aTestCase's fullName() & " ... ")
		end printTestCase
		
		on printSuccess()
			printColoredLine("ok", successColor)
		end printSuccess
		
		on printSkip()
			printColoredLine("skip", successColor)
		end printSkip
		
		on printFail()
			printColoredLine("FAIL", defectColor)
		end printFail
		
		on printError()
			printColoredLine("ERROR", defectColor)
		end printError
		
		on printDefects(title, defects)
			if (count of defects) is 0 then return
			
			printLine("")
			printLine(title)
			repeat with aResult in defects
				printLine(separator)
				printLine("test: " & aResult's test's fullName())
				printLine("message: " & aResult's message)
			end repeat
			printLine(separator)
		end printDefects
		
		on printCounts()
			printLine("")
			tell _TestResult
				set counts to {"Ran " & runCount() & " tests in " & runSeconds() & " seconds.", Â
					"  passed: " & passCount(), Â
					"  skips: " & skipCount(), Â
					"  errors: " & errorCount(), Â
					"  failures: " & failureCount()}
			end tell
			printLine(counts as string)
		end printCounts
		
		on printResult()
			printLine("")
			if _TestResult's hasPassed() then
				printColoredLine("OK", successColor)
			else
				printColoredLine("FAILED", defectColor)
			end if
		end printResult
		
		-- Printing primitives
		
		on printLine(aString)
			printString(aString & return)
		end printLine
		
		on printColoredLine(aString, aColor)
			printColoredString(aString & return, aColor)
		end printColoredLine
		
		on printString(aString)
			printColoredString(aString, missing value)
		end printString
		
		on printColoredString(aString, aColor)
			tell textView
				set selection to insertion point -1
				set contents of selection to aString
				if aColor is not missing value then Â
					set color of contents of selection to aColor
				set selection to insertion point -1
			end tell
		end printColoredString
		
	end script
	
	return TextTestRunner
	
end makeTextTestRunner


-- Loading tests

on makeTestLoader()
	
	script TestLoader
		(* I load tests from files and folders, and return a suite with all tests *)
		
		-- only files that starts with prefix will be considered as tests
		property prefix : "Test"
		
		on loadTestsFromFolder(aFolder)
			(* Return a test suite containng all the suites in the tests scripts 
			in aFolder *)
			
			set suite to makeTestSuite("All Tests in " & (aFolder as string))
			
			tell application "Finder"
				set testFiles to files of aFolder Â
					where name starts with prefix and name ends with ".scpt"
			end tell
			repeat with aFile in testFiles
				suite's add(loadTestsFromFile(aFile))
			end repeat
			
			return suite
		end loadTestsFromFolder
		
		on loadTestsFromFile(aFile)
			(* Return a test suite from aFile or the default suite. 
		
			Raise error if a test file does not have a suite property.
		
			TODO:
			- should check for comforming suite?
			- how to load tests from text format (.applescript)?
			*)
			
			set testScript to load script file (aFile as string)
			try
				set aSuite to testScript's suite
				if testScript's suite is my ASUnitSentinel then MissingSuiteError(aFile)
				return aSuite
			on error number 10
				MissingSuiteError(aFile)
			end try
			
		end loadTestsFromFile
		
		on MissingSuiteError(aFile)
			error (aFile as string) & " does not have a suite property"
		end MissingSuiteError
		
	end script
	
	return TestLoader
end makeTestLoader


on run
	set ASUnit to me
	-- Enable loading the library from text format with run script
	return me
end run
