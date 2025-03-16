# ASUnit
### the AppleScript unit testing framework

[ASUnit][] is a unit testing framework for AppleScript; the original [codebase][ASUnit-original] was written by Nir Soffer.
For a detailed description of the architecture of the original ASUnit framework,
read the file `OldManual.md`. Some advanced features of ASUnit (e.g., custom
TestCases and Visitors) are still described only in that document.

ASUnit's [API][ASUnit-api-ref] is thoroughly commented using [HeaderDoc][Wikipedia-HeaderDoc].

## Download

Any single one of these three methods will get a copyh of the repository; your choice.

To get ASUnit, you may clone the repository from GitHub:
```sh
git clone https://github.com/lifepillar/ASUnit.git
```

Instead, you may download a compressed tarball from our [tagged commits][ASUnit-tags].
The top choice is the most recent; make `VERSION` be the same as its major.minor.bug.
For example, use these steps to download "1.2.4.tar.gz":
```sh
ASUNIT_BASE_URL="https://github.com/lifepillar/ASUnit/"
VERSION="1.2.4"
TARBALL="${VERSION}.tar.gz"
TARBALL_URL="${ASUNIT_BASE_URL}/archive/refs/tags/${TARBALL}"
cd ~/Downloads
curl -O "${TARBALL_URL}"
tar zxvf "${TARBALL}"
```

Alternatively, if you prefer working with `zip` archives, they're here too.
For example, use these steps to download "1.2.4.zip":
```sh
ASUNIT_BASE_URL="https://github.com/lifepillar/ASUnit/"
VERSION="1.2.4"
ZIPFILE="${VERSION}.zip"
ZIPFILE_URL="${ASUNIT_BASE_URL}/archive/refs/tags/${ZIPFILE}"
cd ~/Downloads
curl -O "${ZIPFILE_URL}"
unzip "${ZIPFILE}"
```

## Installation

To build and install ASUnit, you have two options. If you have installed
[ASMake][], you may just write:
```sh
cd ASUnit
./asmake install
```

Otherwise, you can install it manually with the following commands:
```sh
SCRIPT_LIBS_DIR="${HOME}/Library/Script\ Libraries/"
ASUNIT_LIB_DIR="${SCRIPT_LIBS_DIR}/com.lifepillar"
mkdir -p "${ASUNIT_LIB_DIR}"

cd ASUnit
ASUNIT_SRC="ASUnit.applescript"
ASUNIT_LIB="ASUnit.scptd"
osacompile -o ${ASUNIT_LIB} -x ${ASUNIT_SRC}
mv ${ASUNIT_LIB} "${ASUNIT_LIB_DIR}"
```
In either case, the file `ASUnit.scptd` will be installed in `"~/Library/Script Libraries/com.lifepillar"`.

**Note:** If you get an error like the following:
``` error
    The file “ASUnit.applescript” couldn’t be opened because
    the text encoding of its contents can’t be determined. (-2700)
```
open the file with Script Editor, save it and try again.

## Importing ASUnit in a test script

To use ASUnit, add one of the two choices to your script.
If you have AppleScript 2.3 or later (OS X 10.9 "Mavericks" or later):
```applescript
    property parent : script "com.lifepillar/ASUnit"
```
If you have an older pre-Mavericks system, use this instead:
```applescript
    property parent : ¬
      load script (((path to library folder from user domain) as text) ¬
        & "Script Libraries:com.lifepillar:ASUnit.scptd") as alias
```

## Running the tests

Your test script must define a `suite` property and pass it to ASUnit's
`autorun()` handler:
```applescript
    property suite : makeTestSuite("A description for my tests")
    autorun(suite)
```

You may run the test script inside AppleScript Editor,
from the command-line using `osascript`, or in other
environments ([Script Debugger][ScriptDebugger], `AppleScriptObjC Explorer`, …).

When you have several test files, you may run them all at once using
a _test loader_ (there is no need to compile them in advance).
See `Test Loader.applescript` in the `examples` folder.

### Logging

By default, if you run the tests in AppleScript Editor the output is written
to a new AppleScript Editor document; if you run the tests in the Terminal
the output is sent to stdout; otherwise, the output is sent to the current
application's console through `log` statements. You may, however, change this
by setting the `suite's loggers` property. The value of this property
must be a list of _loggers_ (you may send the output to more than one
destination). Currently, ASUnit defines three loggers:

- `AppleScriptEditorLogger`: sends colored output to an AS Editor window;
- `StdoutLogger`: sends colored output to stdout.
- `ConsoleLogger`: prints the output using `log` statements (most portable logger).

Defining custom loggers should be fairly easy: you simply need to define a
script that inherits from `TestLogger` and override the `print…()` handlers to
generate the output you want. A more advanced alternative consists in
subclassing _Visitor_: see the section _Creating new operations on a test suite_
in [OldManual.md](./OldManual.md) for an example.

## Writing the tests

A test template is provided in the `templates` folder.
See the `examples` folder for complete examples.
The general structure of a test script is as follows:
```applescript
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
```

Each unit test is a script that inherits from `UnitTest(me)`. Inside such scripts,
you may use a number of assertion handlers:

