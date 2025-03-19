![ASUnit Logo](./assets/asunit_logo-208x64.png)


# ASUnit

[ASUnit][] is a unit testing framework for `AppleScript` derived from the
original [codebase][ASUnit-original][^1]. For a detailed description of the
architecture of the original **ASUnit** framework, read the [old
manual](./OldManual.md); some advanced features of **ASUnit** (e.g., custom
`TestCase` and `Visitor`) are still described *only* in that document.

**ASUnit**'s API is now thoroughly commented using
[HeaderDoc][Wikipedia-HeaderDoc].


## Download

> [!NOTE]
> Any single one of these three methods will get a copy of ASUnit; your
> choice—pick one.

1. To get **ASUnit**, you may clone the repository from GitHub:

```sh
git clone https://github.com/lifepillar/ASUnit.git
```

   This is the preferred choice if you plan to contribute to the code.

2. Instead, if you just want to make use of the framework, you may prefer to
   download [a compressed tarball][ASUnit-tags]. To do that from the terminal:

```sh
VERSION="1.2.4"
TARBALL="${VERSION}.tar.gz"
ASUNIT_BASE_URL="https://github.com/lifepillar/ASUnit/"
TARBALL_URL="${ASUNIT_BASE_URL}/archive/refs/tags/${TARBALL}"
cd ~/Downloads
curl -O "${TARBALL_URL}"
tar zxvf "${TARBALL}"
```

   Change `VERSION` above to match the version you want to download.

3. Alternatively, if you prefer working with `zip` archives, they're here
   too. For example, use these steps to download "1.2.4.zip":

```sh
VERSION="1.2.4"
ZIPFILE="${VERSION}.zip"
ASUNIT_BASE_URL="https://github.com/lifepillar/ASUnit/"
ZIPFILE_URL="${ASUNIT_BASE_URL}/archive/refs/tags/${ZIPFILE}"
cd ~/Downloads
curl -O "${ZIPFILE_URL}"
unzip "${ZIPFILE}"
```


## Install

To build and install **ASUnit**, you can proceed in two different ways.

1. If you use `AppleScript` 2.4 (OS X 10.10 "Yosemite") or later and have
installed [ASMake][], you may just write:

```sh
cd ASUnit
./asmake install
```

2. Otherwise, you can install it manually with the following commands:

```sh
SCRIPT_LIBS_DIR="${HOME}/Library/Script\ Libraries/"
ASUNIT_LIB_DIR="${SCRIPT_LIBS_DIR}/com.lifepillar"
mkdir -p "${ASUNIT_LIB_DIR}"

cd ASUnit
ASUNIT_TEXT="ASUnit.applescript"
ASUNIT_BNDL="ASUnit.scptd"
osacompile -o ${ASUNIT_BNDL} -x ${ASUNIT_TEXT}
mv ${ASUNIT_BNDL} "${ASUNIT_LIB_DIR}"
```

In either case, the file `ASUnit.scptd` will be installed in
`~/Library/Script Libraries/com.lifepillar`.

> [!WARNING]
> If you get an error about text encoding like this one:
>
> *The file “ASUnit.applescript” couldn’t be opened because
> the text encoding of its contents can’t be determined. (-2700)*
>
> open the file with *Script Editor*[^2], save it and try again.
>
> You can confirm the desired text encoding with this command, shown with shell
> prompt:
>
> ```console
> $ xattr -p com.apple.TextEncoding ASUnit.applescript
> ```
>
>The expected output should be `macintosh;0`.


## Importing ASUnit

To use **ASUnit**, add *one* of the two properties below to your script
in order to import the library.

If you have `AppleScript` 2.3 (OS X 10.9 "Mavericks") or later, use this:

```applescript
property parent : script "com.lifepillar/ASUnit"
```

Otherwise, if you have an older, pre-Mavericks system, use this instead:

```applescript
property parent : ¬
  load script (((path to library folder from user domain) as text) ¬
    & "Script Libraries:com.lifepillar:ASUnit.scptd") as alias
```


