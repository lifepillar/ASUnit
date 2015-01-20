(*!
 @header ASUnit
 	An AppleScript testing framework.
 @abstract License: GNU GPL, see COPYING for details.
 @author Nir Soffer, Lifepillar
 @copyright 2013Ð2014 Lifepillar, 2006 Nir Soffer
 @version 1.2.3
 @charset macintosh
*)

(*! @abstract <em>[text]</em> ASUnit's name. *)
property name : "ASUnit"
(*! @abstract <em>[text]</em> ASUnit's version. *)
property version : "1.2.3"
(*! @abstract <em>[text]</em> ASUnit's id. *)
property id : "com.lifepillar.ASUnit"
(*! @abstract Error number signalling a failed test. *)
property TEST_FAILED : 1000
(*! @abstract Error number signalling a skipped test. *)
property TEST_SKIPPED : 1001
(*! @abstract Error number used inside @link failIf @/link. *)
property TEST_SUCCEEDED_BUT_SHOULD_HAVE_FAILED : 1002
(*! @abstract A property that refers to the top-level script. *)
property TOP_LEVEL : me

(*!
 @abstract
 	Base class for observers.
 @discussion
 	Observers are objects that may get notified by visitors.
 	Concrete observers are supposed to inherit from this script.
*)
script Observer
	property parent : AppleScript
	
	(*! @abstract Sets the object observed by this  observer. *)
	on setNotifier(aNotifier)
	end setNotifier
	
end script -- Observer

(*!
	 @abstract
	 	Base class for visitors.
	 @discussion
	 	This script defines the interface for a Visitor object.
	 	Subclasses are supposed to override some handlers.
	 	To operate on a suite, you call the suite <tt>accept()</tt> with a visitor.
		ASUnit defines only one visitor, <tt>TestResult</tt>, which runs all the tests in a suite.
		You may create other visitors to do filtered testing, custom reporting and like.
		Your custom visitor should inherit from one of the framework visitors or from <tt>Visitor</tt>.
	*)
script Visitor
	property parent : AppleScript
	
	(*! @abstract See <tt>visitTestSuite</tt> in @link TestResult @/link. *)
	on visitTestSuite(aTestSuite)
	end visitTestSuite
	
	(*! @abstract See <tt>visitTestCase</tt> in @link TestResult @/link. *)
	on visitTestCase(TestCase)
	end visitTestCase
	
end script -- Visitor

(*! @abstract Builds and returns a TestResult object. *)
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
		property assertions : 0
		
		(*!
			@abstract
				Makes the given object an observer of TestResult.
			@discussion
				Observers of TestResult are sent notifications whenever
				certain events occur, like starting a test, completing a test, etcÉ
				An observer should be an object that inherits from @link Observer @/link,
				or at least conforms to its interface.
			@param
				anObject <em>[script]</em> The observer.
		*)
		on addObserver(anObject)
			anObject's setNotifier(me)
			set the end of my observers to anObject
		end addObserver
		
		(*!
			 @abstract
			 	Runs the given test case or test suite.
			 @param
			 	aTest <em>[script]</em> May be a test case or a test suite.
		*)
		on runTest(aTest)
			set assertions to 0
			try
				startTest()
				aTest's accept(me)
				stopTest()
			on error msg number n
				stopTest()
				error msg number n
			end try
		end runTest
		
		(*! @abstract Sets the start time of the test and notifies the observers. *)
		on startTest()
			set my startDate to current date
			notify({name:"start"})
		end startTest
		
		(*! @abstract Sets the end time of the test and notifies the observers. *)
		on stopTest()
			set my stopDate to current date
			notify({name:"stop"})
		end stopTest
		
		(*!
			@abstract
				Notifies the observers that the given test has started.
			@param
			 	aTestCase <em>[script]</em> A test case.
		*)
		on startTestCase(aTestCase)
			notify({name:"start test case", test:aTestCase})
		end startTestCase
		
		(*!
			 @abstract
			 	Runs a test case and collects results.
			 @param
			 	aTestCase <em>[script]</em> A test case.
		*)
		on visitTestCase(aTestCase)
			startTestCase(aTestCase)
			try
				aTestCase's runCase()
				addSuccess(aTestCase)
				set my assertions to (my assertions) + (aTestCase's numberOfAssertions())
			on error message number errorNumber
				set my assertions to (my assertions) + (aTestCase's numberOfAssertions())
				if errorNumber is TEST_SKIPPED then
					addSkip(aTestCase, message)
				else if errorNumber is TEST_FAILED then
					addFailure(aTestCase, message)
				else
					addError(aTestCase, message & " (" & errorNumber & ")")
				end if
			end try
		end visitTestCase
		
		(*!
			@abstract
				Registers the fact that the given test has succeeded and notifies the observers.
			@param
			 	aTestCase <em>[script]</em> A test case.
		*)
		on addSuccess(aTestCase)
			set end of my passed to aTestCase
			notify({name:"success", test:aTestCase})
		end addSuccess
		
		(*!
			@abstract
				Registers the fact that the given test was skipped and notifies the observers.
			@param
			 	aTestCase <em>[script]</em> A test case.
			@param
				message <em>[text]</em> The message to be shown to the user.
	*)
		on addSkip(aTestCase, message)
			set end of my skips to {test:aTestCase, message:message}
			notify({name:"skip", test:aTestCase})
		end addSkip
		
		(*!
			@abstract
				Registers the fact that the given test has failed and notifies the observers.
			@param
			 	aTestCase <em>[script]</em> A test case.
			@param
				message <em>[text]</em> The message to be shown to the user.
		*)
		on addFailure(aTestCase, message)
			set end of my failures to {test:aTestCase, message:message}
			notify({name:"fail", test:aTestCase})
		end addFailure
		
		(*!
			@abstract
				Registers the fact that the given test raised an error and notifies the observers.
			@param
			 	aTestCase <em>[script]</em> A test case.
			@param
				message <em>[text]</em> The message to be shown to the user.
		*)
		on addError(aTestCase, message)
			set end of my errors to {test:aTestCase, message:message}
			notify({name:"error", test:aTestCase})
		end addError
		
		(*!
			@abstract
				Sends the given event to all the observers.
			@param
				anEvent <em>[record]</em> the event that must be sent to the observers.
				An event contains two fields: the <tt>name</tt> of the event
				and the <tt>test</tt> object.
		*)
		on notify(anEvent)
			repeat with obs in (a reference to my observers)
				obs's update(anEvent)
			end repeat
		end notify
		
		(*!
			@abstract
				Returns true if and only if the test suite completes successfully, that is,
				without errors or failures.
		*)
		on hasPassed()
			return (my failures's length) + (my errors's length) = 0
		end hasPassed
		
		(*! @abstract Returns the number of tests run. *)
		on runCount()
			return (my passed's length) + (my skips's length) + (my failures's length) + (my errors's length)
		end runCount
		
		(*! @abstract Returns the number of successful tests. *)
		on passCount()
			return count of my passed
		end passCount
		
		(*! @abstract Returns the total number of successful assertions. *)
		on assertionCount()
			return assertions
		end assertionCount
		
		(*! @abstract Returns the number of skipped test. *)
		on skipCount()
			return count of my skips
		end skipCount
		
		(*! @abstract Returns the number of tests that generated an error. *)
		on errorCount()
			return count of my errors
		end errorCount
		
		(*! @abstract Returns the number of failed tests. *)
		on failureCount()
			return count of my failures
		end failureCount
		
		(*! @abstract Returns the time spent to run the test suite, in seconds. *)
		on runSeconds()
			return (my stopDate) - (my startDate)
		end runSeconds
		
	end script -- TestResult
	
	return TestResult
	
end makeTestResult

(*!
	 @abstract
	 	Factory handler to generate a test script.
	 @discussion
	 	This handler is used to create a script that inherits
	 	from <code>theParent</code> and implements testing assertions.
	 @param
	 	theParent <em>[script]</em> The script to inherit from.
	 @return
	 	A script inheriting from the given script and implementing assertions.
	*)
on makeAssertions(theParent)
	
	(*! @abstract The script defining all the test assertions. *)
	script TestAssertions
		property parent : theParent
		
		(*!
			@abstract
				Determines whether invisible characters should be made visible.
			@discussion
				When this property is set to true (which is the default), invisible
				characters (spaces, tabulations, linfeeds, and returns) are printed
				as visible characters.
				This is especially useful when a test like @link assertEqual() @/link fails
				because the expected value and the actual value differ, say, just
				because the actual value has a trailing new line that the
				expected value does not have.
		*)
		property showInvisibles : true
		
		on test_failed_error_number()
			return TEST_FAILED
		end test_failed_error_number
		
		on test_skipped_error_number()
			return TEST_SKIPPED
		end test_skipped_error_number
		
		(*!
			@abstract
				Helper handler that returns a textual representation of an inheritance chain.
		*)
		on formatInheritanceChain(chain)
			local n
			set n to the length of the chain
			if n = 0 then return "(The inheritance chain is empty)"
			if n > 0 then
				local s
				set s to "Inheritance chain: " & pp(item 1 of chain)
				repeat with i from 2 to n
					set s to s & linefeed & "                   -> " & pp(item i of chain)
				end repeat
				return s
			end if
		end formatInheritanceChain
		
		(*!
			@abstract
				Raises a TEST_SKIPPED error.
			@param
				why <em>[text]</em> A message.
			@throws
				A @link TEST_SKIPPED @/link error.
		*)
		on skip(why)
			error why number TEST_SKIPPED
		end skip
		
		(*!
			@abstract
				Raises a TEST_FAILED error.
			@param
				why <em>[text]</em> A message.
			@throws
				A @link TEST_FAILED @/link error.
		*)
		on fail(why)
			error why number TEST_FAILED
		end fail
		
		(*!
			@abstract
				Succeeds when its argument is true.
			@param
				expr <em>[boolean]</em> An expression that evaluates to true or false.
			@throws
				A @link TEST_FAILED @/link error if the assertion fails.
		*)
		on ok(expr)
			if not expr then fail("The given expression did not evaluate to true.")
			countAssertion()
		end ok
		
		(*!
			@abstract
				Succeeds when its argument is false.
			@param
				expr <em>[boolean]</em> An expression that evaluates to true or false.
			@throws
				A @link TEST_FAILED @/link error if the assertion fails.
		*)
		on notOk(expr)
			if expr then fail("The given expression did not evaluate to false.")
			countAssertion()
		end notOk
		
		(*!
			@abstract
				Succeeds when the given expression is true.
			@param
				expr <em>[boolean]</em> An expression that evaluates to true or false.
			@param
				message <em>[text][</em> A message that is printed when the test fails.
			@throws
				A @link TEST_FAILED @/link error if the assertion fails.
		*)
		on assert(expr, message)
			if not expr then fail(message)
			countAssertion()
		end assert
		
		(*! @abstract A synonym for @link assert @/link. *)
		on should(expr, message)
			assert(expr, message)
		end should
		
		(*!
			@abstract
				Succeeds when the given expression is false.
			@param
				expr <em>[boolean]</em> An expression that evaluates to true or false.
			@param
				message <em>[text][</em> A message that is printed when the test fails.
			@throws
				A @link TEST_FAILED @/link error if the assertion fails.
		*)
		on refute(expr, message)
			if expr then fail(message)
			countAssertion()
		end refute
		
		(*! @abstract A synonym for @link refute @/link. *)
		on shouldnt(expr, message)
			refute(expr, message)
		end shouldnt
		
		(*!
			@abstract
				Succeeds when the two given expressions have the same value.
			@param
				expected <em>[anything]</em> The expected value.
			@param
				value <em>[anything]</em> Some other value.
			@throws
				A @link TEST_FAILED @/link error if the assertion fails.
		*)
		on assertEqual(expected, value)
			local msg, got, wanted, errMsg
			considering case, diacriticals, hyphens, punctuation and white space
				if (value is not expected) then
					fail("Expected: " & pp(expected) & linefeed & "  Actual: " & pp(value))
				end if
			end considering
			countAssertion()
		end assertEqual
		
		(*! @abstract A synonym for @link assertEqual @/link. *)
		on shouldEqual(expected, value)
			assertEqual(expected, value)
		end shouldEqual
		
		(*!
			@abstract
				Succeeds when the two given expressions are not equal.
			@param
				unexpected <em>[anything]</em> The unexpected value.
			@param
				value <em>[anything]</em> Some other value.
			@throws
				A @link TEST_FAILED @/link error if the assertion fails.
		*)
		on assertNotEqual(unexpected, value)
			local msg, unwanted, errMsg
			considering case, diacriticals, hyphens, punctuation and white space
				if value is equal to unexpected then
					fail("Expected a value different from " & pp(unexpected) & ".")
				end if
			end considering
			countAssertion()
		end assertNotEqual
		
		(*! @abstract A synonym for @link assertNotEqual @/link. *)
		on refuteEqual(unexpected, value)
			assertNotEqual(unexpected, value)
		end refuteEqual
		
		(*! @abstract A synonym for @link assertNotEqual @/link. *)
		on shouldNotEqual(unexpected, value)
			assertNotEqual(unexpected, value)
		end shouldNotEqual
		
		(*!
			@abstract
				Fails unless <tt>e1</tt> and <tt>e2</tt> are within <tt>delta</tt> from each other.
			@discussion
				This assertion succeeds if and only if |e1-e2| ² delta.
			@param
				e1 <em>[number]</em> A number.
			@param
				e2 <em>[number]</em> A number.
			@param
				delta <em>[number]</em> The absolute error.
			@throws
				A @link TEST_FAILED @/link error if the assertion fails.
		*)
		on assertEqualAbsError(e1, e2, delta)
			if delta < 0.0 then fail("The absolute error cannot be negative.")
			local n
			set n to e1 - e2
			if n < 0.0 then set n to -n
			if n > delta then fail("The arguments differ by " & asText(n) & " > " & asText(delta))
			countAssertion()
		end assertEqualAbsError
		
		(*!
			@abstract
				Fails unless <tt>e1</tt> and <tt>e2</tt> have a relative error less than <tt>eps</tt>.
			@discussion
				This assertion succeeds if and only if |e1-e2| ² min(|e1|,|e2|) * eps.
			@param
				e1 <em>[number]</em> A number.
			@param
				e2 <em>[number]</em> A number.
			@param
				eps <em>[number]</em> The relative error.
			@throws
				A @link TEST_FAILED @/link error if the assertion fails.
		*)
		on assertEqualRelError(e1, e2, eps)
			if eps < 0.0 then fail("The relative error cannot be negative.")
			local min
			local n
			set n to e1 - e2
			if n < 0.0 then set n to -n
			if e1 < 0.0 then set e1 to -e1
			if e2 < 0.0 then set e2 to -e2
			if e1 < e2 then
				set min to e1
			else
				set min to e2
			end if
			if n > min * eps then Â
				fail("The relative error is " & asText(n / min) & " > " & asText(eps))
			countAssertion()
		end assertEqualRelError
		
		(*! @abstract A shortcut for @link assertEqual @/link(missing value, expr). *)
		on assertNil(expr)
			assertEqual(missing value, expr)
		end assertNil
		
		(*! @abstract A shortcut for @link refuteEqual @/link(missing value, expr). *)
		on refuteNil(expr)
			refuteEqual(missing value, expr)
		end refuteNil
		
		(*!
			@abstract
				Tests whether the given expression belongs to the given class.
			@param
				klass <em>[class]</em> A class name.
			@param
				expr <em>[anything]</em> A value.
			@throws
				A @link TEST_FAILED @/link error if the assertion fails.
		*)
		on assertInstanceOf(klass, expr)
			local k
			try
				set k to class of expr
			on error
				fail("Can't get class of" & space & pp(expr) & ".")
			end try
			if k is not klass then
				fail("Expected class: " & pp(klass) & linefeed & Â
					"  Actual class: " & pp(k))
			end if
			countAssertion()
		end assertInstanceOf
		
		(*!
			@abstract
				Succeeds when the given expression is not of the given class.
			@param
				klass <em>[class]</em> A class name.
			@param
				expr <em>[anything]</em> A value.
			@throws
				A @link TEST_FAILED @/link error if the assertion fails.
		*)
		on refuteInstanceOf(klass, expr)
			local k
			try
				set k to class of expr
			on error
				countAssertion()
				return
			end try
			if k is klass then Â
				fail("Expected class of " & pp(expr) & linefeed & "to be different from " & pp(klass) & ".")
			countAssertion()
		end refuteInstanceOf
		
		(*!
			@abstract
				Tests whether the given object or any of its ancestors belongs to the given class.
			@discussion
				This is mainly useful for user-defined scripts and user-defined
				inheritance hierarchies. For built-in types, it is almost equivalent
				to @link assertInstanceOf @/link. The main difference is that it can be
				used to test whether an expression is a <tt>number</tt>,
				but it does not matter if it is an <tt>integer</tt> or <tt>real</tt>
				(you cannot do that with @link assertInstanceOf @/link).
			@param
				klass <em>[class]</em> A class name.
			@param
				expr <em>[anything]</em> A value.
			@throws
				A @link TEST_FAILED @/link error if the assertion fails.
		*)
		on assertKindOf(klass, expr)
			local curr, k, inheritanceChain
			set curr to expr
			set inheritanceChain to {}
			repeat
				try
					set k to class of curr
				on error
					set the end of inheritanceChain to curr
					exit repeat
				end try
				if k is klass then
					countAssertion()
					return
				end if
				if klass is number and k is in {integer, real} then
					countAssertion()
					return
				end if
				set the end of the inheritanceChain to curr
				try
					set curr to curr's parent
					if curr is in inheritanceChain then -- cycle
						set the end of inheritanceChain to curr
						exit repeat
					end if
				on error errMsg number errNum
					if errNum is -1728 then exit repeat -- Can't get parent (end of inheritance chain)
					error "Unexpected error: " & errMsg number errNum
				end try
			end repeat
			fail(pp(expr) & space & "is not a kind of" & space & pp(klass) & "." & linefeed & Â
				formatInheritanceChain(inheritanceChain))
		end assertKindOf
		
		(*!
			@abstract
				Verifies that neither the given object nor any of its ancestors belong to the given class.
			@discussion
				See @link assertKindOf @/link.
			@param
				klass <em>[class]</em> A class name.
			@param
				expr <em>[anything]</em> A value.
			@throws
				A @link TEST_FAILED @/link error if the assertion fails.
		*)
		on refuteKindOf(klass, expr)
			local curr, k, inheritanceChain
			set curr to expr
			set inheritanceChain to {}
			repeat
				try
					set k to class of curr
				on error
					countAssertion()
					return
				end try
				set the end of the inheritanceChain to curr
				if k is klass then exit repeat
				if klass is number and k is in {integer, real} then exit repeat
				try
					set curr to curr's parent
					if curr is in inheritanceChain then -- cycle
						countAssertion()
						return
					end if
				on error errMsg number errNum
					if errNum is -1728 then -- Can't get parent (end of inheritance chain)
						countAssertion()
						return
					end if
					error "Unexpected error: " & errMsg number errNum
				end try
			end repeat
			fail(pp(expr) & space & "is a kind of" & space & pp(klass) & "." & linefeed & Â
				formatInheritanceChain(inheritanceChain))
		end refuteKindOf
		
		(*!
			@abstract
				Tests whether an object inherits from another object.
			@discussion
				This test walks up the inheritance chain of <tt>descendantObject</tt>
				until it finds <tt>obj</tt>, reaches the end of the inheritance
				chain, or detects a cycle in the inheritance chain.
			@param
				ancestor <em>[anything]</em> A value.
			@param
				descendant <em>[anything]</em> A value.
			@throws
				A @link TEST_FAILED @/link error if the assertion fails.
		*)
		on assertInheritsFrom(ancestor, descendant)
			local currObj, inheritanceChain
			set currObj to descendant
			set inheritanceChain to {}
			repeat
				set the end of the inheritanceChain to currObj
				try
					set currObj to currObj's parent
					if currObj is equal to ancestor then
						countAssertion()
						return
					end if
					if currObj is in inheritanceChain then -- cycle
						set the end of inheritanceChain to currObj
						exit repeat
					end if
				on error errMsg number errNum
					if errNum is -1728 then exit repeat -- Can't get parent (end of inheritance chain)
					error "Unexpected error: " & errMsg number errNum
				end try
			end repeat
			fail(pp(descendant) & space & "does not inherit from" & space & pp(ancestor) & "." & linefeed & Â
				formatInheritanceChain(inheritanceChain))
		end assertInheritsFrom
		
		(*!
			@abstract
				Succeeds when <tt>anotherObj</tt> does not inherit
				(directly on indirectly) from <tt>obj</tt>.
			@param
				obj <em>[anything]</em> A value.
			@param
				anotherObj <em>[anything]</em> A value.
			@throws
				A @link TEST_FAILED @/link error if the assertion fails.
		*)
		on refuteInheritsFrom(obj, anotherObj)
			local currObj, inheritanceChain
			set currObj to anotherObj
			set inheritanceChain to {} -- To detect cycles
			repeat
				set the end of inheritanceChain to currObj
				try
					set currObj to currObj's parent
					if currObj is equal to obj then
						set the end of inheritanceChain to currObj
						exit repeat
					end if
					if currObj is in inheritanceChain then -- cycle
						countAssertion()
						return
					end if
				on error errMsg number errNum
					if errNum is -1728 then -- Can't get parent (end of inheritance chain)
						countAssertion()
						return
					end if
					error "Unexpected error: " & errMsg number errNum
				end try
			end repeat
			fail(pp(anotherObj) & space & "inherits from" & space & pp(obj) & "." & linefeed & Â
				formatInheritanceChain(inheritanceChain))
		end refuteInheritsFrom
		
		(*!
			@abstract
				Tests whether a variable is a reference.
			@param
				anObject <em>[anything]</em> An expression.
			@throws
				A @link TEST_FAILED @/link error if the assertion fails.
		*)
		on assertReference(anObject)
			try
				anObject as reference -- Try to coerce to reference class
			on error
				fail(pp(anObject) & space & "is not a reference.")
			end try
			countAssertion()
		end assertReference
		
		(*! @abstract A synonym for @link assertReference @/link. *)
		on shouldBeReference(anObject)
			assertReference(anObject)
		end shouldBeReference
		
		(*!
			@abstract
				Fails when a variable is a reference.
			@param
				anObject <em>[anything]</em> An expression.
			@throws
				A @link TEST_FAILED @/link error if the assertion fails.
		*)
		on assertNotReference(anObject)
			try
				anObject as reference -- Try to coerce to reference class
			on error
				countAssertion()
				return
			end try
			fail("Got a reference to " & pp(anObject) & ".")
		end assertNotReference
		
		(*! @abstract A synonym for @link assertNotReference() @/link. *)
		on shouldNotBeReference(anObject)
			assertNotReference(anObject)
		end shouldNotBeReference
		
		(*!
			@abstract
				Fails when the given argument is not a reference to a Cocoa object.
				Succeeds otherwise.
			@discussion
				TODO
			@param
				anObject <em>[anything]</em> An expression.
			@throws
				A @link TEST_FAILED @/link error if the assertion fails.
			@seealso
				http://macscripter.net/viewtopic.php?pid=177998
		*)
		on assertObjCReference(anObject)
			try
				(class of x) as reference
				(contents of class of x is class of x)
			on error
				fail(pp(anObject) & space & "is not a reference to a Cocoa object.")
			end try
			countAssertion()
		end assertObjCReference
		
		(*! @abstract A synonym for @link assertObjCReference @/link. *)
		on shouldBeObjCReference(anObject)
			assertObjCReference(anObject)
		end shouldBeObjCReference
		
		(*!
			@abstract
				Fails when the given assertion succeeds.
			@discussion
				This is mostly a convenience for testing ASUnit itself, since for every
				positive assertion (<tt>assertÉ</tt>, <tt>shouldÉ</tt>), ASUnit already
				defines a corresponding negative assertion (<tt>refuteÉ</tt>, <tt>shouldntÉ</tt>).
			@param
				assertion <em>[handler]</em> An assertion handler.
			@param
				args <em>[list]</em> A list of arguments to be passed to the handler.
				The length of the list must match the number of arguments of the assertion.
			@param
				msg <em>[text]</em> A message to print when this test fails.
			@throws
				A @link TEST_FAILED @/link error when <tt>assertion(args)</tt> succeeds.
		*)
		on failIf(assertion, args, msg)
			local n
			script AssertionFunctor
				property call : assertion
			end script
			if args's class is not list then set args to {args}
			set n to length of args
			try
				if n = 1 then
					AssertionFunctor's call(item 1 of args)
				else if n = 2 then
					AssertionFunctor's call(item 1 of args, item 2 of args)
				else if n = 3 then
					AssertionFunctor's call(item 1 of args, item 2 of args, item 3 of args)
				else
					error "Wrong number of arguments to assertion handler" number -1721
				end if
				error number TEST_SUCCEEDED_BUT_SHOULD_HAVE_FAILED
			on error errMsg number errNum
				if errNum is TEST_FAILED then
					countAssertion()
					return
				end if
				if errNum is TEST_SUCCEEDED_BUT_SHOULD_HAVE_FAILED then
					set my nAssertions to (my nAssertions) - 1
					fail(msg)
				end if
				if errNum is TEST_SKIPPED then skip(msg)
				error errMsg number errNum
			end try
		end failIf
		
		(*!
			@abstract
				Returns a textual representation of an object.
			@param
				anObject <em>[anything]</em> An expression.
		*)
		on pp(anObject)
			local res, klass, refTo
			try -- Is it a reference?
				anObject as reference
				set refTo to "A reference to" & space
			on error
				set refTo to ""
			end try
			try
				set klass to class of anObject
			on error -- can't get class
				try
					set res to refTo & "Ç" & anObject's name & "È"
					return res
				end try
				try
					set res to refTo & "Ç" & anObject's id & "'È"
					return res
				end try
				try
					set res to refTo & "Ç" & anObject's description & "È"
					return res
				end try
				try
					set res to refTo & asText(anObject)
					return res
				on error -- Give up
					return refTo & "ÇobjectÈ"
				end try
			end try
			
			if klass is in {list, RGB color} then
				local s, n
				set n to anObject's length
				if n = 0 then return refTo & "{}"
				set s to "{"
				repeat with i from 1 to n - 1
					set s to s & pp(item i of anObject) & "," & space
				end repeat
				return refTo & s & pp(item n of anObject) & "}"
			else if klass is record then
				return refTo & "Çrecord " & pp(anObject as list) & "È"
			else if klass is script then
				if anObject is AppleScript then return refTo & "AppleScript"
				try
					set res to space & anObject's name
				on error
					try
						set res to space & anObject's id
					on error
						set res to ""
					end try
				end try
				return refTo & "Çscript" & res & "È"
			else if klass is in {application, null} then
				try
					set res to space & anObject's name
				on error
					set res to ""
				end try
				return refTo & "Çapplication" & res & "È"
			else
				try
					set res to asText(anObject)
				on error
					try
						set klass to asText(klass)
						return refTo & "Çobject of class" & space & klass & "È"
					on error
						return refTo & "ÇobjectÈ"
					end try
				end try
				if klass is text then
					if my showInvisibles then -- show invisible characters
						local tid, x
						set tid to AppleScript's text item delimiters
						set AppleScript's text item delimiters to space
						set x to text items of res
						set AppleScript's text item delimiters to Çdata utxtFF65È as Unicode text -- small bullet
						set res to x as text
						set AppleScript's text item delimiters to tab
						set x to text items of res
						set AppleScript's text item delimiters to Çdata utxt21A6È as Unicode text -- rightwards arrow from bar
						set res to x as text
						set AppleScript's text item delimiters to linefeed
						set x to text items of res
						set AppleScript's text item delimiters to Çdata utxt00ACÈ as Unicode text -- not sign
						set res to x as text
						set AppleScript's text item delimiters to return
						set x to text items of res
						set AppleScript's text item delimiters to Çdata utxt21A9È as Unicode text -- hook arrow
						set res to x as text
						set AppleScript's text item delimiters to tid
					end if
					return refTo & res
				end if
				if klass is in {alias, boolean, class, constant, Â
					date, file, integer, POSIX file, real} then
					return refTo & res
				else if klass is in {centimeters, feet, inches, kilometers, meters, miles, yards, square feet, square kilometers, square meters, square miles, square yards, cubic centimeters, cubic feet, cubic inches, cubic meters, cubic yards, gallons, liters, quarts, grams, kilograms, ounces, pounds, degrees Celsius, degrees Fahrenheit, degrees Kelvin} then
					return res & space & (klass as text) -- These are always references
				else
					return refTo & res
				end if
			end if
		end pp
		
		(*! @abstract Utility handler to coerce an object to <code>text</code>. *)
		on asText(s)
			local ss, tid
			set {tid, AppleScript's text item delimiters} to {AppleScript's text item delimiters, ""}
			try
				set ss to s as text
				set AppleScript's text item delimiters to tid
				return ss
			on error errMsg number errNum
				set AppleScript's text item delimiters to tid
				error errMsg number errNum
			end try
		end asText
		
		
		(*! @abstract A synonym for @link shouldNotRaise@/link(). Deprecated. *)
		on shouldntRaise(expectedErrorNumber, object, message)
			shouldNotRaise(expectedErrorNumber, object, message)
		end shouldntRaise
		
		(*!
			@abstract
				Fails if <tt>expectedErrorNumber</tt> is raised by executing <tt>object</tt>.
			@discussion
				Fails if a certain error is raised.
			@param
				expectedErrorNumber <em>[integer]</em> or <em>[list]</em>
				An exception number or a list of exception numbers. To make this assertion
				succeed only when no exception is raised, pass an empty list.
			@param
				object <em>[script]</em> or <em>[handler]</em> A script or a handler without parameters.
			@param
				message <em>[text]</em> A message that is printed when this assertion fails.
			@throws
				A @link TEST_FAILED @/link error if the assertion fails.
		*)
		on shouldNotRaise(expectedErrorNumber, object, message)
			if expectedErrorNumber's class is integer then
				set expectedErrorNumber to {expectedErrorNumber}
			end if
			if the class of the object is handler then
				script
					property f : object
					f()
				end script
				set aScript to the result
			else if the class of the object is script then
				set aScript to the object
			else
				error "shouldNotRaise()'s second argument must be a script or a handler with no parametrs."
			end if
			try
				run aScript
			on error errMsg number errNum
				if (the length of expectedErrorNumber = 0) or (expectedErrorNumber contains errNum) then
					fail(message & linefeed & errMsg & linefeed & "Exception raised: " & errNum)
				end if
			end try
			countAssertion()
		end shouldNotRaise
		
		(*!
			@abstract
				Fails unless <tt>expectedErrorNumber</tt> is raised by executing <tt>object</tt>.
			@discussion
				Fails if an unexpected error was raised or no error was raised.
			@param
				expectedErrorNumber <em>[integer]</em> or <em>[list]</em>
				An exception number or a list of exception numbers. To make this assertion
				succeed no matter what exception is raised, pass an empty list.
			@param
				object <em>[script]</em> or <em>[handler]</em> A script or a handler without parameters.
			@param
				message <em>[text]</em> A message that is printed when the assertion fails.
			@throws
				A @link TEST_FAILED @/link error if the assertion fails.
		*)
		on shouldRaise(expectedErrorNumber, object, message)
			local aScript
			if expectedErrorNumber's class is integer then
				set expectedErrorNumber to {expectedErrorNumber}
			end if
			if the class of the object is handler then
				script
					property f : object
					f()
				end script
				set aScript to the result
			else if the class of the object is script then
				set aScript to the object
			else
				error "shouldRaise()'s second argument must be a script or a handler with no parametrs."
			end if
			try
				run aScript
			on error errMsg number errNum
				if (length of expectedErrorNumber > 0) and (expectedErrorNumber does not contain errNum) then
					fail(message & linefeed & errMsg & linefeed & "Exception raised: " & errNum)
				end if
				countAssertion()
				return
			end try
			fail(message)
		end shouldRaise
		
	end script
end makeAssertions

(*! @abstract Base class for loggers. *)
script TestLogger
	property parent : Observer
	property _TestResult : missing value
	property separator : "----------------------------------------------------------------------"
	property successColor : {256 * 129, 256 * 167, 256 * 147} -- RGB (129,167,147)
	property defectColor : {256 * 215, 256 * 67, 256 * 34} -- RGB (215,67,34)
	property defaultColor : {256 * 12, 256 * 56, 256 * 67} -- RGB (12,56,67)
	
	(*! @abstract Overrides @link Observer @/link's <tt>setNotifier()</tt>. *)
	on setNotifier(aTestResult)
		set my _TestResult to aTestResult
	end setNotifier
	
	(*!
		@abstract
			Initializes this logger.
		@discussion
			This handler may be overriden by subclasses to perform any needed
			initialization step. This handler is called automatically by @link autorun @/link.
	*)
	on initialize()
	end initialize
	
	(*!
		@abstract
			Logs the given event.
		@param
			anEvent <em>[record]</em> An event. For the structure of an event,
			see <tt>notify()</tt> in @link TestResult @/link.
	*)
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
	
	(*! @abstract Prints the title of the test results. *)
	on printTitle()
		printLine("")
		printLine(((my _TestResult's startDate) as text))
		printLine("")
		printLine(my _TestResult's name)
		printLine("")
	end printTitle
	
	(*! @abstract Prints a summary of the test results. *)
	on printSummary()
		printDefects("ERRORS", my _TestResult's errors)
		printDefects("FAILURES", my _TestResult's failures)
		printCounts()
		printResult()
	end printSummary
	
	(*!
		@abstract
			Prints the name of the current test.
		@param
			aTestCase <em>[script]</em> A test case.
	*)
	on printTestCase(aTestCase)
		printString(aTestCase's fullName() & " ... ")
	end printTestCase
	
	(*! @abstract Prints the success string for the current test. *)
	on printSuccess()
		printColoredString("ok" & linefeed, my successColor)
	end printSuccess
	
	(*! @abstract Prints the skip string for the current test. *)
	on printSkip()
		printColoredString("skip" & linefeed, my successColor)
	end printSkip
	
	(*! @abstract Prints the failure string for the current test. *)
	on printFail()
		printColoredString("FAIL" & linefeed, my defectColor)
	end printFail
	
	(*! @abstract Prints the error string for the current test. *)
	on printError()
		printColoredString("ERROR" & linefeed, my defectColor)
	end printError
	
	(*!
		@abstract
			Prints detailed information about failures and errors.
		@param
			title <em>[text]</em> The type of defect (failures, errors).
			defects <em>[list]</em> The list of failures and errors.
	*)
	on printDefects(title, defects)
		if (count of defects) is 0 then return
		printLine("")
		printLine(title)
		repeat with aResult in defects
			printColoredLine(my separator, my defectColor)
			printColoredLine("test: " & aResult's test's fullName(), my defectColor)
			repeat with aLine in every paragraph of aResult's message
				printColoredLine("      " & aLine, my defectColor)
			end repeat
		end repeat
		printColoredLine(my separator, my defectColor)
	end printDefects
	
	(*! @abstract Prints the counts of passed and skipped tests, failures, and errors. *)
	on printCounts()
		printLine("")
		set {tid, AppleScript's text item delimiters} to {AppleScript's text item delimiters, ""}
		tell my _TestResult
			set elapsed to runSeconds()
			set timeMsg to (elapsed as text) & " second"
			if elapsed is not 1 then set timeMsg to timeMsg & "s"
			set counts to {runCount() & " tests, ", Â
				passCount() & " passed (", Â
				assertionCount() & " assertions), ", Â
				failureCount() & " failures, ", Â
				errorCount() & " errors, ", Â
				skipCount() & " skips."}
		end tell
		printLine("Finished in " & timeMsg & ".")
		printLine("")
		printLine(counts as text)
		set AppleScript's text item delimiters to tid
	end printCounts
	
	(*! @abstract Prints "OK" or "FAILED" at the end of the test results.  *)
	on printResult()
		printLine("")
		if my _TestResult's hasPassed() then
			printColoredLine("OK", my successColor)
		else
			printColoredLine("FAILED", my defectColor)
		end if
	end printResult
	
	(*!
		@abstract
			Prints the given text with the given style.
		@discussion
			This handler must be implemented by subclasses.
		@param
			aString <em>[text]</em> The text to be printed.
		@param
			aColor <em>[RGB color]</em> The text color.
	*)
	on printColoredString(aString, aColor)
	end printColoredString
	
	(*!
		@abstract
			Prints a string using the default color.
		@param
			aString <em>[text]</em> The text to be printed.
	*)
	on printString(aString)
		printColoredString(aString, my defaultColor)
	end printString
	
	(*!
		@abstract
			Prints a string with the given color and starts a new line.
		@param
			aString <em>[text]</em> The text to be printed.
		@param
			aColor <em>[RGB color]</em> The text color.
	*)
	on printColoredLine(aString, aColor)
		printColoredString(aString & linefeed, aColor)
	end printColoredLine
	
	(*!
		@abstract
			Prints a string using the default color and starts a new line.
		@param
			aString <em>[text]</em> The text to be printed.
	*)
	on printLine(aString)
		printColoredLine(aString, my defaultColor)
	end printLine
	
	(*!
		@abstract
			Removes the trailing newline from the text, if present.
		@param
			s <em>[text]</em> A string.
		@return
			The string <tt>s</tt> with the trailing newline character removed, if any.
	*)
	on chomp(s)
		if s ends with linefeed or s ends with return then
			try
				text 1 thru -2 of s
			on error -- s is "\n" or "\r"
				""
			end try
		else
			s
		end if
	end chomp
	
end script -- TestLogger		

(*! @abstract Displays test results in a new AppleScript Editor document. *)
script ScriptEditorLogger
	property parent : TestLogger
	property textView : missing value
	property windowTitle : "Test Results"
	
	(*! @abstract Creates a ÒTest ResultsÓ document if one does not already exist. *)
	on initialize()
		local loggerPath, tid
		set loggerPath to ((path to temporary items from user domain) as text) & my windowTitle
		try -- to reuse an existing window
			tell application id "com.apple.ScriptEditor2"
				set my textView to get document (my windowTitle)
				set my textView's window's index to 1 -- bring to front
			end tell
		on error -- create a new document
			tell application id "com.apple.ScriptEditor2"
				save (make new document) in file loggerPath as "text"
				set my textView to document (my windowTitle)
			end tell
		end try
	end initialize
	
	(*!
		@abstract
			Prints the given string to the ÒTest ResultsÓ document.
		@param
			aString <em>[text]</em> The text to be printed.
		@param
			aColor <em>[RGB color]</em> The text color.
	*)
	on printColoredString(aString, aColor)
		tell my textView
			set selection to insertion point -1
			set contents of selection to aString
			if aColor is not missing value then Â
				set color of contents of selection to aColor
			set selection to insertion point -1
		end tell
	end printColoredString
	
	(*!
		@abstract
			Prints the given string to the ÒTest ResultsÓ document and starts a new line.
		@discussion
			The string is automatically prefixed by <tt>--</tt>,
			so that it is treated as a comment by AppleScript Editor.
		@param
			aString <em>[text]</em> The text to be printed.
		@param
			aColor <em>[RGB color]</em> The text color.
	*)
	on printColoredLine(aString, aColor)
		printColoredString("-- " & aString & linefeed, aColor)
	end printColoredLine
	
	(*!
		@abstract
			Prints the name of the current test.
		@discussion
			The string is automatically prefixed by <tt>--</tt>,
			so that it is treated as a comment by AppleScript Editor.
		@param
			aTestCase <em>[script]</em> A test case.
	*)
	on printTestCase(aTestCase)
		printString("-- " & aTestCase's fullName() & " ... ")
	end printTestCase
	
end script -- ScriptEditorLogger		

(*! @abstract Displays test results in the console. *)
script ConsoleLogger
	property parent : TestLogger
	property _buffer : ""
	
	(*!
		@abstract
			Logs the given string.
		@param
			aString <em>[text]</em> The text to be printed.
		@param
			aColor <em>[RGB color]</em> The text color. Ignored.
	*)
	on printColoredString(aString, aColor)
		if aString ends with linefeed then -- flush buffer
			log my _buffer & chomp(aString)
			set my _buffer to ""
		else
			set my _buffer to my _buffer & aString
		end if
	end printColoredString
	
end script -- ConsoleLogger		

(*! @abstract Prints colorful test results to the standard output. *)
script StdoutLogger
	property parent : TestLogger
	property esc : "\\033["
	property black : esc & "0;30m"
	property blue : esc & "0;34m"
	property cyan : esc & "0;36m"
	property green : esc & "0;32m"
	property magenta : esc & "0;35m"
	property purple : esc & "0;35m"
	property red : esc & "0;31m"
	property yellow : esc & "0;33m"
	property white : esc & "0;37m"
	property boldType : esc & "1m"
	property reset : esc & "0m"
	property successColor : green
	property defectColor : red
	property defaultColor : reset
	property _buffer : ""
	
	-- Make color bold
	on bb(kolor)
		esc & "1;" & text -3 thru -1 of kolor
	end bb
	
	on echo(s)
		set s to do shell script "echo " & quoted form of s without altering line endings
		log chomp(s) -- Remove echo's linefeed (log adds its own)
	end echo
	
	(*!
		@abstract
			Logs the given string.
		@param
			aString <em>[text]</em> The text to be printed.
		@param
			aColor <em>[RGB color]</em> The text color.
	*)
	on printColoredString(aString, aColor)
		if aString ends with linefeed then
			echo(_buffer & aColor & chomp(aString) & reset)
			set _buffer to ""
		else
			set _buffer to _buffer & aColor & aString & reset
		end if
	end printColoredString
	
end script -- StdoutLogger

-----------------------------------------------------------------
-- The ASUnit framework.
-----------------------------------------------------------------

(*!
	@abstract
		<em>[script]</em> Saves the current fixture while compiling
	 	test cases in a fixture.
*)
property _currentFixture : missing value

(*!
	@abstract
		Sentinel object used to mark missing values.
	@discussion
		This is used, in particular, to catch a missing suite property in a test script.
*)
script ASUnitSentinel
	property parent : AppleScript
end script

(*!
	@abstract
		Used to automatically collect tests in a script file.
	@discussion
		If a test script defines its own suite property, this property will be shadowed.
*)
property suite : ASUnitSentinel

(*!
	@abstract
		The base class for test components.
	@discussion Test suites are a composite of components.
	 	The basic unit is a single @link TestCase @/link, which may be tested as is.
		Several <tt>TestCase</tt>s are grouped in a @link TestSuite @/link,
		which can test all its tests. A <tt>TestSuite</tt> may contain other
		<tt>TestSuite</tt>s, which may contain other suites.
		Testing a composite returns a @link TestResult @/link object.
*)
script TestComponent
	-- The parent property must be set to something different from the top-level script.
	-- Without explicitly setting its parent, TestComponent
	-- would inherit the top-level name property and would pass it to all its descendant scripts,
	-- which would not be able to get their own name any longer (see TestCase's fullName()).
	-- AppleScript is the correct object to inherit from: it makes all global constants
	-- available in tests. The AppleScript object has a name property, but fortunately
	-- it is not inherited (as well as its version property).
	property parent : AppleScript
	
	(*!
		@abstract
			Runs a test.
		@return
			<em>[script]</em> A @link TestResult @/link object.
	*)
	on test()
		set aTestResult to TOP_LEVEL's makeTestResult(my name)
		tell aTestResult
			runTest(me)
		end tell
		return aTestResult
	end test
	
	(*!
		@abstract
			Tells whether this is a composite test.
		@discussion
			Allows transparent handling of components, avoiding <tt>try... on error</tt>,
			e.g., if <tt>a's isComposite()</tt> then <tt>a's add(foo)</tt>.
		@return
			<em>[boolean]</em> <tt>true</tt> if this a composite test; <tt>false</tt> otherwise.
		*)
	on isComposite()
		return false
	end isComposite
	
	(*!
		@abstract
			Implemented by sub classes.
		@param
			aVisitor <em>[script]</em> A visitor.
	*)
	on accept(aVisitor)
		return
	end accept
	
end script -- TestComponent

(*!
	@abstract
		Models a certain configuration of the system being tested.
*)
script TestCase
	property parent : TestComponent
	(*! @abstract Maintains the count of non-failing assertions in the current test case. *)
	property nAssertions : 0
	
	(*! @abstract Returns the count of assertions run successfully in the current test case. *)
	on numberOfAssertions()
		return nAssertions
	end numberOfAssertions
	
	(*!
		@abstract
			Increments the count of successful assertions in the current test case.
		@discussion
			Each assertion must call this handler after checking its assertion.
	*)
	on countAssertion()
		set nAssertions to nAssertions + 1
	end countAssertion
	
	(*! @abstract TODO. *)
	on accept(aVisitor)
		set nAssertions to 0
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
		@abstract
			Runs a test case.
		@discussion
			Ensures that <tt>tearDown()</tt> is executed,
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
	
	(*! @abstract Returns the full name of this test. *)
	on fullName()
		return my parent's name & " - " & my name
	end fullName
	
end script -- TestCase

(*!
	@abstract
		Creates an unregistered fixture inheriting from @link TestCase @/link.
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
	@abstract
		Primitive registration handler.
	@discussion
		May be used to register a fixture inheriting from a <tt>TestCase</tt> subclass.
*)
on registerFixtureOfKind(aUserFixture, aParent)
	set my _currentFixture to aUserFixture
	return aParent
end registerFixtureOfKind

(*! @abstract Convenience handler for registering fixture inheriting from @link TestCase @/link. *)
on registerFixture(aUserFixture)
	TestSet(aUserFixture)
end registerFixture

(*! @abstract A more user-friendly name for @link registerFixture @/link. *)
on TestSet(aUserFixture)
	return registerFixtureOfKind(aUserFixture, makeAssertions(TestCase))
end TestSet

(*!
	@abstract
		Creates an unregistered @link TestCase @/link inheriting from the current fixture.
	@discussion
		You can run the test case or add it manually to a suite.
	 	This feature is essential for ASUnit own unit tests.
*)
on makeTestCase()
	return my _currentFixture
end makeTestCase

(*!
	@abstract
		Creates a test case and registers it with the main script suite.
	@discussion
		This test will run automatically when you run the suite.
*)
on registerTestCase(aUserTestCase)
	UnitTest(aUserTestCase)
end registerTestCase

(*! @abstract A more user-friendly name for @link registerTestCase @/link. *)
on UnitTest(aUserTestCase)
	set aSuite to aUserTestCase's parent's suite
	if aSuite is not ASUnitSentinel then aSuite's add(aUserTestCase)
	return makeTestCase()
end UnitTest

(*!
	@abstract
		Creates a test suite.
	@discussion
		Each test script should define a <tt>suite</tt> property to support
	 	automatic registration of test cases. If a suite is not defined,
		tests will have to be registered with a suite manually. You may define
		your own suite class, inheriting from @link TestSuite @/link.
		Each test script should define a <tt>suite</tt> property and initialize it
		with @link makeTestSuite @/link, or with a @link TestSuite @/link subclass.
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
			repeat with aTest in my tests
				aTest's accept(aVisitor)
			end repeat
		end accept
		
		(*! @abstract TODO. *)
		on isComposite()
			return true
		end isComposite
		
		(*!
			@abstract
				Adds a test case or test suite to this suite.
			@param
				aTest <em>[script]</em> May be a @link TestCase @/link
			 	or another @link TestSuite @/link containing other <tt>TestCase</tt>s
				and <tt>TestSuite</tt>s.
		*)
		on add(aTest)
			set end of my tests to aTest
		end add
		
	end script -- TestSuite
	
	return TestSuite
	
end makeTestSuite

(*! @abstract Loads tests from files and folders, and returns a suite with all tests. *)
on makeTestLoader()
	
	script TestLoader
		property name : "TestLoader"
		
		(*! @abstract Only files that starts with prefix will be considered as tests. *)
		property prefix : "Test"
		
		(*!
			@abstract
				Returns a test suite containing all the suites
				in the tests scripts in the specified folder.
		*)
		on loadTestsFromFolder(aFolder)
			local suite
			set suite to makeTestSuite("All Tests in " & (aFolder as text))
			compileSourceFiles(aFolder)
			
			tell application "Finder"
				set testFiles to files of aFolder Â
					where name starts with my prefix and name ends with Â
					".scpt" and name does not start with Â
					"Test Load" and name does not start with "TestLoad"
			end tell
			repeat with aFile in testFiles
				suite's add(loadTestsFromFile(aFile))
			end repeat
			
			return suite
		end loadTestsFromFolder
		
		(*! @abstract Compiles all the test scripts in the specified folder. *)
		on compileSourceFiles(aFolder)
			tell application "Finder"
				set testFiles to files of aFolder Â
					where name starts with my prefix and name ends with Â
					".applescript" and name does not start with Â
					"Test Load" and name does not start with "TestLoad"
			end tell
			repeat with aFile in testFiles
				set outfile to (text 1 thru -(2 + (length of (aFile's name extension as text))) Â
					of (aFile's name as text)) & ".scpt"
				set cmd to "osacompile -d -o " & space & Â
					quoted form of (POSIX path of (aFolder as alias) & outfile) & space & Â
					quoted form of POSIX path of (aFile as alias)
				try
					do shell script cmd
				on error errMsg
					log "Skipping " & aFile & space & "(Could not compile)"
					log errMsg
				end try
			end repeat
		end compileSourceFiles
		
		(*!
			@abstract
				Returns a test suite from aFile or the default suite.
			@throws
				An error if a test file does not have a <tt>suite</tt> property.
		*)
		on loadTestsFromFile(aFile)
			-- TODO: Should check for comforming suite?
			set testScript to load script file (aFile as text)
			try
				set aSuite to testScript's suite
				if testScript's suite is my ASUnitSentinel then MissingSuiteError(aFile)
				return aSuite
			on error number 10
				MissingSuiteError(aFile)
			end try
			
		end loadTestsFromFile
		
		(*! @abstract Raises a missing suite error. *)
		on MissingSuiteError(aFile)
			set f to aFile as text
			error f & " does not have a suite property"
		end MissingSuiteError
		
	end script -- TestLoader
	
	return TestLoader
	
end makeTestLoader

-----------------------------------------------------------------
-- End of ASUnit framework
-----------------------------------------------------------------

(*! @abstract Automatically runs all the registered tests. *)
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
		if current application's id is "com.apple.ScriptEditor2" then
			set loggers to {ScriptEditorLogger}
		else if current application's name is "osascript" then
			set loggers to {StdoutLogger}
		else
			set loggers to {ConsoleLogger}
		end if
	end try
	repeat with aLogger in loggers
		aLogger's initialize()
		tell theTestRunner to addObserver(aLogger)
	end repeat
	tell theTestRunner to runTest(aTestSuite)
	return
end autorun

on run
	-- Enable loading the library from text format with run script
	return me
end run
