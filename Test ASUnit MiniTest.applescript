set MiniTest to MiniTest of (run script file Â
	((folder of file (path to me) of application "Finder" as text) & "ASUnit.applescript"))
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
		
		TestSet(TCAssert, "Test assert() et al.")
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
		
		TestSet(TCAssertEqual, "Test assertEqual()")
		script TCAssertEqual
			
			UnitTest(compareInts, "Compare two integers")
			script compareInts
				assertEqual(2, 1 + 1)
			end script
			
		end script -- TCAssertEqual
		
	end script -- InnerTestSuite
end script -- MiniTestSuite
