## ASUnit, an AppleScript unit testing framework

[ASUnit](http://nirs.freeshell.org/asunit/) is a unit testing framework for
AppleScript originally written by Nir Soffer.
For a detailed description of the architecture of the original ASUnit framework,
read the file `OldManual.md` (you may build an HTML version of it with `./asmake manual`).

Currently, ASUnit includes two different test frameworks: one is the
original and excellent _ASUnit_'s framework by Nir Soffer, in which tests are
registered at compile time; the other is the newer _MiniTest_, in which tests are
registered at run time. The latter was developed to overcome the typical difficulties
with loading external scripts at compile time in a generic and portable way.
Starting with AppleScript 2.3 (shipping with OS X 10.9 Mavericks), which defines
a new `use` keyword, most of those concerns do not apply any longer.

ASUnit has been developed according to sound object-oriented design patterns.
MiniTest is a simpler “AppleScript-ish” implementation. Choosing one framework
or the other is mostly a matter of personal taste (it depends on which syntax
you like most).

To build and install ASUnit, see

    ./asmake help


### ASUnit

ASUnit must be loaded into your test script at compile time, because it must be
set as the parent of the test script. On OS X 10.9 or later, put `ASUnit.scpt`
in `~/Libraries/Script Libraries` (create the folder if it does not exist)
and load it as follows:

    property parent : ASUnit of script "ASUnit"

With previous OS X releases, a similar result can be achieved with a code like
this:

    property parent : ASUnit of ¬
	    (load script file (((path to library folder from user domain) as text) ¬
		    & "Script Libraries:ASUnit.scpt"))

Once ASUnit has been loaded, you must define a `suite` property as follows:

    property suite : makeTestSuite("A description for my tests")

The general structure of a test script looks as follows:

    script |One test set|
      property parent : TestSet(me)

      on setUp()
        -- Code executed before each unit test
      end

      on tearDown()
        -- Code executed after each unit test
      end

      script |a test|
        property parent : UnitTest(me)

        assert(1 + 1 = 2, "one plus one should be two")
        assertEqual(2, 1 + 1)
        refute(3 = 1 + 1, "1 + 1 should not be 3")
      end script

      script |another test|
        property parent : UnitTest(me)
        -- More assertions…
      end
    end script

    script |Another test set|
      property parent : TestSet(me)
       -- More tests…
    end

Each unit test is a script that inherits from `UnitTest(me)`. Inside such scripts,
you may use a number of assertion handlers:

- `skip(msg)`: use this to skip a given test.
- `fail(msg)`: make the test unconditionally fail.
- `ok(expr)`: succeeds when the boolean `expr` evaluates to true.
- `notOk(expr)`: succeeds when `expr` evaluates to false.
- `assert(expr, msg)` or `should(expr, msg)`: succeeds when `expr` is true.
- `refute(expr, msg)` or `shouldnt(expr, msg)`: succeeds when `expr` is false.
- `shouldRaise(num, aScript, msg)`: fails unless `aScript` raises exception `num` when run.
- `shouldntRaise(num, aScript, msg)`: fails if `aScript` raises exception `num` when run.
- `assertEqual(exp, value)` or `shouldEqual(exp, value)`: succeeds when `exp` = `value`.
- `assertNotEqual(exp, value)` or `shouldNotEqual(exp, value)`: succeeds when `exp` ≠ `value`.
- `assertReference(x)` or `shouldBeReference(x)`: succeeds when `x` is a reference.
- `assertNotReference(x)` or `shouldNotBeReference(x)`: fails when `x` is a reference.

Most of the assertions take as an argument a textual message,
which is printed when the assertion fails.

Related unit tests can be grouped together into a wrapping script that must
inherit from `TestSet(me)`. One advantage of grouping
tests is that you may define `setUp()` and `tearDown()` operations
that are automatically executed before and after each unit test, respectively.
Such handlers can be used for initialization of
data structures and clean up operations, and help ensure that each unit test
is not affected by the behavior of the others.

Note that the names of the scripts are used in the output. For this reason,
you may want to use short sentences enclosed between vertical bars as script
names, as it was done in the example above.

The tests can be executed by adding the following line to your test script:

    autorun(suite)


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


### MiniTest

If you use MiniTest, you may load ASUnit.scpt at runtime. This makes it easier,
for example, to load the script from the same folder as the test script:

    set MiniTest to MiniTest of (load script file ¬
	    ((folder of file (path to me) of application "Finder" as text) & "ASUnit.scpt"))

A test script has the following structure:

    script suite
    
        TestSet(TC1, "One test set")
        script TC1
        
          on setUp()
            -- Code executed before each unit test
          end
          
          on tearDown()
            -- Code executed after each unit test
          end
          
          UnitTest(UT1, "A test")
          script UT1
            assert(1 + 1 = 2, "One plus one should equal two")
            assertEqual(2, 1 + 1)
            refute(3 = 1 + 1, "One plus one should not be three")
          end
          
          UnitTest(UT2, "Another test")
          script UT2
            -- More assertions…
          end
        end
        
        TestSet(TC2, "Another test set")
        script TC2
          -- More tests…
        end
    end

Each unit test must be registered by calling the `UnitTest()`
handler. Note that the handler takes a description as an argument: this is used
in the output to identify the tests.
Groups of related unit tests can be wrapped into a script, which
must be registered by calling the `TestSet()` handler.
Finally, all groups must be included in a single script (`suite` in the code
above). Then, all the tests can be executed by adding the following line to your test
script:

    MiniTest's autorun(suite)


#### Running all tests inside a folder

If you have several test files, you may run them at once using the following code:

    use ASUnit : script "ASUnit"
    use scripting additions -- for 'path to me'

    set testFolder to folder of file (path to me) of application "Finder"
    tell ASUnit's MiniTest to runTestsFromFolder(testFolder)


### Setting loggers and customizing colors

No matter which framework you use, you may define where the output should go
through a `loggers` property. Currently, two loggers are defined:
`AppleScriptEditorLogger` to produce the output in an AppleScript Editor document,
and `ConsoleLogger`, to send the output to the standard output.
Setting loggers is optional: if your script does not have a `loggers` property,
a suitable logger will be chosen depending on how you execute the tests
(in AppleScript Editor vs in the Terminal with `osascript`).
See the test files in the project for the syntax to be used to set the loggers.

Three properties of `AppleScriptEditorLogger` define the colors to be used in
the output: `defaultColor`, `successColor`, and `defectColor`. See the file
`Test ASUnit.applescript` to see an example of how to set them.

Creating a new logger (for example, an HTML logger) should be fairly easy: you
just create a script that inherits from `TestLogger` and override the suitable
handlers.


### A Complete Example

The following is a self-contained example that tests a hypothetical
script object for manipulating hexadecimal strings. The script is defined in
a `HexString.scpt` file, which we assume to be saved in a `Script Libraries`
folder along with `ASUnit.scpt`:

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

To test this script, we write the following `TestHexString.scpt` script:

    use HexString : script "HexString"
    use ASUnit : script "ASUnit"
    ASUnit's MiniTest's autorun(HexStringTestSuite)

    script HexStringTestSuite

      TestSet(TestToUTF8, "Conversions to UTF8")
      script TestToUTF8
        property x : missing value -- To store a hex string

        on setUp()
          set x to missing value -- Make sure x does not retain a value from a previous test
        end setUp

        UnitTest(TestAscii, "Hex string should be 'abcde'")
        script TestAscii
          set x to HexString's makeHexString("6162636465")
          assertEqual("abcde", x's toUTF8())
        end script

        UnitTest(TestAccents, "Hex string should be 'àèìòù'")
        script TestAccents
          set x to HexString's makeHexString("C3A0C3A8C3ACC3B2C3B9")
          assertEqual("àèìòù", x's toUTF8())
        end script

      end script

      TestSet(TestToDec, "Conversion to decimal")
      script TestToDec
        property x : missing value -- To store a hex string

        on setUp()
          set x to missing value
        end setUp

        UnitTest(TestClass, "Class of toDec()'s result")
        script TestClass
          set x to HexString's makeHexString("0")
          assert(x's toDec()'s class is integer, "class should be integer")
        end script

        UnitTest(TestZero, "Convert zero")
        script TestZero
          set x to HexString's makeHexString("0000")
          assertEqual(0, x's toDec())
        end script

        UnitTest(TestOneThousand, "Convert one thousand")
        script TestOneThousand
          set x to HexString's makeHexString("03E8")
          assertEqual(1000, x's toDec())
        end script

      end script -- TestToDec

    end script -- HexStringTestSuite

    
You may run the test script in AppleScript Editor or from the command-line
with

    osascript TestHexString.scpt

The output should be:

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

    Finished in 0 seconds.

    5 tests, 4 passed, 1 failures, 0 errors, 0 skips.

    FAILED


Fixing the script and make all the tests pass is left as an exercise to the reader :)


### License

GNU GPL, see COPYING for details.

Copyright © 2013 Lifepillar, 2006 Nir Soffer

