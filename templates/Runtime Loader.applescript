(*! @header 
	@abstract
		Illustrates a trick to load ASUnit at runtime.
	@discussion
		This script shows a method to load ASUnit at runtime. Why would you want to do that? Suppose that you want to load ASUnit.scpt from the same folder containing the test script. You may determine the path where the script is saved with <tt>path to me</tt>, but <tt>path to me</tt> does not evaluate to the correct path if it is executed at compile-time.
		The drawback of this method is that it breaks test loaders (but it can be used for the test loader itself, i.e., the test loader can import ASUnit at runtime).
		All in all, loading scripts at compile time is more robust.	
*)
global ASUnit
set ASUnit to run script Â
	((folder of folder of file (path to me) of application "Finder" as text) & "ASUnit.applescript") as alias

-- Tests start here
(*!
@abstract
	Wraps a test suite.
@discussion
	To be able to set the parent property at runtime, a wrapper script must be defined, whose parent is set to ASUnit. The wrapper must be an <em>anonymous</em> script, so that it is ÒinstantiatedÓ at runtime.
*)
script
	property parent : ASUnit
	-- It is mandatory to define the suite property, because it is not inherited at compile time.
	property suite : missing value
	set suite to makeTestSuite("Test Template")
	(*!
	@abstract
		Wrapper handler for test cases.
	@discussion
		The test-case scripts must be defined inside a handler to avoid their instantiation at compile time, which would not be possible because their parent property is set by calling the ASUnit's handler UnitTest(), undefined at compile-time.
	*)
	on testCases()
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
	end testCases
	
	testCases()
	
	autorun(suite)
	
end script

run the result
