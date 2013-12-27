property loggers : missing value

set MiniTest to MiniTest of (run script file Â
	((folder of file (path to me) of application "Finder" as text) & "ASUnit.applescript"))
log "ASUnit MiniTest v" & MiniTest's version
set loggers to {MiniTest's AppleScriptEditorLogger, MiniTest's ConsoleLogger}
MiniTest's autorun(MiniTestSuite)

script MiniTestSuite
	
	UnitTest(T1, "Unit test inside suite")
	script T1
		ok(true)
	end script
	
	TestSet(InnerTestSuite, "Nested test suite")
	script InnerTestSuite
		
		UnitTest(T1, "Unit test inside nested suite")
		script T1
			notOk(false)
		end script
		
		TestSet(TCAssert, "assert() et al.")
		script TCAssert
			
			UnitTest(AssertTrue, "assert() succeeds with true argument")
			script AssertTrue
				assert(true, "true should be true")
			end script
			
			UnitTest(ShouldTrue, "should() succeeds with true argument")
			script ShouldTrue
				should(true, "true should be true")
			end script
			
			UnitTest(RefuteFalse, "refute() succeeds with false argument")
			script RefuteFalse
				refute(false, "false should not be true")
			end script
			
			UnitTest(ShouldntFalse, "shouldnt() succeeds with false argument")
			script ShouldntFalse
				shouldnt(false, "false should not be true")
			end script
			
			UnitTest(ShouldFalse, "should() fails with false argument")
			script ShouldFalse
				try
					should(false, "false should not be true")
				on error errMsg number errNum
					if errNum is not test_failed_error_number() then
						error errMsg number errNum
					end if
				end try
			end script
			
			UnitTest(ShouldntTrue, "shouldnt() fails with true argument")
			script ShouldntTrue
				try
					shouldnt(true, "true shouldn't be false")
				on error errMsg number errNum
					if errNum is not test_failed_error_number() then
						error errMsg number errNum
					end if
				end try
			end script
			
		end script -- TCAssert
		
		TestSet(TCAssertEqual, "assertEqual()")
		script TCAssertEqual
			
			UnitTest(compareEqual, "Compare equal objects")
			script compareEqual
				assertEqual(2, 1 + 1)
				assertEqual("ab", "a" & "b")
				shouldEqual({} as text, "")
				shouldEqual(compareEqual, compareEqual)
			end script
			
		end script -- TCAssertEqual
		
		TestSet(TCAssertNotEqual, "assertNotEqual()")
		script TCAssertNotEqual
			
			UnitTest(cmpDifferent, "Compare different objects.")
			script cmpDifferent
				script EmptyScript
				end script
				assertNotEqual(1, "a")
				assertNotEqual(cmpDifferent, EmptyScript)
				assertNotEqual(cmpDifferent, {})
				shouldNotEqual({1}, {2})
				shouldNotEqual(1 + 1, 3)
			end script
			
		end script -- TCAssertNotEqual
		
	end script -- InnerTestSuite
	
	TestSet(TRef, "assertReference().")
	script TRef
		
		UnitTest(TRef1, "Test Finder reference.")
		script TRef1
			assertReference(path to me)
			tell application "Finder" to set x to folder of file (path to me)
			assertReference(x)
		end script
		
		UnitTest(TRef2, "Test 'a reference to' operator.")
		script TRef2
			property x : 3
			set y to a reference to x
			assertReference(y)
		end script
		
		UnitTest(TRef3, "Test assertNotReference().")
		script TRef3
			property x : 1
			assertNotReference(x)
			assertNotReference({})
			set y to a reference to x
			assertNotReference(contents of y)
		end script
	end script -- TRef
	
end script -- MiniTestSuite
