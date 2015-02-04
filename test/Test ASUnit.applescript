(*!
	@header ASUnit
		ASUnit self tests.
	@abstract License: GNU GPL, see COPYING for details.
	@author NirSoffer, Lifepillar
	@copyright 2013–2015 Lifepillar, 2006 Nir Soffer
	@charset: macintosh
*)
use scripting additions
use ASUnit : script "com.lifepillar/ASUnit"
property parent : ASUnit
property name : "Unit tests for ASUnit"
property TestASUnit : me -- Needed to refer to top level entities from some tests
property suite : makeTestSuite("ASUnit Tests")

-- Test ASUnit with non-standard text item delimiters
on changeTextItemDelimiters()
	local astid
	set {astid, AppleScript's text item delimiters} to {AppleScript's text item delimiters, "##"}
	return astid
end changeTextItemDelimiters

property tid : changeTextItemDelimiters()

log my parent's name & space & my parent's version
tell my ScriptEditorLogger -- Customize colors
	set its defaultColor to {256 * 30, 256 * 20, 256 * 10} -- RGB(30,20,10)
	set its successColor to {256 * 1, 256 * 102, 256 * 146} -- RGB(1,102,146)
	set its defectColor to {256 * 255, 256 * 108, 256 * 96} -- RGB(255,108,96)
end tell
tell my StdoutLogger -- Customize colors when tests are run with osascript
	--set its defaultColor to its boldType
	--set its successColor to bb(its green) -- bold green
	--set its defectColor to bb(its red) -- bold red
end tell

--set suite's loggers to {ScriptEditorLogger, ConsoleLogger}
set AppleScript's text item delimiters to "%%"
my autorun(suite)
set AppleScript's text item delimiters to my tid
return


