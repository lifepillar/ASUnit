(*! @header 
@abstract
	Illustrates a trick to load ASUnit at runtime.
@discussion
	This script show a method to load ASUnit at runtime. Why would you want to do that? Suppose that you want to load ASUnit.scpt from the same folder containing the test script. You may determine the path where the script is saved with <tt>path to me</tt>, but <tt>path to me</tt> does not evaluate to the correct path if it is executed at compile-time.
	The drawback of this method is that it breaks test loaders (but it can be used for the test loader itself, i.e., the test loader can import ASUnit at runtime). Trying to define the suite property like this:
	<pre>
	property suite : a reference to TestWrapper's suite
	</pre>
	does not work (the test loader goes into an infinite loop). Trying to define the top-level script as a child of TestWrapper is also doomed to fail (<tt>path to me</tt> will cause a stack overflow):
	<pre>
	property parent : TestWrapper
	</pre>
	All in all, loading scripts at compile time is more robust.	
*)
global ASUnit
set ASUnit to ASUnit of (load script file Â
	((folder of file (path to me) of application "Finder" as text) & "ASUnit.scpt"))
run TestWrapper

-- Tests start here
(*!
@abstract
	Wraps a test suite.
@discussion
	To be able to set the parent property at runtime, a wrapper script must be defined, whose parent is set to <tt>a reference to</tt> ASUnit.
*)
script TestWrapper
	property parent : a reference to its ASUnit
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
	
end script -- TheTestWrapper