### Assertions

- `skip(msg)`: skips the current test.
- `fail(msg)`: makes the test unconditionally fail.
- `ok(expr)`: succeeds iff the boolean `expr` evaluates to true.
- `notOk(expr)`: succeeds iff `expr` evaluates to false.
- `assert(expr, msg)` or `should(expr, msg)`: succeeds iff `expr` is true.
- `refute(expr, msg)` or `shouldnt(expr, msg)`: succeeds iff `expr` is false.
- `shouldRaise(num, object, msg)`: succeeds iff `object` raises exception `num` when executed.
   The `object` can be a script object or a handler without parameters.
- `shouldNotRaise(num, object, msg)`: succeeds iff `object` does not raise exception `num` when executed.
   The `object` can be a script object or a handler without parameters.
- `assertEqual(expr, value)` or `shouldEqual(expr, value)`: succeeds iff `expr` = `value`.
- `refuteEqual(expr, value)` or `shouldNotEqual(expr, value)`: succeeds iff `expr` ≠ `value`.
- `assertMissing(expr)`: a synonym for `assertEqual(missing value, expr)`.
- `assertObjCReference(expr)`: succeeds iff `expr` is a reference to a Cocoa object.
- `refuteObjCReference(expr)`: succeeds iff `expr` is not a reference to a Cocoa object.
- `refuteMissing(expr)`: a synonym for `assertNotEqual(missing value, expr)`.
- `assertNull(expr)`: a synonym for `assertEqual(null, expr)`.
- `refuteNull(expr)`: a synonym for `assertNotEqual(null, expr)`.
- `assertEqualAbsError(e1, e2, delta)`: succeeds iff `|e1-e2| <= delta`.
- `assertEqualRelError(e1, e2, eps)`: succeeds iff `|e1-e2| <= min(|e1|,|e2|) * eps`.
- `assertReference(x)` or `shouldBeReference(x)`: succeeds iff `x` is a reference.
- `assertNotReference(x)` or `shouldNotBeReference(x)`: succeeds iff `x` is not a reference.
- `assertInstanceOf(aClass, expr)`: succeeds iff the class of `expr` is equal to `aClass`.
- `refuteInstanceOf(aClass, expr)`: succeeds iff the class of `expr` is not `aClass`.
- `assertKindOf(aClass, expr)`: succeeds iff `expr` or any of its ancestors belongs to `aClass`.
- `refuteKindOf(aClass, expr)`: succeeds iff neither `expr` nor any of its ancestors belong to `aClass`.
- `assertInheritsFrom(a, b)`: succeeds iff `b` (directly or indirectly) inherits from `a`.
- `refuteInheritsFrom(a, b)`: succeeds iff `b` does not inherit from `a`.

Some of the assertions take a textual message as an argument (`msg` parameter),
which is printed when the assertion fails.

A clarification is in order for the last three types of assertions.
Consider the following two scripts:
```applescript
    script A
      property class : "Father"
    end script

    script B
      property parent : A
      property class : "Child"
    end script
```

Then, these assertions must succeed:
```applescript
    assertInstanceOf("Father", A)
    assertInstanceOf("Child", B)
    refuteInstanceOf("Father", B)
    assertKindOf("Father", B)
    refuteInstanceOf(script, A)
    assertKindOf(script, A)
    assertInheritsFrom(A, B)
    refuteInheritsFrom(B, A)
```

Related unit tests can be grouped together into a script that must
inherit from `TestSet(me)`. One advantage of grouping
tests is that you may define `setUp()` and `tearDown()` operations
that are automatically executed before and after each unit test, respectively.
Such handlers can be used for initialization of
data structures and clean up operations, and help ensure that each unit test
is not affected by the behavior of the others.

Note that the names of the scripts are used in the output. For this reason, you
may want to use short sentences enclosed between vertical bars as script names,
as it was done in the example above. Alternatively, you may define the `name`
property of the script explicitly.

## Copyright

Copyright © 2013 Lifepillar, 2006 Nir Soffer. All rights reserved.

## License

This software is licensed under the [GNU GPL-2.0][GNU-GPLv2] License, see COPYING for details.

[//]: # (Cross reference section)

[ASMake]: https://github.com/lifepillar/ASMake/
[ASUnit]: https://github.com/lifepillar/ASUnit/
[ASUnit-api-ref]: https://lifepillar.me/ASUnit/
[ASUnit-tags]: https://github.com/lifepillar/ASUnit/tags
[ASUnit-original]: http://nirs.freeshell.org/asunit/
[Console-doc]: https://support.apple.com/guide/console/welcome/mac
[GNU-GPLv2]: https://opensource.org/license/gpl-2-0
[HeaderDoc-doc]: https://developer.apple.com/library/archive/documentation/DeveloperTools/Conceptual/HeaderDoc/intro/intro.html
[ScriptDebugger]: https://www.latenightsw.com "Script Debugger"
[ScriptEditor-doc]: https://support.apple.com/guide/script-editor/welcome/mac
[Wikipedia-HeaderDoc]: https://en.wikipedia.org/wiki/HeaderDoc