script |ASUnit name and bundle id|
	property parent : TestSet(me)
	property ThisTestSet : me
	
	script |This test script's name|
		property parent : UnitTest(me)
		assertEqual("Unit tests for ASUnit", TestASUnit's name)
	end script
	
	script |A unit test's name is accessible|
		property parent : UnitTest(me)
		assertEqual("A unit test's name is accessible", my name)
	end script
	
	script |The parent of a unit test is the wrapping test set|
		property parent : UnitTest(me)
		assertEqual("ASUnit name and bundle id", my parent's name)
	end script
	
	script |A test set descends from TestCase|
		property parent : UnitTest(me)
		assertEqual("TestCase", ThisTestSet's parent's parent's name)
		assertInheritsFrom(ASUnit's TestCase, ASUnit's TestSet(me))
	end script
	
	script |Bundle name|
		property parent : UnitTest(me)
		assertEqual("ASUnit", ASUnit's name)
	end script
	
	script |Bundle id|
		property parent : UnitTest(me)
		assertEqual("com.lifepillar.ASUnit", ASUnit's id)
	end script
	
end script

script |ASUnit architecture|
	property parent : TestSet(me)
	-- -1700 (Can't make x into type reference) is raised by AS Editor
	-- -1728 (Can't get x) is raised by osascript
	property cantGetVar : {-1700, -1728}
	
	script |test Observer|
		property parent : UnitTest(me)
		script DoesNotInheritFromTopLevel
			ASUnit's Observer's TEST_FAILED
		end script
		shouldRaise(cantGetVar, DoesNotInheritFromTopLevel, ¬
			"Observer should not define TEST_FAILED.")
		assertEqual(AppleScript, ASUnit's Observer's parent)
		assertEqual("Observer", ASUnit's Observer's name)
		refuteInheritsFrom(ASUnit, ASUnit's Observer)
	end script
	
	script |test Visitor|
		property parent : UnitTest(me)
		script DoesNotInheritFromTopLevel
			ASUnit's Visitor's TEST_FAILED
		end script
		shouldRaise(cantGetVar, DoesNotInheritFromTopLevel, ¬
			"Visitor should not define TEST_FAILED.")
		assertEqual(AppleScript, ASUnit's Visitor's parent)
		assertEqual("Visitor", ASUnit's Visitor's name)
		refuteInheritsFrom(ASUnit, ASUnit's Visitor)
	end script
	
	script |test TestResult|
		property parent : UnitTest(me)
		property TestResult : missing value
		set TestResult to ASUnit's makeTestResult("Name of test result")
		script DoesNotInheritFromTopLevel
			TestResult's TEST_FAILED
		end script
		shouldRaise(cantGetVar, DoesNotInheritFromTopLevel, ¬
			"TestResult should not define TEST_FAILED.")
		assertEqual(ASUnit's Visitor, TestResult's parent)
		assertEqual("Name of test result", TestResult's name)
		refuteInheritsFrom(ASUnit, TestResult)
	end script
	
	script |test TestAssertions|
		property parent : UnitTest(me)
		property TestAssertions : missing value
		set TestAssertions to ASUnit's makeAssertions(ASUnit's TestCase)
		script DoesNotInheritFromTopLevel
			TestAssertions's TEST_FAILED
		end script
		shouldRaise(cantGetVar, DoesNotInheritFromTopLevel, ¬
			"TestAssertions should not define TEST_FAILED.")
		assertEqual(ASUnit's TestCase, TestAssertions's parent)
		assertEqual("TestAssertions", TestAssertions's name)
		refuteInheritsFrom(ASUnit, TestAssertions)
	end script
	
	script |test TestLogger|
		property parent : UnitTest(me)
		script DoesNotInheritFromTopLevel
			ASUnit's TestLogger's TEST_FAILED
		end script
		shouldRaise(cantGetVar, DoesNotInheritFromTopLevel, ¬
			"TestLogger should not define TEST_FAILED.")
		assertEqual(ASUnit's Observer, ASUnit's TestLogger's parent)
		assertEqual("TestLogger", ASUnit's TestLogger's name)
		refuteInheritsFrom(ASUnit, ASUnit's TestLogger)
	end script
	
	script |test ScriptEditorLogger|
		property parent : UnitTest(me)
		script DoesNotInheritFromTopLevel
			ASUnit's ScriptEditorLogger's TEST_FAILED
		end script
		shouldRaise(cantGetVar, DoesNotInheritFromTopLevel, ¬
			"ScriptEditorLogger should not define TEST_FAILED.")
		assertEqual(ASUnit's TestLogger, ASUnit's ScriptEditorLogger's parent)
		assertEqual("ScriptEditorLogger", ASUnit's ScriptEditorLogger's name)
		refuteInheritsFrom(ASUnit, ASUnit's ScriptEditorLogger)
	end script
	
	script |test ConsoleLogger|
		property parent : UnitTest(me)
		script DoesNotInheritFromTopLevel
			ASUnit's ConsoleLogger's TEST_FAILED
		end script
		shouldRaise(cantGetVar, DoesNotInheritFromTopLevel, ¬
			"ConsoleLogger should not define TEST_FAILED.")
		assertEqual(ASUnit's TestLogger, ASUnit's ConsoleLogger's parent)
		assertEqual("ConsoleLogger", ASUnit's ConsoleLogger's name)
		refuteInheritsFrom(ASUnit, ASUnit's ConsoleLogger)
	end script
	
	script |test ASUnitSentinel|
		property parent : UnitTest(me)
		script DoesNotInheritFromTopLevel
			ASUnit's ASUnitSentinel's TEST_FAILED
		end script
		shouldRaise(cantGetVar, DoesNotInheritFromTopLevel, ¬
			"ASUnitSentinel should not define TEST_FAILED.")
		assertEqual(AppleScript, ASUnit's ASUnitSentinel's parent)
		refuteInheritsFrom(ASUnit, ASUnit's ASUnitSentinel)
	end script
	
	script |test TestComponent|
		property parent : UnitTest(me)
		script DoesNotInheritFromTopLevel
			ASUnit's TestComponent's TEST_FAILED
		end script
		shouldRaise(cantGetVar, DoesNotInheritFromTopLevel, ¬
			"TestComponent should not define TEST_FAILED.")
		assertEqual(AppleScript, ASUnit's TestComponent's parent)
		assertEqual("TestComponent", ASUnit's TestComponent's name)
		refuteInheritsFrom(ASUnit, ASUnit's TestComponent)
	end script
	
	script |test TestCase|
		property parent : UnitTest(me)
		script DoesNotInheritFromTopLevel
			ASUnit's TestCase's TEST_FAILED
		end script
		shouldRaise(cantGetVar, DoesNotInheritFromTopLevel, ¬
			"TestCase should not define TEST_FAILED.")
		assertEqual(ASUnit's TestComponent, ASUnit's TestCase's parent)
		assertEqual("TestCase", ASUnit's TestCase's name)
		refuteInheritsFrom(ASUnit, ASUnit's TestCase)
	end script
	
	script |test TestSuite|
		property parent : UnitTest(me)
		property TestSuite : missing value
		set TestSuite to ASUnit's makeTestSuite("Name of test suite")
		script DoesNotInheritFromTopLevel
			TestSuite's TEST_FAILED
		end script
		shouldRaise(cantGetVar, DoesNotInheritFromTopLevel, ¬
			"TestSuite should not define TEST_FAILED.")
		assertEqual(ASUnit's TestComponent, TestSuite's parent)
		assertEqual("Name of test suite", TestSuite's name)
		refuteInheritsFrom(ASUnit, TestSuite)
	end script
	
	script |test TestLoader|
		property parent : UnitTest(me)
		property TestLoader : missing value
		set TestLoader to ASUnit's makeTestLoader()
		assertEqual(contents of ASUnit, TestLoader's parent)
		assertEqual("TestLoader", TestLoader's name)
		assertInheritsFrom(contents of ASUnit, TestLoader)
	end script
end script

script |test failIf|
	property parent : TestSet(me)
	
	script |nested failIf|
		property parent : UnitTest(me)
		on willFail(dummy)
			failIf(my ok, {true}, "")
		end willFail
		failIf(willFail, {0}, "Nested failIf() should not fail.")
	end script
	
end script

script |should and shouldnt|
	property parent : TestSet(me)
	
	script |should succeed with true|
		property parent : UnitTest(me)
		should(true, name)
	end script
	
	script |shouldnt succeed with false|
		property parent : UnitTest(me)
		shouldnt(false, name)
	end script
	
	script |should fail with false|
		property parent : UnitTest(me)
		
		script |unregistered failure|
			property parent : makeTestCase()
			should(false, name)
		end script
		set aResult to |unregistered failure|'s test()
		should(aResult's hasPassed() is false, "should passed with false?!")
	end script
	
	script |shouldnt fail with true|
		property parent : UnitTest(me)
		
		script |unregistered failure|
			property parent : makeTestCase()
			shouldnt(true, name)
		end script
		set aResult to |unregistered failure|'s test()
		shouldnt(aResult's hasPassed(), "shouldnt passed with true?!")
	end script
	
end script

script |ok, notOk, assert and refute|
	property parent : TestSet(me)
	
	script |ok succeeds with true|
		property parent : UnitTest(me)
		ok(true)
	end script
	
	script |notOk succeeds with false|
		property parent : UnitTest(me)
		notOk(false)
	end script
	
	script |assert succeeds with true|
		property parent : UnitTest(me)
		assert(true, "true should be true.")
	end script
	
	script |refute succeeds with false|
		property parent : UnitTest(me)
		refute(false, "false should be false.")
	end script
	
end script -- ok, notOk, assert and refute

script |assert equal (exact and approximate)|
	property parent : TestSet(me)
	
	script |compare equal values|
		property parent : UnitTest(me)
		assertEqual(2, 1 + 1)
		assertEqual("ab", "a" & "b")
		shouldEqual({} as text, "")
		shouldEqual(|compare equal values|, |compare equal values|)
		assertEqual(current application, current application)
	end script
	
	script |compare different values|
		property parent : UnitTest(me)
		failIf(my assertEqual, {1, "a"}, "1 should be different from a.")
		failIf(my assertEqual, {script, "a"}, "script should be different from a.")
		failIf(my assertEqual, {AppleScript, current application}, "script should be different from a.")
	end script
	
	script |equal within absolute error|
		property parent : UnitTest(me)
		assertEqualAbsError(1, 1 + 1.0E-5, 1.0E-4)
	end script
	
	script |equal within relative error|
		property parent : UnitTest(me)
		assertEqualRelError(100, 104, 0.05) -- Equal within 5% tolerance
	end script
	
end script -- assert equal

script |assert not equal|
	property parent : TestSet(me)
	
	script |compare different values|
		property parent : UnitTest(me)
		script EmptyScript
		end script
		assertNotEqual(1, "a")
		assertNotEqual(|compare different values|, EmptyScript)
		assertNotEqual(|compare different values|, {})
		shouldNotEqual({1}, {2})
		shouldNotEqual(1 + 1, 3)
		assertNotEqual(AppleScript, current application)
	end script
	
	script |compare a value with a reference|
		property parent : UnitTest(me)
		refuteEqual("x", a reference to item 1 of {"x"})
	end script
	
end script -- assert not equal

script |assert instance of|
	property parent : TestSet(me)
	
	script |test classes of expressions|
		property parent : UnitTest(me)
		assertInstanceOf(integer, 1)
		assertInstanceOf(real, 2.7)
		failIf(my assertInstanceOf, {number, 1}, "1 should be an instance of integer.")
		failIf(my assertInstanceOf, {number, 2.7}, "2.7 should be an instance of real.")
		assertInstanceOf(text, "abc")
		assertInstanceOf(list, {})
		assertInstanceOf(record, {a:1})
		assertInstanceOf(date, current date)
		assertInstanceOf(boolean, 1 = 1)
		assertInstanceOf(class, class of class of 1)
		assertInstanceOf(real, pi)
		assertInstanceOf(script, me)
		-- "class of current application" collapses to "class"
		refuteInstanceOf(application, current application) -- AS bug?
		-- should be 'application' according to The AppleScript Language Guide
		assertInstanceOf(null, application "Finder") -- AS bug?
		set f to POSIX file "/Users/myUser/Feb_Meeting_Notes.rtf"
		assertInstanceOf(«class furl», f) -- shouldn't be 'file'?
		assertInstanceOf(grams, 1 as grams)
		refuteInstanceOf(number, 1)
		refuteInstanceOf(real, 1)
		refuteInstanceOf(RGB color, {1, 2, 70000})
		refuteInstanceOf(RGB color, {65535, 65535, 65535})
		refuteInstanceOf(kilograms, 1 as grams)
		refuteInstanceOf(list, {a:1})
		refuteInstanceOf(file, f)
		refuteInstanceOf(POSIX file, f)
		refuteInstanceOf(alias, f)
	end script
	
end script

script |Test for missing values and nulls|
	property parent : TestSet(me)
	
	script |test assertMissing|
		property x : missing value
		assertMissing(missing value)
		assertMissing(x)
		failIf(assertMissing, {null}, "null should not be equal to missing value")
	end script
	
	script |test refuteMissing|
		property x : {}
		refuteMissing(x)
		refuteMissing(null)
	end script
	
	script |test assertNull|
		property x : null
		assertNull(null)
		assertNull(x)
		failIf(assertNull, {missing value}, "missing value should not be equal to null")
	end script
	
	script |test refuteNull|
		property x : {}
		refuteNull(x)
		refuteNull(missing value)
	end script
	
end script

script |Kind of|
	property parent : TestSet(me)
	property x : missing value
	
	on setUp()
		set x to missing value
	end setUp
	
	script |kind of user-defined class|
		property parent : UnitTest(me)
		
		script Father
			property class : "Father"
		end script
		
		script Child
			property parent : Father
			property class : "Child"
		end script
		
		assertInstanceOf("Child", Child)
		assertInstanceOf("Father", Father)
		refuteInstanceOf("Child", Father)
		refuteInstanceOf("Father", Child)
		refuteInstanceOf(script, Child)
		refuteInstanceOf(script, Father)
		assertInheritsFrom(Father, Child)
		assertInheritsFrom(AppleScript, Child)
		assertInheritsFrom(current application, Child)
		refuteInheritsFrom(Child, Father)
		assertKindOf("Father", Child)
		refuteKindOf("Child", Father)
		assertKindOf(script, Child)
	end script
	
	script |Child of integer in kind of number|
		property parent : UnitTest(me)
		script x
			property parent : 1
		end script
		assertInstanceOf(script, x)
		refuteInstanceOf(number, x)
		refuteInstanceOf(integer, x)
		assertKindOf(integer, x)
		assertKindOf(number, x)
	end script
	
end script

script |Test inheritance assertions|
	property parent : TestSet(me)
	
	on scriptWithParent(theParent)
		script
			property parent : theParent
			property class : theParent's class -- Avoids infinite loop when accessing script's class
		end script
	end scriptWithParent
	
	script |inherits from AppleScript|
		property parent : UnitTest(me)
		assertInheritsFrom(AppleScript, me)
		failIf(my refuteInheritsFrom, {AppleScript, me}, "")
	end script
	
	script |inherits from top level|
		property parent : UnitTest(me)
		script x
		end script
		assertInheritsFrom(TestASUnit, x)
		refuteInheritsFrom(x, x)
	end script
	
	script |inherits from list|
		property parent : UnitTest(me)
		set x to scriptWithParent({})
		assertInheritsFrom({}, x)
		refuteInheritsFrom({1}, x)
		failIf(my refuteInheritsFrom, {{}, x}, "")
	end script
	
	script |test current application|
		property parent : UnitTest(me)
		
		set x to current application -- does not have a parent
		refuteInheritsFrom(x, x)
		failIf(my assertInheritsFrom, {x, x}, "")
	end script
	
	script |self-inheritance|
		property parent : UnitTest(me)
		script Loop
			property parent : me
		end script
		set x to scriptWithParent(Loop)
		assertInheritsFrom(Loop, Loop)
		
		failIf(my refuteInheritsFrom, {Loop, Loop}, "")
		(*
		assertInheritsFrom(Loop, x)
		assertNotEqual(x, Loop) -- "x's class" hangs if x's class is not explicitly defined (AS 2.3, OS X 10.9)
		assertNotEqual(Loop's parent, x)
		refuteInheritsFrom(x, Loop)
		*)
	end script
	
end script

script |assert (not) reference|
	property parent : TestSet(me)
	
	script |test Finder reference|
		property parent : UnitTest(me)
		assertReference(path to me)
		tell application "Finder" to set x to folder of file (path to me)
		assertReference(x)
	end script
	
	script |test 'a reference to' operator|
		property parent : UnitTest(me)
		property x : 3
		set y to a reference to x
		assertReference(y)
	end script
	
	script |test assertNotReference|
		property parent : UnitTest(me)
		property x : 1
		assertNotReference(x)
		assertNotReference({})
		set y to a reference to x
		assertNotReference(contents of y)
	end script
	
	script |use ASUnit sets a reference|
		property parent : UnitTest(me)
		assertReference(ASUnit)
		assertNotReference(contents of ASUnit)
	end script
	
	script |Reference to ASUnit|
		property parent : UnitTest(me)
		property scriptRef : a reference to TestASUnit's ASUnit
		assertReference(scriptRef)
		assertReference(contents of scriptRef)
		assertNotReference(contents of (contents of (scriptRef)))
	end script
	
end script -- assert (not) reference


script |skipping test helper|
	-- I'm a helper fixture for the skip tests..
	property parent : TestSet(me)
	
	script test
		property parent : makeTestCase()
		skip("I feel skippy")
		should(true, name)
	end script
end script


script |skipping setup helper|
	-- I'm a helper fixture for the skip tests..
	property parent : TestSet(me)
	
	on setUp()
		skip("I feel skippy")
	end setUp
	
	script test
		property parent : makeTestCase()
		should(true, name)
	end script
end script


script skipping
	property parent : TestSet(me)
	
	script |skipping test|
		property parent : UnitTest(me)
		set aResult to |skipping test helper|'s test's test()
		should(aResult's hasPassed(), "test failed")
		should(aResult's skipCount() = 1, "skipCount ≠ 1")
	end script
	
	script |skipping setup|
		property parent : UnitTest(me)
		set aResult to |skipping setup helper|'s test's test()
		should(aResult's hasPassed(), "test failed")
		should(aResult's skipCount() = 1, "skipCount ≠ 1")
	end script
	
end script


script |errors setUp helper|
	-- I'm a helper for tearDown tests
	property parent : TestSet(me)
	
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
	property parent : TestSet(me)
	
	script test
		property parent : makeTestCase()
		error "I feel nasty"
	end script
	
end script


script |errors tearDown helper|
	-- I'm a helper for tearDown tests
	property parent : TestSet(me)
	
	on tearDown()
		error "tearDown raised an error"
	end tearDown
	
	script test
		property parent : makeTestCase()
		should(true, name)
	end script
	
end script


script errors
	property parent : TestSet(me)
	
	script |error in setup|
		property parent : UnitTest(me)
		set aResult to |errors setUp helper|'s test's test()
		shouldnt(aResult's hasPassed(), "error in setup ignored")
		should(aResult's errorCount() = 1, "errorCount ≠ 1")
	end script
	
	script |error in test case|
		property parent : UnitTest(me)
		set aResult to |errors test case helper|'s test's test()
		shouldnt(aResult's hasPassed(), "error in test case ignored")
		should(aResult's errorCount() = 1, "errorCount ≠ 1")
	end script
	
	script |error in tearDown|
		property parent : UnitTest(me)
		set aResult to |errors tearDown helper|'s test's test()
		shouldnt(aResult's hasPassed(), "error in tearDown ignored")
		should(aResult's errorCount() = 1, "errorCount ≠ 1")
	end script
	
end script


script setUp
	property parent : TestSet(me)
	property setUpDidRun : false
	
	on setUp()
		set setUpDidRun to true
	end setUp
	
	script |setup run before test|
		property parent : UnitTest(me)
		should(setUpDidRun, "setup did not run before the test")
	end script
	
end script


script |tearDown helper|
	-- I'm a helper to tearDown tests
	property parent : TestSet(me)
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
	property parent : TestSet(me)
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
	property parent : TestSet(me)
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
	property parent : TestSet(me)
	
	script |run after failed test|
		property parent : UnitTest(me)
		set aResult to (|tearDown helper|'s |failing test|'s test())
		if aResult's hasPassed() then error "failing test did not fail, can't test tearDown"
		should(|tearDown helper|'s tearDownDidRun, name)
	end script
	
	script |run after error in test|
		property parent : UnitTest(me)
		set aResult to (|tearDown helper|'s |erroring test|'s test())
		if aResult's hasPassed() then error "erroring test did not error, can't test tearDown"
		should(|tearDown helper|'s tearDownDidRun, name)
	end script
	
	script |run after skipping test|
		property parent : UnitTest(me)
		set aResult to (|tearDown helper|'s |skipping test|'s test())
		if aResult's skipCount() ≠ 1 then error "skipping test did not skip, can't test tearDown"
		should(|tearDown helper|'s tearDownDidRun, name)
	end script
	
	script |run after skip in setup|
		property parent : UnitTest(me)
		set aResult to (|skip in setUp helper|'s test's test())
		if aResult's skipCount() ≠ 1 then error "there was no skip, can't test tearDown"
		should(|skip in setUp helper|'s tearDownDidRun, name)
	end script
	
	script |run after error in setup|
		property parent : UnitTest(me)
		set aResult to (|error in setUp helper|'s test's test())
		if aResult's hasPassed() then error "there was no error, can't test tearDown"
		should(|error in setUp helper|'s tearDownDidRun, name)
	end script
	
end script


script |invalid test case|
	property parent : TestSet(me)
	
	script |unregistered test without run handler|
		property parent : makeTestCase()
	end script
	
	script |no run handler|
		property parent : UnitTest(me)
		set aResult to |unregistered test without run handler|'s test()
		shouldnt(aResult's hasPassed(), "test passed with an error?!")
	end script
	
end script


script |analyze helper|
	-- I'm a helper fixture. All my tests are NOT registered in this suite
	property parent : TestSet(me)
	
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
	property parent : TestSet(me)
	
	script |check counts|
		property parent : UnitTest(me)
		set aSuite to TestASUnit's makeTestSuite(name)
		aSuite's add(|analyze helper|'s success)
		aSuite's add(|analyze helper|'s success)
		aSuite's add(|analyze helper|'s skip)
		aSuite's add(|analyze helper|'s |error|)
		aSuite's add(|analyze helper|'s failure)
		set aResult to aSuite's test()
		should(aResult's runCount() = 5, "runCount ≠ 5")
		should(aResult's passCount() = 2, "passCount ≠ 2")
		should(aResult's skipCount() = 1, "skipCount ≠ 1")
		should(aResult's failureCount() = 1, "failureCount ≠ 1")
		should(aResult's errorCount() = 1, "errorCount ≠ 1")
	end script
	
	script |suite with success should pass|
		property parent : UnitTest(me)
		set aSuite to TestASUnit's makeTestSuite(name)
		aSuite's add(|analyze helper|'s success)
		aSuite's add(|analyze helper|'s success)
		set aResult to aSuite's test()
		should(aResult's hasPassed(), "test failed without defects?!")
	end script
	
	script |suite with skips should pass|
		property parent : UnitTest(me)
		set aSuite to TestASUnit's makeTestSuite(name)
		aSuite's add(|analyze helper|'s success)
		aSuite's add(|analyze helper|'s skip)
		aSuite's add(|analyze helper|'s skip)
		set aResult to aSuite's test()
		should(aResult's hasPassed(), "test failed without defects?!")
	end script
	
	script |suite with a failure should fail|
		property parent : UnitTest(me)
		set aSuite to TestASUnit's makeTestSuite(name)
		aSuite's add(|analyze helper|'s success)
		aSuite's add(|analyze helper|'s skip)
		aSuite's add(|analyze helper|'s failure)
		set aResult to aSuite's test()
		shouldnt(aResult's hasPassed(), "test passed with defects?!")
	end script
	
	script |suite with an error should fail|
		property parent : UnitTest(me)
		set aSuite to TestASUnit's makeTestSuite(name)
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
	property parent : TestSet(me)
	
	script |properties|
		property parent : UnitTest(me)
		try
			should(properyOfMainScript, name)
		on error msg number errorNumber
			fail(msg & "(" & errorNumber & ")")
		end try
	end script
	
	script |scripts|
		property parent : UnitTest(me)
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
	property parent : TestSet(me)
	
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
	
	script |shouldNotRaise fail|
		property parent : makeTestCase()
		shouldNotRaise(500, |raise 500|, name)
	end script
	
	-- tests
	
	script |should raise with expected error|
		property parent : UnitTest(me)
		shouldRaise(500, |raise 500|, name)
	end script
	
	script |shouldnt raise with no error|
		property parent : UnitTest(me)
		shouldNotRaise(500, |no error|, name)
	end script
	
	script |shouldnt raise with another error|
		property parent : UnitTest(me)
		shouldNotRaise(500, |raise 501|, name)
	end script
	
	script |should raise with unexpected error|
		property parent : UnitTest(me)
		set aResult to |shouldRaise fail with unexpected error|'s test()
		shouldnt(aResult's hasPassed(), name)
	end script
	
	script |should raise with no error|
		property parent : UnitTest(me)
		set aResult to |shouldRaise fail with no error|'s test()
		shouldnt(aResult's hasPassed(), name)
	end script
	
	script |shouldnt raise with an error|
		property parent : UnitTest(me)
		set aResult to |shouldNotRaise fail|'s test()
		shouldnt(aResult's hasPassed(), name)
	end script
	
	script |shouldRaise can catch more than one exception|
		property parent : UnitTest(me)
		script Raiser
			error number 9876
		end script
		
		shouldRaise({1, 2, 3, 1000, 9876, 10000}, Raiser, ¬
			"The script should have raised exception 9876.")
		shouldRaise({}, Raiser, ¬
			"The script should have raised exception 9876")
		shouldNotRaise({1, 2, 3, 1000, 10000}, Raiser, ¬
			"The script has raised a forbidden exception.")
	end script
	
	script |shouldNotRaise can catch more than one exception|
		property parent : UnitTest(me)
		script Quiet
			-- Must not be empty, because it will inherit the run handler
			-- which will cause a stack overflow
			-- (see http://macscripter.net/viewtopic.php?pid=170090)
			on run
			end run
		end script
		shouldNotRaise({1, 2, 9876}, Quiet, "Should not have raised any exception.")
		shouldNotRaise({}, Quiet, "Should not have raised any exception.")
	end script
	
	script |shouldRaise accepts a handler|
		property parent : UnitTest(me)
		on h()
			error number 502
		end h
		shouldRaise(502, h, "h() should raise error 502")
	end script
	
	script |shouldNotRaise accepts a handler|
		property parent : UnitTest(me)
		on h1()
			error number 502
		end h1
		on h2()
			return 0
		end h2
		shouldNotRaise({501}, h1, "h1() should not raise error 501")
		shouldNotRaise({}, h2, "h2() should not raise at all")
	end script
	
end script


script |test case creation|
	-- Note: don't rename me or my tests will break!
	property parent : TestSet(me)
	
	-- helpers
	
	script |makeTestCase helper|
		property parent : makeTestCase()
		should(true, name)
	end script
	
	-- tests
	
	script |registerTestCase make test case inherit from current fixture|
		property parent : UnitTest(me)
		should(parent is |test case creation|, "test registration failed")
	end script
	
	script |makeTestCase make test case inherit from current fixture|
		property parent : UnitTest(me)
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
		property parent : UnitTest(me)
		should(sharedHandler(), "why?!")
	end script
	
end script

script |pretty print|
	property parent : TestSet(me)
	
	script |pp alias|
		property parent : UnitTest(me)
		assertEqual("alias" & space & ((path to me) as text), pp(path to me))
		assertEqual("alias" & space & ((path to me) as text), ¬
			pp(a reference to (path to me)))
		assertEqual("alias" & space & ((path to me) as text), ¬
			pp(a reference to (a reference to (path to me))))
	end script
	
	script |pp application|
		property parent : UnitTest(me)
		assertEqual("«application com.apple.finder»", pp(application "Finder"))
		assertEqual("«application com.apple.finder»", ¬
			pp(a reference to (application "Finder")))
		assertEqual("«application com.apple.finder»", ¬
			pp(a reference to (a reference to (application "Finder"))))
	end script
	
	script |pp AppleScript|
		property parent : UnitTest(me)
		assertEqual("AppleScript", pp(AppleScript))
		assertEqual("AppleScript", pp(a reference to AppleScript))
	end script
	
	script |pp boolean|
		property parent : UnitTest(me)
		property flag : true
		assertEqual("true", pp(true))
		assertEqual("false", pp(false))
		assertEqual("true", pp(1 = 1))
		assertEqual("false", pp(1 = 2))
		assertEqual("a reference to true", pp(a reference to flag))
	end script
	
	script |pp class|
		property parent : UnitTest(me)
		assertEqual("integer", pp(class of 1))
		assertEqual("a reference to integer", pp(a reference to (class of 1)))
		assertEqual("class", pp(class of class of 1))
		assertEqual("a reference to class", pp(a reference to (class of class of 1)))
	end script
	
	script |pp constant|
		property parent : UnitTest(me)
		set x to missing value
		assertEqual("«" & current application's name & "»", pp(current application))
		assertEqual("missing value", pp(missing value))
		assertEqual("missing value", pp(x))
		assertEqual("null", pp(null))
		assertEqual("hyphens", pp(hyphens))
		assertEqual(pi as text, pp(pi))
		assertEqual(quote, pp(quote))
		assert(my showInvisibles, "Show invisibles should be turned on by default")
		assertEqual(«data utxt00AC» as Unicode text, pp(linefeed)) -- not sign
		assertEqual(«data utxt21A9» as Unicode text, pp(return)) -- hook arrow
		assertEqual(«data utxtFF65» as Unicode text, pp(space)) -- small bullet
		assertEqual(«data utxt21A6» as Unicode text, pp(tab)) -- rightwards arrow from bar
		set my showInvisibles to false
		assertEqual(linefeed, pp(linefeed))
		assertEqual(return, pp(return))
		assertEqual(space, pp(space))
		assertEqual(tab, pp(tab))
		set my showInvisibles to true
	end script
	
	script |pp date|
		property parent : UnitTest(me)
		property d : current date
		property d1 : a reference to d
		property d2 : a reference to d1
		
		set day of d to 19
		set month of d to 12
		set year of d to 2014
		set time of d to 2700
		assertEqual(d as text, pp(d))
		assertEqual("a reference to " & (d as text), pp(d1))
		assertEqual("a reference to " & (d as text), pp(a reference to d))
		assertEqual("a reference to a reference to " & (d as text), pp(d2))
	end script
	
	script |pp handler|
		property parent : UnitTest(me)
		
		on f(x, y)
		end f
		
		assertEqual("«handler»", pp(f))
		assertEqual("a reference to «handler»", pp(a reference to f))
	end script
	
	script |pp list|
		property parent : UnitTest(me)
		assertEqual("{}", pp({}))
		assertEqual("{1, " & (3.4 as text) & ", abc}", pp({1, 3.4, "abc"}))
		assertEqual("{1, {2, {3, 4}}, 5}", pp({1, {2, {3, 4}}, 5}))
		assertEqual("{«script pp list», «record {1, {«application com.apple.finder», {1, 2}}, x}», true}", ¬
			pp({me, {a:1, b:{application "Finder", {1, 2}}, c:"x"}, true}))
	end script
	
	script |pp number|
		property parent : UnitTest(me)
		assertEqual("42", pp(42))
		assertEqual(2.71828 as text, pp(2.71828))
		assertEqual(2.71828 as text, pp(a reference to 2.71828))
		assertEqual(2.71828 as text, pp(a reference to (a reference to 2.71828)))
	end script
	
	script |pp POSIX file|
		property parent : UnitTest(me)
		property f : POSIX file "/Users/myUser/Feb_Meeting_Notes.rtf"
		property f1 : a reference to f
		property f2 : a reference to f1
		
		assertEqual("file" & space & (f as text), pp(f))
		assertEqual("a reference to file" & space & (f as text), pp(f1))
		assertEqual("a reference to file" & space & (f as text), pp(a reference to f))
		assertEqual("a reference to a reference to file" & space & (f as text), ¬
			pp(f2))
	end script
	
	script |pp record|
		property parent : UnitTest(me)
		assertEqual("«record {1, 2, 3}»", pp({a:1, b:2, c:3}))
	end script
	
	script |pp script|
		property parent : UnitTest(me)
		property ppScriptRef : a reference to ppScript
		
		script ppScript
			property id : "com.lifepillar.ppscript"
		end script
		
		assertEqual("«script pp script»", pp(me))
		assertEqual("«script pp script»", pp(a reference to me))
		assertEqual("«script pp script»", pp(a reference to (a reference to me)))
		assertEqual("«script com.lifepillar.ppscript»", pp(ppScript))
		assertEqual("a reference to «script com.lifepillar.ppscript»", pp(ppScriptRef))
	end script
	
	script |pp script called 'missing value'|
		property parent : UnitTest(me)
		property ppScriptRef : a reference to ppScript
		
		script ppScript
			property id : missing value
			property name : "missing value"
		end script
		
		assertEqual("«script missing value»", pp(ppScript))
		assertEqual("a reference to «script missing value»", pp(ppScriptRef))
	end script
	
	script |pp ASUnit|
		property parent : UnitTest(me)
		property scriptRef : a reference to TestASUnit's ASUnit
		
		assertEqual("a reference to «script" & space & ASUnit's id & "»", pp(TestASUnit's ASUnit))
		assertEqual("a reference to a reference to «script" & space & ASUnit's id & "»", pp(scriptRef))
	end script
	
	script |pp text|
		property parent : UnitTest(me)
		assertEqual("àèìòùñ©", pp("àèìòùñ©"))
	end script
	
	script |pp unit types|
		property parent : UnitTest(me)
		assertEqual("10 centimeters", pp(10 as centimeters))
		assertEqual("11 feet", pp(11 as feet))
		assertEqual("12 inches", pp(12 as inches))
		assertEqual("13 kilometers", pp(13 as kilometers))
		assertEqual("14 meters", pp(14 as meters))
		assertEqual("15 miles", pp(15 as miles))
		assertEqual("16 yards", pp(16 as yards))
		assertEqual("17 square feet", pp(17 as square feet))
		assertEqual("18 square kilometers", pp(18 as square kilometers))
		assertEqual("19 square meters", pp(19 as square meters))
		assertEqual("20 square miles", pp(20 as square miles))
		assertEqual("21 square yards", pp(21 as square yards))
		assertEqual("22 cubic centimeters", pp(22 as cubic centimeters))
		assertEqual("23 cubic feet", pp(23 as cubic feet))
		assertEqual("24 cubic inches", pp(24 as cubic inches))
		assertEqual("25 cubic meters", pp(25 as cubic meters))
		assertEqual("26 cubic yards", pp(26 as cubic yards))
		assertEqual("27 gallons", pp(27 as gallons))
		assertEqual("28 liters", pp(28 as liters))
		assertEqual("29 quarts", pp(29 as quarts))
		assertEqual("30 grams", pp(30 as grams))
		assertEqual("31 kilograms", pp(31 as kilograms))
		assertEqual("32 ounces", pp(32 as ounces))
		assertEqual("33 pounds", pp(33 as pounds))
		assertEqual("34 degrees Celsius", pp(34 as degrees Celsius))
		assertEqual("35 degrees Fahrenheit", pp(35 as degrees Fahrenheit))
		assertEqual("36 degrees Kelvin", pp(36 as degrees Kelvin))
		assertEqual("36 degrees Kelvin", pp(a reference to (36 as degrees Kelvin)))
		assertEqual("36 degrees Kelvin", pp(a reference to (a reference to (36 as degrees Kelvin))))
	end script
	
	script |References|
		property parent : UnitTest(me)
		property x : 0
		property y : a reference to x
		property w : a reference to y
		property z : a reference to w
		assertEqual("a reference to 0", pp(y))
		assertEqual("a reference to a reference to 0", pp(w))
		assertEqual("a reference to a reference to a reference to 0", pp(z))
	end script
	
	script |pp object of class self|
		property parent : UnitTest(me)
		
		script Self
			property class : me -- Weird, but legal
		end script
		
		assertEqual("«object of class self»", pp(Self))
	end script
	
	script |pp recursive undefined|
		property parent : UnitTest(me)
		
		script SX
			property class : a reference to SY
		end script
		
		script SY
			property class : SX
		end script
		
		assertEqual("«object of class «undefined reference»»", pp(SX))
		assertEqual("«object of class «object of class «undefined reference»»»", pp(SY))
	end script
	
	property PPRL : a reference to |pp recursive loop|
	
	script |pp recursive loop|
		property parent : UnitTest(me)
		
		script SX
			property class : a reference to PPRL's SY
		end script
		
		script SY
			property class : SX
		end script
		
		set my maxRecursionDepth to 4
		assertEqual("«object of class a reference to «object of class «object of class a reference to ...»»»", pp(SX))
		assertEqual("«object of class «object of class a reference to «object of class «object of class ...»»»»", pp(SY))
	end script
end script -- pretty print

script |Count assertions|
	property parent : TestSet(me)
	property n : missing value
	
	on setUp()
		set n to numberOfAssertions()
	end setUp
	
	script |ok() increments count|
		property parent : UnitTest(me)
		ok(true)
		assertEqual(n + 1, numberOfAssertions())
	end script
	
	script |notOk() increments count|
		property parent : UnitTest(me)
		notOk(false)
		assertEqual(n + 1, numberOfAssertions())
	end script
	
	script |assert() increments count|
		property parent : UnitTest(me)
		assert(true, "")
		assertEqual(n + 1, numberOfAssertions())
	end script
	
	script |refute() increments count|
		property parent : UnitTest(me)
		refute(false, "")
		assertEqual(n + 1, numberOfAssertions())
	end script
	
	script |should() increments count|
		property parent : UnitTest(me)
		should(true, "")
		assertEqual(n + 1, numberOfAssertions())
	end script
	
	script |shouldnt() increments count|
		property parent : UnitTest(me)
		shouldnt(false, "")
		assertEqual(n + 1, numberOfAssertions())
	end script
	
	script |shouldRaise() increments count|
		property parent : UnitTest(me)
		script Err
			error number 1984
		end script
		shouldRaise(1984, Err, "")
		assertEqual(n + 1, numberOfAssertions())
	end script
	
	script |shouldNotRaise() increments count|
		property parent : UnitTest(me)
		script Err
			error number 1984
		end script
		shouldNotRaise(1978, Err, "")
		assertEqual(n + 1, numberOfAssertions())
	end script
	
	script |assertEqual() increments count|
		property parent : UnitTest(me)
		assertEqual(0, 0)
		assertEqual(n + 1, numberOfAssertions())
	end script
	
	script |shouldEqual() increments count|
		property parent : UnitTest(me)
		shouldEqual(0, 0)
		assertEqual(n + 1, numberOfAssertions())
	end script
	
	script |assertNotEqual() increments count|
		property parent : UnitTest(me)
		assertNotEqual(0, 1)
		assertEqual(n + 1, numberOfAssertions())
	end script
	
	script |refuteEqual() increments count|
		property parent : UnitTest(me)
		refuteEqual(0, 1)
		assertEqual(n + 1, numberOfAssertions())
	end script
	
	script |shouldNotEqual() increments count|
		property parent : UnitTest(me)
		shouldNotEqual(0, 1)
		assertEqual(n + 1, numberOfAssertions())
	end script
	
	script |assertEqualAbsError() increments count|
		property parent : UnitTest(me)
		assertEqualAbsError(0, 1.0E-3, 0.005)
		assertEqual(n + 1, numberOfAssertions())
	end script
	
	script |assertEqualRelError() increments count|
		property parent : UnitTest(me)
		assertEqualRelError(100, 105, 0.1)
		assertEqual(n + 1, numberOfAssertions())
	end script
	
	script |assertNil() increments count|
		property parent : UnitTest(me)
		assertNil(missing value)
		assertEqual(n + 1, numberOfAssertions())
	end script
	
	script |refuteNil() increments count|
		property parent : UnitTest(me)
		refuteNil(0)
		assertEqual(n + 1, numberOfAssertions())
	end script
	
	script |refuteInstanceOf() increments count|
		property parent : UnitTest(me)
		refuteInstanceOf(text, {})
		assertEqual(n + 1, numberOfAssertions())
	end script
	
	script |assertKindOf() increments count|
		property parent : UnitTest(me)
		assertKindOf(script, me)
		assertEqual(n + 1, numberOfAssertions())
	end script
	
	script |refuteKindOf() increments count|
		property parent : UnitTest(me)
		refuteKindOf(list, me)
		assertEqual(n + 1, numberOfAssertions())
	end script
	
	script |assertInheritsFrom() increments count|
		property Father : UnitTest(me)
		property parent : Father
		assertInheritsFrom(Father, me)
		assertEqual(n + 1, numberOfAssertions())
	end script
	
	script |refuteInheritsFrom() increments count|
		property Father : UnitTest(me)
		property parent : Father
		refuteInheritsFrom(me, Father)
		assertEqual(n + 1, numberOfAssertions())
	end script
	
	script |assertReference() increments count|
		property parent : UnitTest(me)
		assertReference(a reference to TopLevel)
		assertEqual(n + 1, numberOfAssertions())
	end script
	
	script |assertNotReference() increments count|
		property parent : UnitTest(me)
		assertNotReference(0)
		assertEqual(n + 1, numberOfAssertions())
	end script
	
	script |shouldBeReference() increments count|
		property parent : UnitTest(me)
		shouldBeReference(a reference to TopLevel)
		assertEqual(n + 1, numberOfAssertions())
	end script
	
	script |shouldNotBeReference() increments count|
		property parent : UnitTest(me)
		shouldNotBeReference(a reference to me)
		assertEqual(n + 1, numberOfAssertions())
	end script
	
	script |failIf() increments count|
		property parent : UnitTest(me)
		failIf(my ok, {false}, "")
		assertEqual(n + 1, numberOfAssertions())
	end script
	
	script |failIf() does not increment count when it fails|
		property parent : UnitTest(me)
		try -- ignore failure
			failIf(my ok, {true}, "")
		end try
		assertEqual(n, numberOfAssertions())
	end script
	
	script |Count of nested test set|
		property parent : TestSet(me)
		
		script |increments assertion|
			property parent : UnitTest(me)
			assertEqual(n, numberOfAssertions())
			assertEqual(n + 1, numberOfAssertions())
		end script
	end script
	
end script -- Count assertions

script TestSetCocoaRef
	property parent : TestSet(me)
	property name : "Objective-C references"
	
	script TestCocoaRef
		property parent : UnitTest(me)
		property name : "assertCocoaReference() fails with AppleScript objects"
		
		failIf(my assertCocoaReference, {""}, "Should fail with string")
		refuteCocoaReference("")
		failIf(my assertCocoaReference, {text}, "Should fail with class object")
		refuteCocoaReference(text)
	end script
	
	script TestCocoaRefWithReferences
		property parent : UnitTest(me)
		property name : "assertCocoaReference() fails with AppleScript references"
		property a : a reference to my name
		property b : a reference to a
		property c : a reference to b
		property d : a reference to e
		
		failIf(my assertCocoaReference, {a}, "a")
		failIf(my assertCocoaReference, {b}, "b")
		failIf(my assertCocoaReference, {c}, "c")
		failIf(my assertCocoaReference, {d}, "d")
		refuteCocoaReference(a)
		refuteCocoaReference(b)
		refuteCocoaReference(c)
		refuteCocoaReference(d)
	end script
	
	script TestCocoaRefCritical
		property parent : UnitTest(me)
		property name : "assertCocoaReference() fails with cyclic AppleScript references"
		property e : a reference to f
		property f : a reference to (class of e)
		
		if current application's name is not "osascript" then
			skip("This test causes Script Editor 2.7 (and possibly other AppleScript editors) to crash")
		else
			failIf(my assertCocoaReference, {e}, "e")
			failIf(my assertCocoaReference, {f}, "f")
			refuteCocoaReference(e)
			refuteCocoaReference(f)
		end if
	end script
end script -- TestSetCocoaRef
