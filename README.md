## ASUnit, an AppleScript unit testing framework

[ASUnit](http://nirs.freeshell.org/asunit/) is a unit testing framework for
AppleScript originally written by Nir Soffer.

This version of ASUnit actually includes two different test frameworks: one is the
original and excellent ASUnit's framework by Nir Soffer, in which tests are typically
registered at compile time; the other is the newer MiniTest, in which tests are
typically registered at run time. We start by describing the latter.

### MiniTest

In MiniTest, a test script has the following structure:

    script TheTestSuite
    
        TestSet(TC1, "Test case one")
        script TC1
        
          on setUp()
            -- Code executed before each unit test
          end
          
          on tearDown()
            -- Code executed after each unit test
          end
          
          UnitTest(UT1, "Unit test one")
          script UT1
            -- A unit test may use assertions to perform tests, e.g.,
            assert(1 + 1 = 2, "One plus one should equal two")
            assertEqual(2, 1 + 1)
            refute(3 = 1 + 1, "One plus one should not be three")
            -- Etc…
          end
          
          UnitTest(UT2, "Unit test two")
          script UT2
            -- Etc…
          end
        end
        
        TestSet(TC2, "Test case two")
        script TC2
          -- Etc…
        end
    end

A _unit test_ is a script containing at least one assertion. Each unit test
must be registered using the `UnitTest()` directive. Related unit tests may
be grouped into _test cases_, which are just collections of tests. Each
test case must be registered using a `TestSet()` directive.
One advantage of grouping
tests in test cases is that you may define `setUp()` and `tearDown()` operations
that are automatically executed respectively before and after each unit test
in the test case. Such handlers can be used for initialization of
data structures and clean up operations, and help ensure that each unit test
is not affected by the behavior of the others.
Finally, test cases must be included in a script (`TheTestSuite` in the code
above), which is the script passed to MiniTest.

To execute the above test suite, you must add the code that loads MiniTest
and runs the tests:

    set MiniTest to MiniTest of (load script file "path:to:ASUnit.scpt")
    tell MiniTest to autorun(TheTestSuite)

#### Example

The following is a complete self-contained example that tests hypothetical
script objects for manipulating hexadecimal strings:

    on makeHexString(aString)
      script
        property value : aString
      
        on toUTF8() -- Interprets this hexadecimal string as UTF8-encoded text
          run script "«data utf8" & value & "» as text"
        end toUTF8
      
        on toDec() -- Converts this hexadecimal string to an integer value
          (run script "«data long" & reversebytes() & "» as text") as integer
        end toDec
      
        on reversebytes()
          value -- wrong
        end reversebytes
      
      end script
    end makeHexString

    -- Load MiniTest from the same folder that contains this script
    set myFolder to (folder of file (path to me) of application "Finder") as text
    set MiniTest to MiniTest of (load script file (myFolder & "ASUnit.scpt"))
  
    -- Run the test suite!
    MiniTest's autorun(HexStringTestSuite)

    script HexStringTestSuite
    
      TestSet(TestToUTF8, "Conversions to UTF8")
      script TestToUTF8
        property x : missing value -- To store a hex string
      
        on tearDown()
          set x to missing value -- Make sure x does not retain a value from a previous test
        end tearDown
      
        UnitTest(TestAscii, "Hex string should be 'abcde'")
        script TestAscii
          set x to makeHexString("6162636465")
          assertEqual("abcde", x's toUTF8())
        end script
      
        UnitTest(TestAccents, "Hex string should be 'àèìòù'")
        script TestAccents
          set x to makeHexString("C3A0C3A8C3ACC3B2C3B9")
          assertEqual("àèìòù", x's toUTF8())
        end script
      
      end script
    
      TestSet(TestToDec, "Conversion to decimal")
      script TestToDec
        property x : missing value -- To store a hex string
      
        on tearDown()
          set x to missing value
        end tearDown
      
        UnitTest(TestClass, "Class of toDec()'s result")
        script TestClass
          set x to makeHexString("0")
          assert(x's toDec()'s class is integer, "class should be integer")
        end script
      
        UnitTest(TestZero, "Convert zero")
        script TestZero
          set x to makeHexString("0000")
          assertEqual(0, x's toDec())
        end script
      
        UnitTest(TestOneThousand, "Convert one thousand")
        script TestOneThousand
          set x to makeHexString("03E8")
          assertEqual(1000, x's toDec())
        end script
      
      end script -- TestToDec
    
    end script -- HexStringTestSuite
    
If you run the script above (this can be done in AppleScript Editor or
from the command line with `osascript`), the output will be something similar to:

    Friday, February 15, 2013 17:49:33 
  
    HexStringTestSuite
  
    Conversions to UTF8 - Hex string should be 'abcde' ... ok
    Conversions to UTF8 - Hex string should be 'àèìòù' ... ok
    Conversion to decimal - Class of toDec()'s result ... ok
    Conversion to decimal - Convert zero ... ok
    Conversion to decimal - Convert one thousand ... FAIL
  
    FAILURES
    ----------------------------------------------------------------------
    test: Conversion to decimal - Convert one thousand
          Expected: 1000
          Actual: 59395
    ----------------------------------------------------------------------
  
    Finished in 1 second.
  
    5 tests, 4 passed, 1 failures, 0 errors, 0 skips.
  
    FAILED

Fixing the script and make all the tests pass is left as an exercise to the reader :)

#### Running all tests inside a folder

If you have several test files, you may run them at once using the following code:

    set myFolder to (folder of file (path to me) of application "Finder") as text
    set MiniTest to MiniTest of (load script file (myFolder & "ASUnit.scpt"))
    tell MiniTest to runTestsFromFolder(myFolder)


### ASUnit


The original ASUnit framework differs from MiniTest because tests are typically
registered at compile time. Therefore, ASUnit must be loaded at compile time, too
(which may not always be convenient). Using ASUnit, a test script has the following
structure:

    property parent : ASUnit of (load script file "path:to:ASUnit.scpt")
    property suite : makeTestSuite("My Unit Tests")
    
    script |Test case one|
      property parent : registerFixture(me)
  
      script |some test|
        property parent : registerTestCase(me)
        
        assert(1 + 1 = 2, "one plus one should be two")
        assertEqual(2, 1 + 1)
        refute(3 = 1 + 1, "1 + 1 should not be 3")
      end script

      script |some other test|
        property parent : registerTestCase(me)
        -- Etc…
      end
    end script

    script |Test case two|
      property parent : registerFixture(me)
       -- Etc…
    end

Using ASUnit, a test script typically inherits from ASUnit (first line)
and defines a `suite` property by calling ASUnit's `makeTestSuite()` (second line).
Then, each test case inherits from ASUnit's `TestCase` script by setting its
`parent` property to the result of `registerFixture(me)`.
Similarly, each unit test inside each test case inherits from `TestCase` by setting
its parent property to the result of `registerTestCase(me)`. Note that all such handler
invocations happen when the script is compiled. Note also that the names of the scripts
are used as test descriptions for the output. For this reason, you may want to use
short sentences (enclosed between vertical bars) as script names, as done above.

For a detailed description of the architecture of the original ASUnit framework,
read the file `Manual.md`.

#### Running all tests inside a folder

When you start writing many test files, you may want to run them all at once.
In ASUnit, you do so with a script like the following:

    property myFolder : folder of file (document 1's path as POSIX file) of application "Finder"
    property parent : ASUnit of (load script file ((myFolder as text) & "ASUnit.scpt"))
    set suite to makeTestLoader()'s loadTestsFromFolder(myFolder)
    autorun(suite)

Save this script in the same folder as your test files and run it from AppleScript Editor.
It will load all the _compiled_ scripts whose name starts with `Test`
and it will execute all of their tests, producing a single global summary at the end.


### License

GNU GPL, see COPYING for details.

Copyright © 2013 Lifepillar, 2006 Nir Soffer

