(*!
 @header ASUnit
 	An AppleScript testing framework.
 @abstract License: GNU GPL, see COPYING for details.
 @author Nir Soffer, Lifepillar
 @copyright 2013 Lifepillar, 2006 Nir Soffer
 @version 0.5.0
 @charset macintosh
*)

(*! @abstract <em>[text]</em> ASUnit's version. *)
property version : "0.5.0"
(*! @abstract Error number signalling a failed test. *)
property TEST_FAILED : 1000
(*! @abstract Error number signalling a skipped test. *)
property TEST_SKIPPED : 1001
property TOP_LEVEL : me

(*!
 @abstract Base class for observers.
 @discussion Observers are objects that may get notified by visitors.
 	Concrete observers are supposed to inherit from this script.
*)
script Observer
	
	(*! @abstract TODO *)
	on setNotifier(aNotifier)
	end setNotifier
	
end script -- Observer

(*!
	 @abstract Base class for visitors.
	 @discussion This script defines the interface for a Visitor object.
	 	Subclasses are supposed to override some handlers.
	 	To operate on a suite, you call the suite <tt>accept()</tt> with a visitor.
		ASUnit defines only one visitor, <tt>TestResult</tt>, which runs all the tests in a suite.
		You may create other visitors to do filtered testing, custom reporting and like.
		Your custom visitor should inherit from one of the framework visitors or from <tt>Visitor</tt>.
	*)
script Visitor
	
	(*! @abstract TODO *)
	on visitTestSuite(aTestSuite)
	end visitTestSuite
	
	(*! @abstract TODO *)
	on visitTestCase(TestCase)
	end visitTestCase
	
end script -- Visitor

(*! @abstract TODO *)
on makeTestResult(aName)
	
	(*! @abstract Runs test cases and collects the results. *)
	script TestResult
		
		property parent : Visitor
		property name : aName
		
		(*! @abstract An observer will be notified on visiting progress. *)
		property observers : {}
		
		property startDate : missing value
		property stopDate : missing value
		property passed : {}
		property skips : {}
		property failures : {}
		property errors : {}
		
		(*! @abstract TODO *)
		on addObserver(anObject)
			anObject's setNotifier(me)
			set the end of observers to anObject
		end addObserver
		
		(*!
			 @abstract TODO.
			 @param aTest <em>[script]</em> May be a test case or a test suite.
			*)
		on runTest(aTest)
			try
				startTest()
				aTest's accept(me)
				stopTest()
			on error msg number n
				stopTest()
				error msg number n
			end try
		end runTest
		
		(*! @abstract TODO *)
		on startTest()
			set startDate to current date
			notify({name:"start"})
		end startTest
		
		(*! @abstract TODO *)
		on stopTest()
			set stopDate to current date
			notify({name:"stop"})
		end stopTest
		
		(*! @abstract TODO *)
		on startTestCase(aTestCase)
			notify({name:"start test case", test:aTestCase})
		end startTestCase
		
		(*!
			 @abstract Runs a test case and collects results.
			 @param aTestCase <em>[script]</em> A test case.
			*)
		on visitTestCase(aTestCase)
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
		
		(*! @abstract TODO *)
		on addSuccess(aTestCase)
			set end of passed to aTestCase
			notify({name:"success", test:aTestCase})
		end addSuccess
		
		(*! @abstract TODO *)
		on addSkip(aTestCase, message)
			set end of skips to {test:aTestCase, message:message}
			notify({name:"skip", test:aTestCase})
		end addSkip
		
		(*! @abstract TODO *)
		on addFailure(aTestCase, message)
			set end of failures to {test:aTestCase, message:message}
			notify({name:"fail", test:aTestCase})
		end addFailure
		
		(*! @abstract TODO *)
		on addError(aTestCase, message)
			set end of errors to {test:aTestCase, message:message}
			notify({name:"error", test:aTestCase})
		end addError
		
		(*! @abstract TODO *)
		on notify(anEvent)
			repeat with obs in (a reference to observers)
				obs's update(anEvent)
			end repeat
		end notify
		
		(*! @abstract TODO *)
		on hasPassed()
			return (failures's length) + (errors's length) = 0
		end hasPassed
		
		(*! @abstract TODO *)
		on runCount()
			return (passed's length) + (skips's length) + (failures's length) + (errors's length)
		end runCount
		
		(*! @abstract TODO *)
		on passCount()
			return count of passed
		end passCount
		
		(*! @abstract TODO *)
		on skipCount()
			return count of skips
		end skipCount
		
		(*! @abstract TODO *)
		on errorCount()
			return count of errors
		end errorCount
		
		(*! @abstract TODO *)
		on failureCount()
			return count of failures
		end failureCount
		
		(*! @abstract TODO *)
		on runSeconds()
			return stopDate - startDate
		end runSeconds
		
	end script -- TestResult
	
	return TestResult
	
end makeTestResult

(*!
	 @abstract Factory handler to generate a test script.
	 @discussion This handler is used to create a script inheriting
	 	from the given script, which implements testing assertions.
		This handler is used with both ASUnit's <tt>TestCase</tt>s
		and MiniTest's <tt>UnitTest</tt>s.
	 @param theParent <em>[script]</em> The script to inherit from.
	 @return A script inheriting from the given script and implementing assertions.
	*)
on makeAssertions(theParent)
	script
		property parent : theParent
		
		on test_failed_error_number()
			return TEST_FAILED
		end test_failed_error_number
		
		on test_skipped_error_number()
			return TEST_SKIPPED
		end test_skipped_error_number
		
		(*!
		 @abstract Raises a TEST_SKIPPED error.
		 @param why <em>[text]</em> A message.
		 @throws A TEST_SKIPPED error.
		*)
		on skip(why)
			error why number TEST_SKIPPED
		end skip
		
		(*!
		 @abstract Raises a TEST_FAILED error.
		 @param why <em>[text]</em> A message.
		 @throws A TEST_FAILED error.
		*)
		on fail(why)
			error why number TEST_FAILED
		end fail
		
		(*!
		 @abstract Succeeds when its argument is true.
		 @param expr <em>[boolean]</em> An expression that evaluates to true or false.
		*)
		on ok(expr)
			if not expr then fail("The given expression did not evaluate to true")
		end ok
		
		(*!
		 @abstract Succeeds when its argument is false.
		 @param expr <em>[boolean]</em> An expression that evaluates to true or false.
		*)
		on notOk(expr)
			if expr then fail("The given expression did not evaluate to false")
		end notOk
		
		(*!
		 @abstract Succeeds when the given expression is true.
		 @param expr <em>[boolean]</em> An expression that evaluates to true or false.
		 @param message <em>[text][</em> A message.
		 @throws A <tt>TEST_FAILED</tt> error if the assertion fails.
		*)
		on assert(expr, message)
			if not expr then fail(message)
		end assert
		
		(*! @abstract A synonym for <tt>assert()</tt>. *)
		on should(expr, message)
			assert(expr, message)
		end should
		
		(*!
		 @abstract Succeeds when the given expression is false.
		 @param expr <em>[boolean]</em> An expression that evaluates to true or false.
		 @param message <em>[text][</em> A message.
		 @throws A <tt>TEST_FAILED</tt> error if the assertion fails.
		*)
		on refute(expr, message)
			if expr then fail(message)
		end refute
		
		(*! @abstract A synonym for <tt>refute()</tt>. *)
		on shouldnt(expr, message)
			refute(expr, message)
		end shouldnt
		
		(*!
		 @abstract Fails unless <tt>expectedErrorNumber</tt> is raised
		 	by running <tt>aScript</tt>.
		 @discussion Fails if an unexpected error was raised or no error was raised.
		 @param expectedErrorNumber <em>[integer]</em> or <em>[list]</em>
		 An exception number or a list of exception numbers. To make this assertion
		 succeeds no matter what exception is raised, pass an empty list.
		 @param aScript <em>[script]</em> A script.
		 @param message <em>[text]</em> A message.
		*)
		on shouldRaise(expectedErrorNumber, aScript, message)
			if expectedErrorNumber's class is integer then
				set expectedErrorNumber to {expectedErrorNumber}
			end if
			try
				run aScript
			on error errMsg number errNum
				if (length of expectedErrorNumber > 0) and (expectedErrorNumber does not contain errNum) then
					fail(message & linefeed & errMsg & linefeed & "Exception raised: " & errNum)
				end if
				return
			end try
			fail(message)
		end shouldRaise
		
		(*!
		 @abstract Fails if <tt>expectedErrorNumber</tt> is raised
		 	by running <tt>aScript</tt>.
		 @discussion Fails if a certain error is raised.
		 @param expectedErrorNumber <em>[integer]</em> or <em>[list]</em>
		 An exception number or a list of exception numbers. To make this assertion
		 succeeds only when no exception is raised, pass an empty list.
		 @param aScript <em>[script]</em> A script.
		 @param message <em>[text]</em> A message.
		*)
		on shouldntRaise(expectedErrorNumber, aScript, message)
			if expectedErrorNumber's class is integer then
				set expectedErrorNumber to {expectedErrorNumber}
			end if
			try
				run aScript
			on error errMsg number errNum
				if (the length of expectedErrorNumber = 0) or (expectedErrorNumber contains errNum) then
					fail(message & linefeed & errMsg & linefeed & "Exception raised: " & errNum)
				end if
			end try
		end shouldntRaise
		
		(*!
		 @abstract Succeeds when the two given expressions have the same value.
		 @param expected <em>[anything]</em> The expected value.
		 @param value <em>[anything]</em> Some other value.
		 @throws A <tt>TEST_FAILED</tt> error if the assertion fails.
		*)
		on assertEqual(expected, value)
			local msg, got, wanted, errMsg
			if value's class is not expected's class then
				try -- to coerce classes to text (this may not succeed)
					set wanted to (expected's class) as text
					set got to (value's class) as text
					set msg to "Expected class: " & wanted & linefeed & �
						"Actual class: " & got
				on error -- produce a more generic message
					set msg to "The value does not belong to the expected class."
				end try
				fail(msg)
			end if
			considering case, diacriticals, hyphens, punctuation and white space
				if (value is not expected) then
					try -- to coerce the values to text (this may not succeed)
						set wanted to (expected as text)
						set got to (value as text)
						set msg to "Expected: " & wanted & linefeed & "Actual: " & got
					on error errMsg -- produce a more generic message
						set msg to "Got an unexpected value"
					end try
					fail(msg)
				end if
			end considering
		end assertEqual
		
		(*! @abstract A synonym for <tt>assertEqual()</tt>. *)
		on shouldEqual(expected, value)
			assertEqual(expected, value)
		end shouldEqual
		
		(*!
		 @abstract Succeeds when the two given expressions are different.
		 @param unexpected <em>[anything]</em> The unexpected value.
		 @param value <em>[anything]</em> Some other value.
		 @throws A <tt>TEST_FAILED</tt> error if the assertion fails.
		*)
		on assertNotEqual(unexpected, value)
			local msg, unwanted, errMsg
			if value's class is not equal to unexpected's class then return
			-- else, the values are of the same type
			considering case, diacriticals, hyphens, punctuation and white space
				if value is equal to unexpected then
					try -- to coerce the unexpected value to text (this may not succeed)
						set unwanted to (unexpected as text)
						set msg to "Expected a value different from " & unwanted
					on error errMsg -- produce a more generic message
						set msg to "The values are not different"
					end try
					fail(msg)
				end if
			end considering
		end assertNotEqual
		
		(*! @abstract A synonym for <tt>assertNotEqual()</tt>. *)
		on shouldNotEqual(unexpected, value)
			assertNotEqual(unexpected, value)
		end shouldNotEqual
		
		(*! @abstract Tests whether a variable is a reference. *)
		on assertReference(anObject)
			try
				anObject as reference -- Try to coerce to reference class
			on error
				fail("The given object is not a reference.")
			end try
		end assertReference
		
		(*! @abstract A synonym for <tt>assertReference()</tt>. *)
		on shouldBeReference(anObject)
			assertReference(anObject)
		end shouldBeReference
		
		(*! @abstract Fails when a variable is a reference. *)
		on assertNotReference(anObject)
			try
				anObject as reference -- Try to coerce to reference class
			on error
				return
			end try
			fail("The given object is a reference.")
		end assertNotReference
		
		(*! @abstract A synonym for <tt>assertReference()</tt>. *)
		on shouldNotBeReference(anObject)
			assertNotReference(anObject)
		end shouldNotBeReference
		
	end script
end makeAssertions

(*! @abstract Base class for loggers. *)
script TestLogger
	property parent : Observer
	property _TestResult : missing value
	property separator : "----------------------------------------------------------------------"
	property successColor : {256 * 113, 256 * 140, 256 * 0} -- RGB (113,140,0)
	property defectColor : {256 * 200, 256 * 40, 256 * 41} -- RGB (200,40,41)
	property defaultColor : {256 * 77, 256 * 77, 256 * 76} -- RGB (77,77,76)
	
	(*! @abstract TODO *)
	on setNotifier(aTestResult)
		set my _TestResult to aTestResult
	end setNotifier
	
	(*! @abstract TODO *)
	on update(anEvent)
		set eventName to anEvent's name
		if eventName is "start" then
			printTitle()
		else if eventName is "stop" then
			printSummary()
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
	
	(*! @abstract TODO *)
	on printTitle()
		printLine(((_TestResult's startDate) as text))
		printLine("")
		printLine(_TestResult's name)
		printLine("")
	end printTitle
	
	(*! @abstract TODO *)
	on printSummary()
		printDefects("ERRORS", _TestResult's errors)
		printDefects("FAILURES", _TestResult's failures)
		printCounts()
		printResult()
	end printSummary
	
	(*! @abstract TODO *)
	on printTestCase(aTestCase)
		printString(aTestCase's fullName() & " ... ")
	end printTestCase
	
	(*! @abstract TODO *)
	on printSuccess()
		printColoredString("ok" & linefeed, successColor)
	end printSuccess
	
	(*! @abstract TODO *)
	on printSkip()
		printColoredString("skip" & linefeed, successColor)
	end printSkip
	
	(*! @abstract TODO *)
	on printFail()
		printColoredString("FAIL" & linefeed, defectColor)
	end printFail
	
	(*! @abstract TODO *)
	on printError()
		printColoredString("ERROR" & linefeed, defectColor)
	end printError
	
	(*! @abstract TODO *)
	on printDefects(title, defects)
		if (count of defects) is 0 then return
		printLine("")
		printLine(title)
		repeat with aResult in defects
			printColoredLine(separator, defectColor)
			printColoredLine("test: " & aResult's test's fullName(), defectColor)
			repeat with aLine in every paragraph of aResult's message
				printColoredLine("      " & aLine, defectColor)
			end repeat
		end repeat
		printColoredLine(separator, defectColor)
	end printDefects
	
	(*! @abstract TODO *)
	on printCounts()
		printLine("")
		tell _TestResult
			set elapsed to runSeconds()
			set timeMsg to (elapsed as text) & " second"
			if elapsed is not 1 then set timeMsg to timeMsg & "s"
			set counts to {runCount() & " tests, ", �
				passCount() & " passed, ", �
				failureCount() & " failures, ", �
				errorCount() & " errors, ", �
				skipCount() & " skips."}
		end tell
		printLine("Finished in " & timeMsg & ".")
		printLine("")
		printLine(counts as text)
	end printCounts
	
	(*! @abstract TODO *)
	on printResult()
		printLine("")
		if _TestResult's hasPassed() then
			printColoredLine("OK" & linefeed & linefeed, successColor)
		else
			printColoredLine("FAILED" & linefeed & linefeed, defectColor)
		end if
	end printResult
	
	(*!
	 @abstract Prints the given text with the given style.
	 @discussion This handler must be implemented by subclasses.
	*)
	on printColoredString(aString, aColor)
	end printColoredString
	
	(*! @abstract TODO *)
	on printString(aString)
		printColoredString(aString, defaultColor)
	end printString
	
	(*! @abstract TODO *)
	on printColoredLine(aString, aColor)
		printColoredString(aString & linefeed, aColor)
	end printColoredLine
	
	(*! @abstract TODO *)
	on printLine(aString)
		printColoredLine(aString, defaultColor)
	end printLine
	
end script -- TestLogger		

(*!
 @abstract Displays test results in a new AppleScript Editor document.
*)
script AppleScriptEditorLogger
	property parent : TestLogger
	property textView : missing value
	property windowTitle : "Test Results"
	property loggerPath : ((path to temporary items from user domain) as text) & windowTitle
	
	on printTitle()
		try -- to reuse an existing window
			tell application "AppleScript Editor"
				set textView to get document windowTitle
				set textView's window's index to 1 -- bring to front
			end tell
		on error -- create a new document
			-- Create a file so later we can use an alias
			open for access file loggerPath
			close access file loggerPath
			tell application "AppleScript Editor"
				set textView to make new document �
					with properties {name:windowTitle, path:(POSIX path of loggerPath)}
				save textView as "text" in (loggerPath as alias)
			end tell
		end try
		continue printTitle()
	end printTitle
	
	(*! @abstract TODO *)
	on printColoredString(aString, aColor)
		tell textView
			set selection to insertion point -1
			set contents of selection to aString
			if aColor is not missing value then �
				set color of contents of selection to aColor
			set selection to insertion point -1
		end tell
	end printColoredString
	
	(*! @abstract TODO *)
	on printColoredLine(aString, aColor)
		printColoredString("-- " & aString & linefeed, aColor)
	end printColoredLine
	
	(*! @abstract TODO *)
	on printTestCase(aTestCase)
		printString("-- " & aTestCase's fullName() & " ... ")
	end printTestCase
	
end script -- AppleScriptEditorLogger		

(*!
 @abstract Displays test results in the console.
*)
script ConsoleLogger
	property parent : TestLogger
	property _buffer : ""
	
	on printColoredString(aString, aColor)
		if aString ends with linefeed then
			if the length of aString > 1 then
				set _buffer to _buffer & (text 1 thru -2 of aString)
			end if
			log _buffer
			set _buffer to ""
		else
			set _buffer to _buffer & aString
		end if
	end printColoredString
	
end script -- ConsoleLogger		


-----------------------------------------------------------------
-- The ASUnit framework.
-----------------------------------------------------------------

(*!
	 @abstract <em>[script]</em> Saves the current fixture while compiling
	 	test cases in a fixture.
	*)
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

(*!
	 @abstract The base class for test components.
	 @discussion Test suites are a composite of components.
	 	The basic unit is a single <tt>TestCase</tt>, which may be tested as is.
		Several <tt>TestCase</tt>s are grouped in a <tt>TestSuite</tt>,
		which can test all its tests. A <tt>TestSuite</tt> may contain other
		<tt>TestSuite</tt>s, which may contain other suites.
		Testing a composite returns a <tt>TestResult</tt> object.
	*)
script TestComponent
	
	(*!
		 @abstract Runs a test.
		 @return <em>[script]</em> A <tt>TestResult</tt> object.
		*)
	on test()
		set aTestResult to makeTestResult(name)
		tell aTestResult
			runTest(me)
		end tell
		return aTestResult
	end test
	
	(*!
		 @abstract Tells whether this is a composite test.
		 @discussion Allows transparent handling of components,
		 	avoiding try... on error, e.g., if a's isComposite() then a's add(foo).
		 @return <em>[boolean]</em> <tt>true</tt> if this a composite test;
		 	returns <tt>false</tt> otherwise.
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
	
end script -- TestComponent

(*!
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
	
	(*! @abstract TODO. *)
	on fullName()
		return parent's name & " - " & name
	end fullName
	
end script -- TestCase

(*!
	 @abstract Creates an unregistered fixture inheriting from <tt>TestCase</tt>.
	 @discussion
	 	A user test case inherits from the user fixture, which inherit from <tt>TestCase</tt>.
		Test cases are automatically registered while compiling a script, using two simple rules:
		
			1. Each fixture should call <tt>registerFixture()</tt> to register the fixture
				and set its parent to <tt>TestCase</tt>.
			2. Each tests case should call <tt>registerTestCase()</tt> to register the test case
				and set its parent to the current fixture.
   
		To create a fixture inheriting from a user defined <tt>TestCase</tt>,
		create a script inheriting from <tt>TestCase</tt>, then create the concrete fixture script
		inheriting from your custom <tt>TestCase</tt> script:

		<pre>
		script |user defined TestCase|
			property parent: makeFixture()
			-- define your custom handlers here
		end
		
		script |concrete fixture|
			property parent: registerFixtureOfKind(me, |user defined TestCase|)
			-- define your test cases here
		end
		</pre>
	*)
on makeFixture()
	return makeAssertions(TestCase)
end makeFixture

(*!
	 @abstract Primitive registration handler.
	 @discussion May be used to register a fixture inheriting
	 	from a <tt>TestCase</tt> subclass.
	*)
on registerFixtureOfKind(aUserFixture, aParent)
	set _currentFixture to aUserFixture
	return aParent
end registerFixtureOfKind

(*! @abstract Convenience handler for registering fixture inheriting from <tt>TestCase</tt>. *)
on registerFixture(aUserFixture)
	TestSet(aUserFixture)
end registerFixture

(*! @abstract A more user-friendly name for <tt>registerFixture()</tt>. *)
on TestSet(aUserFixture)
	return registerFixtureOfKind(aUserFixture, makeAssertions(TestCase))
end TestSet

(*!
	 @abstract Creates an unregistered <tt>TestCase</tt> inheriting from the current fixture.
	 @discussion You can run the test case or add it manually to a suite.
	 	This feature is essential for ASUnit own unit tests.
	*)
on makeTestCase()
	return _currentFixture
end makeTestCase

(*!
	 @abstract Creates a test case and registers it with the main script suite.
	 @discussion This test will run automatically when you run the suite.
	*)
on registerTestCase(aUserTestCase)
	UnitTest(aUserTestCase)
end registerTestCase

(*! @abstract A more user-friendly name for <tt>registerTestCase()</tt>. *)
on UnitTest(aUserTestCase)
	set aSuite to aUserTestCase's parent's suite
	if aSuite is not ASUnitSentinel then aSuite's add(aUserTestCase)
	return makeTestCase()
end UnitTest

(*!
	 @abstract Creates a test suite.
	 @discussion Each test script should define a <tt>suite</tt> property to support
	 	automatic registration of test cases. If a suite is not defined, tests will have to be registered
		with a suite manually. You may define your own suite class, inheriting from <tt>TestSuite</tt>.
		Each test script should define a <tt>suite</tt> property and initialize it with <tt>makeTestSuite()</tt>,
		or with a <tt>TestSuite</tt> subclass.
	*)
on makeTestSuite(aName)
	
	(*! @abstract A composite of test cases and test suites. *)
	script TestSuite
		
		property parent : TestComponent
		property name : aName
		property tests : {}
		property loggers : missing value
		
		(*! @abstract TODO. *)
		on accept(aVisitor)
			aVisitor's visitTestSuite(me)
			repeat with aTest in tests
				aTest's accept(aVisitor)
			end repeat
		end accept
		
		(*! @abstract TODO. *)
		on isComposite()
			return true
		end isComposite
		
		(*!
			 @abstract Adds a test case or test suite to this suite.
			 @param aTest <em>[script]</em> May be a <tt>TestCase</tt>
			 	or another <tt>TestSuite</tt> containing other <tt>TestCase</tt>s
				and <tt>TestSuite</tt>s.
			*)
		on add(aTest)
			set end of tests to aTest
		end add
		
	end script -- TestSuite
	
	return TestSuite
	
end makeTestSuite

(*! @abstract Loads tests from files and folders, and returns a suite with all tests. *)
on makeTestLoader()
	
	script TestLoader
		
		-- only files that starts with prefix will be considered as tests
		property prefix : "Test"
		
		(*!
			 @abstract Returns a test suite containing all the suites
			 	in the tests scripts in the specified folder.
			*)
		on loadTestsFromFolder(aFolder)
			set suite to makeTestSuite("All Tests in " & (aFolder as text))
			
			tell application "Finder"
				set testFiles to files of aFolder �
					where name starts with prefix and name ends with ".scpt"
			end tell
			repeat with aFile in testFiles
				suite's add(loadTestsFromFile(aFile))
			end repeat
			
			return suite
		end loadTestsFromFolder
		
		(*!
			 @abstract Returns a test suite from aFile or the default suite.
			 @throws An error if a test file does not have a suite property.
			*)
		on loadTestsFromFile(aFile)
			-- TODOs:
			-- - Should check for comforming suite?
			-- - How to load tests from text format (.applescript)?
			set testScript to load script file (aFile as text)
			try
				set aSuite to testScript's suite
				if testScript's suite is my ASUnitSentinel then MissingSuiteError(aFile)
				return aSuite
			on error number 10
				MissingSuiteError(aFile)
			end try
			
		end loadTestsFromFile
		
		(*! @abstract TODO *)
		on MissingSuiteError(aFile)
			error (aFile as text) & " does not have a suite property"
		end MissingSuiteError
		
	end script -- TestLoader
	
	return TestLoader
	
end makeTestLoader

-----------------------------------------------------------------
-- End of ASUnit framework
-----------------------------------------------------------------

(*! @abstract TODO *)
on autorun(aTestSuite)
	local loggers
	set theTestRunner to makeTestResult(aTestSuite's name)
	-- If the script defines a 'loggers' property, set the loggers based on that.
	-- Otherwise, choose a default logger.
	try
		set loggers to aTestSuite's loggers
		if loggers is missing value then error
		if loggers's class is not list then set loggers to {loggers}
	on error
		if current application's name is "AppleScript Editor" then
			set loggers to {AppleScriptEditorLogger}
		else
			set loggers to {ConsoleLogger}
		end if
	end try
	repeat with aLogger in loggers
		tell theTestRunner to addObserver(aLogger)
	end repeat
	tell theTestRunner to runTest(aTestSuite)
	return
end autorun

on run
	-- Enable loading the library from text format with run script
	return me
end run
