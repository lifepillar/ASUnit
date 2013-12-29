## ASUnit, an AppleScript unit testing framework

[ASUnit](http://nirs.freeshell.org/asunit/) is a unit testing framework for
AppleScript originally written by Nir Soffer.
For a detailed description of the architecture of the original ASUnit framework,
read the file `OldManual.md`.

To build and install ASUnit:

    git clone https://github.com/lifepillar/ASUnit.git
    cd ASUnit
    ./asmake install

The file `ASUnit.scpt` will be installed in `~/Library/Script Libraries`
(creating that folder if it does not exist).


### Importing ASUnit in a test script

To use ASUnit with AppleScript 2.3 or later (OS X 10.9 or later), add

    property parent : script "ASUnit"

at the top of your test script. For previous systems, use:

    property parent : ¬
      load script file (((path to library folder from user domain) as text) ¬
        & "Script Libraries:ASUnit.scpt")


### Running the tests

Your test script must define a `suite` property and pass it to ASUnit's
`autorun()` handler:

    property suite : makeTestSuite("A description for my tests")
    autorun(suite)

You may run the test script inside AppleScript Editor,
or from the command-line using `osascript`.

When you have several test files, you may run them all at once using
a _test loader_ (there is no need to compile them in advance).
See `Test Loader.applescript` in the `templates` folder.

By default, if you run the tests in AppleScript Editor, the output is written
to a new AppleScript Editor document, and if you run the tests in the Terminal,
the output is sent to stdout. You may, however, change this
by setting the `suite's loggers` property. The value of this property
must be a list of _loggers_ (you may send the output to more than one
destination). Currently, ASUnit defines two loggers:
`AppleScriptEditorLogger` and `ConsoleLogger`. Defining custom loggers
should be fairly easy: you simply need to define a script that inherits
from `TestLogger` and override some handlers.


### Writing the tests

A test template is provided in the `templates` folder.
See the `examples` folder for complete examples.
The general structure of a test script is as follows:

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
- `assertEqualWithAccuracy(e1, e2, delta)`: Succeeds when `|e1-e2| <= delta`.
- `assertReference(x)` or `shouldBeReference(x)`: succeeds when `x` is a reference.
- `assertNotReference(x)` or `shouldNotBeReference(x)`: fails when `x` is a reference.

Most of the assertions take as an argument a textual message,
which is printed when the assertion fails.

Related unit tests can be grouped together into a script that must
inherit from `TestSet(me)`. One advantage of grouping
tests is that you may define `setUp()` and `tearDown()` operations
that are automatically executed before and after each unit test, respectively.
Such handlers can be used for initialization of
data structures and clean up operations, and help ensure that each unit test
is not affected by the behavior of the others.

Note that the names of the scripts are used in the output. For this reason,
you may want to use short sentences enclosed between vertical bars as script
names, as it was done in the example above.


### License

GNU GPL, see COPYING for details.

Copyright © 2013 Lifepillar, 2006 Nir Soffer

