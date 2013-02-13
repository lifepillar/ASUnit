(*!
 @header ASUnit
 	An AppleScript testing framework.
 @abstract License: GNU GPL, see COPYING for details.
 @author Nir Soffer
 @copyright 2006 Nir Soffer
 @version 0.4.2
 @charset macintosh
*)
script ASUnit
	
	(*! @abstract <em>[text]</em> ASUnit's version string.  *)
	property version : "0.4.4"
	
	(*! @abstract <em>[script]</em> Saves the current fixture while compiling test cases in a fixture. *)
	property _currentFixture : missing value
	
	(*!
 @abstract Sentinel object used to mark missing values.
 @discussion This is used, in particular, to catch a missing suite property in a test script.
*)
	script ASUnitSentinel
	end script
	
	(*!
 @abstract Used to automatically collect tests in a script file.
 @discussion If a test script defines its own suite property, this property will be shadowed.
 *)
	property suite : ASUnitSentinel
	
	(*! @abstract Error number signalling a failed test. *)
	property TEST_FAILED : 1000
	(*! @abstract Error number signalling a skipped test. *)
	property TEST_SKIPPED : 1001
	
	
	(*!
 @class TestComponent
 @abstract The base class for test components.
 @discussion Test suites are a composite of components.
 	The basic unit is a single <tt>TestCase</tt>, which may be tested as is.
	Several <tt>TestCase</tt>s are grouped in a <tt>TestSuite</tt>, which can test all its tests.
	A <tt>TestSuite</tt> may contain other <tt>TestSuite</tt>s, which may contain other suites.
	Testing a composite returns a <tt>TestResult</tt> object.
*)
	script TestComponent
		
		(*!
	 @abstract Runs a test.
	 @return <em>[script]</em> A <tt>TestResult</tt> object.
	 *)
		on test()
			set aTestResult to ASUnit's makeTestResult(name)
			tell aTestResult
				runTest(me)
			end tell
			return aTestResult
		end test
		
		(*!
	 @abstract Tells whether this is a composite test.
	 @discussion Allows transparent handling of components,
	 	avoiding try... on error, e.g., if a's isComposite() then a's add(foo).
	 @return <em>[boolean]</em> <tt>true</tt> if this a composite test; <tt>false</tt> otherwise.
	*)
		on isComposite()
			return false
		end isComposite
		
		(*!
	 @abstract Implemented by sub classes.
	 @param aVisitor <em>[script]</em> A visitor.
	*)
		on accept(aVisitor)
			return
		end accept
		
	end script
	
	(*!
 @class TestCase
 @abstract Models a certain configuration of the system being tested.
 @discussion TODO.
*)
	script TestCase
		property parent : TestComponent
		
		(*! @abstract TODO. *)
		on accept(aVisitor)
			tell aVisitor
				visitTestCase(me)
			end tell
		end accept
		
		(*! @abstract May be implemented by a subclass. *)
		on setUp()
		end setUp
		
		(*! @abstract May be implemented by a subclass. *)
		on tearDown()
		end tearDown
		
		(*! @abstract TODO. *)
		on skip(why)
			error why number TEST_SKIPPED
		end skip
		
		(*! @abstract TODO. *)
		on fail(why)
			error why number TEST_FAILED
		end fail
		
		(*!
	 @abstract Runs a test case.
	 @discussion Ensures that <tt>tearDown()</tt> is executed,
	 	even if an error was raised. Errors are passed to the caller.
	@return Nothing.
	 *)
		on runCase()
			try
				setUp()
				run
				tearDown()
			on error message number errorNumber
				tearDown()
				error message number errorNumber
			end try
		end runCase
		
		(*! @abstract Makes sure that the user test script has a <tt>run</tt> method. *)
		on run
			error "test script does not contain any test code"
		end run
		
		(*!
	 @abstract TODO.
	 @param value <em>[boolean]</em> An expression that evaluates to true or false.
	 @param message <em>[text][</em> A message.
	 @throws A <tt>TEST_FAILED</tt> error if the assertion fails.
	 *)
		on should(value, message)
			if value is false then
				fail(message)
			end if
		end should
		
		(*! @abstract TODO. *)
		on shouldnt(value, message)
			if value is true then
				fail(message)
			end if
		end shouldnt
		
		(*!
	 @abstract Fails unless <tt>expectedErrorNumber</tt> is raised by running <tt>aScript</tt>. 
	 @discussion Fails if an unexpected error was raised or no error was raised.
	 *)
		on shouldRaise(expectedErrorNumber, aScript, message)
			try
				run aScript
			on error why number errorNumber
				if errorNumber is not expectedErrorNumber then fail(message & ": " & why)
				return
			end try
			fail(message)
		end shouldRaise
		
		(*! @abstract Fails if <tt>expectedErrorNumber</tt> is raised by running <tt>aScript</tt>. *)
		on shouldntRaise(expectedErrorNumber, aScript, message)
			try
				run aScript
			on error why number errorNumber
				if errorNumber is expectedErrorNumber then fail(message & ": " & why)
			end try
		end shouldntRaise
		
		(*! @abstract TODO. *)
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
					if errorNumber is TEST_SKIPPED then
						addSkip(aTestCase, message)
					else if errorNumber is TEST_FAILED then
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
			
			-- Creates a new AppleScript Editor document
			on makeNewAppleScriptEditorDocument(theName)
				tell application Â
					"AppleScript Editor" to make new document with properties {name:theName}
			end makeNewAppleScriptEditorDocument
			
			property suite : aSuite
			property _TestResult : missing value
			property textView : my makeNewAppleScriptEditorDocument(aSuite's name)
			property separator : "----------------------------------------------------------------------"
			property successColor : {256 * 113, 256 * 140, 256 * 0} -- RGB (113,140,0)
			property defectColor : {256 * 200, 256 * 40, 256 * 41} -- RGB (200,40,41)
			property defaultColor : {256 * 77, 256 * 77, 256 * 76} -- RGB (77,77,76)
			
			-- Configuring
			
			on setTestResult(aTestResult)
				set _TestResult to aTestResult
			end setTestResult
			
			-- Running
			
			on run
				-- Create TestResult and set me as its observer
				if _TestResult is missing value then set _TestResult to ASUnit's makeTestResult(suite's name)
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
				printColoredString(aString, defaultColor)
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
				
				set suite to ASUnit's makeTestSuite("All Tests in " & (aFolder as string))
				
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
	
	(*!
	 @abstract A different way to run your tests.
	*)
	script MiniTest
		
		on makeUnitTest(aScript, aDescription)
			script
				property parent : aScript
				property class : "UnitTest"
				property description : aDescription
				
				(*! @abstract Raises a TEST_SKIPPED error. *)
				on skip(why)
					error why number ASUnit's TEST_SKIPPED
				end skip
				
				(*! @abstract Raises a TEST_FAILED error. *)
				on fail(why)
					error why number ASUnit's TEST_FAILED
				end fail
				
				-- Borrowed from ASTest
				on |==|(val1, val2) -- performs more precise check than AS 'equals' operator alone
					considering case, diacriticals, hyphens, punctuation and white space
						-- class check ensures that (e.g.) 1.0=1 will fail
						return (val1's class is val2's class) and (val1 is val2)
					end considering
				end |==|
				
				on should(cond)
					if not cond then fail("I failed. I am a failure")
				end should
				
				on accept(aVisitor)
					tell aVisitor to visitTestCase(me)
				end accept
				
				on runCase()
					run
				end runCase
				
				(*! @abstract TODO. *)
				on fullName()
					return my parent's name & " - " & my description
				end fullName
				
			end script
		end makeTest
		
		on makeTestSet(aScript, testSetDescription)
			script TestSet
				property parent : aScript
				property class : "TestSet"
				property description : testSetDescription
				property tests : {} -- private
				
				on setUp()
					try -- to invoke parent's setUp()
						continue setUp()
					on error errMsg number errNum
						if errNum is not -1708 then -- -1708 = can't continue
							error errMsg number errNum
						end if
					end try
				end setUp
				
				on tearDown()
					try -- to invoke parent's tearDown()
						continue tearDown()
					on error errMsg number errNum
						if errNum is not -1708 then -- -1708 = can't continue
							error errMsg number errNum
						end if
					end try
				end tearDown
				
				on accept(aVisitor)
					aVisitor's visitTestSuite(me)
					repeat with aTest in tests
						try
							setUp()
							aTest's accept(aVisitor)
							tearDown()
						on error errMsg number errNum
							tearDown()
							error errMsg number errNum
						end try
					end repeat
				end accept
				
				on UnitTest(scriptName, aDescription)
					set the end of tests to MiniTest's makeUnitTest(scriptName, aDescription)
					return "Test"
				end 
				
				on TestSet(scriptName, aDescription)
					set the end of tests to MiniTest's makeTestSet(scriptName, aDescription)
					return "TestSet"
				end |@TestSet|
				
			end script -- TestSet
			
			run TestSet -- Register the tests
			return TestSet
			
		end makeTestSet
		
		on autorun(aTestSet)
			run ASUnit's makeTextTestRunner(makeTestSet(aTestSet, aTestSet's name))
		end autorun
		
	end script -- ASMiniTest
	
end script -- ASUnit

on run
	-- Enable loading the library from text format with run script
	return ASUnit
end run
