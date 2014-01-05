(* Do not compile me into a .scpt file, run me from source! *)

-- Load ASMake from source at compile time
on _setpath()
	if current application's name is "AppleScript Editor" then
		(folder of file (document 1's path as POSIX file) of application "Finder") as text
	else if current application's name is in {"osacompile", "osascript"} then
		((POSIX file (do shell script "pwd")) as text) & ":"
	else
		error "This file can be compiled only with AppleScript Editor or osacompile"
	end if
end _setpath
property parent : run script (_setpath() & "ASMake.applescript") as alias
--

property TopLevel : me

on run {action}
	runTask(action)
end run

------------------------------------------------------------------
-- Tasks
------------------------------------------------------------------

script api
	property parent : Task(me)
	property description : "Build the API documentation."
	property dir : "Documentation"
	
	owarn("HeaderDoc's support for AppleScript is definitely broken as of v8.9 (Xcode 5.0)")
	--Set LANG to get rid of warnings about missing default encoding
	sh("env LANG=en_US.UTF-8 headerdoc2html -q -o" & space & Â
		dir & space & "ASUnit.applescript")
	sh("env LANG=en_US.UTF-8 gatherheaderdoc" & space & dir)
	sh("open " & dir & "/ASUnit_applescript/index.html")
end script

script asunitBuild
	property parent : Task(me)
	property name : "asunit"
	property description : "Build ASUnit."
	osacompile("ASUnit")
end script

script build
	property parent : Task(me)
	property description : "Build all source AppleScript scripts."
	run asunit
	osacompile({Â
		"examples/HexString", "examples/Test HexString", "examples/Test Loader", Â
		"templates/Test Template", Â
		"templates/Runtime Loader", "templates/MyScript"})
end script

script clean
	property parent : Task(me)
	property description : "Remove any temporary products."
	rm({"*.scpt", "*.scptd", "templates/*.scpt*", "examples/*.scpt*"})
end script

script clobber
	property parent : Task(me)
	property description : "Remove any generated file."
	run clean
	rm({api's dir, "ASUnit-*", "*.tar.gz", "*.html"})
end script

script doc
	property parent : Task(me)
	property description : "Build an HTML version of the old manual and the README."
	property markdown : "markdown"
	
	if which(markdown) then
		sh(markdown & space & "OldManual.md >OldManual.html")
		sh(markdown & space & "README.md >README.html")
	else
		error markdown & space & "not found." & linefeed & Â
			"PATH: " & (do shell script "echo $PATH")
	end if
end script

script dist
	property parent : Task(me)
	property description : "Prepare a directory for distribution."
	property dir : missing value
	run clobber
	run asunit
	run doc
	set dir to "ASUnit-" & TopLevel's version
	mkdir(dir)
	cp({"ASUnit.scpt", "COPYING", "OldManual.html", Â
		"README.html", "examples", "templates"}, dir)
end script

script gzip
	property parent : Task(me)
	property description : "Build a compressed archive for distribution."
	run dist
	sh("tar czf" & space & dist's dir & ".tar.gz" & space & dist's dir & "/*")
end script

script helpTask
	property parent : Task(me)
	property name : "help"
	property description : "Show this help and exit."
	property printSuccess : false
	repeat with t in my tasks
		echo(bb(my white) & t's name & my reset & tab & tab & t's description)
	end repeat
end script

script install
	property parent : Task(me)
	property dir : POSIX path of Â
		((path to library folder from user domain) as text) & "Script Libraries"
	property description : "Install ASUnit in" & space & dir & "."
	run asunit
	mkdir(dir)
	cp("ASUnit.scpt", dir)
	ohai("ASUnit installed in" & space & (dir as text))
end script

script test
	property parent : Task(me)
	property description : "Run tests."
	property printSuccess : false
	run script "Test ASUnit.applescript"
end script

script versionTask
	property parent : Task(me)
	property name : "version"
	property description : "Print ASUnit's version and exit."
	property printSuccess : false
	set workDir to (folder of file (path to me) of application "Finder") as text
	set {n, v} to {name, version} of Â
		(run script (workDir & "ASUnit.applescript") as alias)
	ohai(n & space & "v" & v)
end script
