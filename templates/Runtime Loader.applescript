(*! @header 
	@abstract
		Illustrates a trick to load ASUnit at runtime.
	@discussion
		This script shows a method to load ASUnit at runtime. Why would you want to do that? 
		Suppose that you want to load ASUnit.scptd from the same folder containing the test
		script. You may determine the path where the script is saved with <tt>path to me</tt>,
		but <tt>path to me</tt> does not evaluate to the correct path if it is executed at
		compile-time.
		
		The drawback of this method is that it breaks test loaders (but it can be used for
		the test loader itself, i.e., the test loader can import ASUnit at runtime).
		All in all, loading scripts at compile time is probably the best thing to do.	
*)
property ASUnit : missing value
property suite : missing value
property dir : missing value

on run
	set my dir to (folder of folder of file (path to me) of application "Finder") as text
	set ASUnit to run script ((my dir) & "ASUnit.applescript") as alias
	set suite to ASUnit's makeTestSuite("Test Template")
	tests() -- Register tests at runtime to be able to inherit from source code, and run them
	ASUnit's autorun(suite)
end run

-- Make TestSet() and UnitTest() visible to nested scripts for convenience
on TestSet(t)
	ASUnit's TestSet(t)
end TestSet

on UnitTest(t)
	ASUnit's UnitTest(t)
end UnitTest

-- Tests are defined here:

on tests()
	script TestCaseTemplate
		property parent : TestSet(me)
		
		on setUp()
		end setUp
		
		on tearDown()
		end tearDown
		
		script testOne
			property parent : UnitTest(me)
			should(1 + 1 = 2, "1+1 is not 2")
		end script
		
		script testTwo
			property parent : UnitTest(me)
			shouldnt(1 + 1 = 3, "1+1 is 3")
		end script
	end script -- TestCaseTemplate
end tests