## Running Tests

Your test script must define a `suite` property and pass it to **ASUnit**'s
`autorun()` handler:

```applescript
property suite : makeTestSuite("A description for my tests")
autorun(suite)
```

You may run the test script inside *Script Editor*, from the command-line using
`osascript`, or in other environments (e.g., [Script
Debugger][ScriptDebugger], *AppleScriptObjC Explorer*).

When you have several test files, you may run them all at once using a *test
loader* (there is no need to compile them in advance). See *Test
Loader.applescript* in the [examples](./examples/) folder.


### Logging

By default, if you run the tests in [Script Editor][ScriptEditor-doc], the
output is written to a new *Script Editor* document; if you run the tests
in the [Terminal][Terminal-doc], the output is sent to stdout; otherwise,
the output is sent to the current system logger through `log` statements;
access them via [Console][Console-doc].

You may, however, change this by setting the `suite's loggers` property. The
value of this property must be a list of *loggers* (you may send the output to
more than one destination). Currently, **ASUnit** defines three loggers:

- `AppleScriptEditorLogger`: sends colored output to a *Script Editor* window;
- `StdoutLogger`: sends colored output to stdout.
- `ConsoleLogger`: prints the output using `log` statements (most portable logger).

Defining custom loggers should be fairly easy: you simply need to define
a script that inherits from `TestLogger` and override the `print…()` handlers
to generate the output you want. A more advanced alternative consists in
subclassing `Visitor`: you may find an example in the [old
manual](./OldManual.md#creating-new-operations-on-a-test-suite).


## Writing Tests

A test template is provided in the [templates](./templates/) folder. See the
[examples](./examples/) folder for complete examples. The general structure of
a test script is as follows:

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

Each unit test is a script that inherits from `UnitTest(me)`. Inside such
scripts, you may make a number of assertions.


### Assertions

Below, “iff” stands for [“if and only if”][Wikipedia-iff].

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

A clarification is in order for the last three types of assertions. Consider
the following two scripts:

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

Related unit tests can be grouped together into a script that must inherit from
`TestSet(me)`. One advantage of grouping tests is that you may define `setUp()`
and `tearDown()` operations that are automatically executed before and after
each unit test, respectively. Such handlers can be used for initialization of
data structures and clean up operations, and help ensure that each unit test is
not affected by the behavior of the others.

Note that the names of the scripts are used in the output. For this reason, you
may want to use short sentences enclosed between vertical bars as script names,
as it was done in the example above. Alternatively, you may define the `name`
property of the script explicitly.


## Copyright

Copyright © 2013 Lifepillar, 2006 Nir Soffer. All rights reserved.


## License

This software is licensed under the [GNU GPL-2.0][GNU-GPLv2] License, see COPYING for details.


[^1]: The original framework codebase was written by Nir Soffer.
[^2]: `Script Editor` was called `AppleScript Editor` from 2009 to 2014 but it's the same program.


[//]: # (Cross reference section)

[ASMake]: https://github.com/lifepillar/ASMake/
[ASUnit]: https://github.com/lifepillar/ASUnit/
[ASUnit-tags]: https://github.com/lifepillar/ASUnit/tags
[ASUnit-original]: http://nirs.freeshell.org/asunit/
[Console-doc]: https://support.apple.com/guide/console/welcome/mac
[GNU-GPLv2]: https://opensource.org/license/gpl-2-0
[HeaderDoc-doc]: https://developer.apple.com/library/archive/documentation/DeveloperTools/Conceptual/HeaderDoc/intro/intro.html
[ScriptDebugger]: https://www.latenightsw.com "Script Debugger"
[ScriptEditor-doc]: https://support.apple.com/guide/script-editor/welcome/mac
[Terminal-doc]: https://support.apple.com/guide/terminal/welcome/mac
[Wikipedia-HeaderDoc]: https://en.wikipedia.org/wiki/HeaderDoc
[Wikipedia-iff]: https://simple.wikipedia.org/wiki/If_and_only_if
