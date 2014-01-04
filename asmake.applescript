property name : missing value
property version : missing value
property fullname : missing value
property workDir : missing value
property tasks : {}
property docDir : "Documentation"
property TopLevel : me


script Stdout
	property parent : AppleScript
	property esc : "\\033["
	property boldBlue : esc & "1;34m"
	property boldGreen : esc & "1;92m"
	property boldPurple : esc & "1;35m"
	property boldRed : esc & "1;31m"
	property boldYellow : esc & "1;33m"
	property boldWhite : esc & "1;39m"
	property blue : esc & "0;34m"
	property green : esc & "0;92m"
	property purple : esc & "0;35m"
	property red : esc & "0;31m"
	property yellow : esc & "0;33m"
	property white : esc & "0;39m"
	property reset : esc & "0m"
	
	on col(msg, kolor)
		set msg to kolor & msg & reset
	end col
	
	on echo(msg)
		set msg to do shell script "echo " & quoted form of msg without altering line endings
		log text 1 thru -2 of msg -- Remove last linefeed
	end echo
	
	on ohai(msg)
		echo(green & "==>" & space & boldWhite & msg & reset)
	end ohai
	
	on ofail(msg, info)
		echo(red & "Fail: " & boldWhite & msg & reset & linefeed & info)
	end ofail
	
	on owarn(msg)
		echo(red & "Warn: " & boldWhite & msg & reset)
	end owarn
	
end script


-- Registers a task.
on Task(t)
	set the end of tasks to t
	script BaseTask
		property parent : Stdout
		property class : "Task"
		
		on cp(src, dst) -- src can be a list of POSIX paths
			local cmd
			if src's class is text then
				set src to {src}
			end if
			set cmd to "cp -r"
			repeat with s in src
				set cmd to cmd & space & quoted form of s & space
			end repeat
			sh(cmd & space & quoted form of dst)
		end cp
		
		on mkdir(dirname)
			sh("mkdir -p" & space & quoted form of dirname)
		end mkdir
		
		on osacompile(src)
			if src's class is text then
				set src to {src}
			end if
			repeat with s in src
				sh("osacompile -x -o" & space & Â
					quoted form of (s & ".scpt") & space & Â
					quoted form of (s & ".applescript"))
			end repeat
		end osacompile
		
		on rm(patterns)
			if patterns's class is text then
				set patterns to {patterns}
			end if
			set cmd to ""
			repeat with p in patterns
				set cmd to cmd & "rm -fr" & space & p & ";" & space
			end repeat
			sh(cmd)
		end rm
		
		on sh(command)
			Stdout's echo(command)
			-- Execute command in working directory
			set command to Â
				"cd" & space & quoted form of POSIX path of workDir & ";" & space & command
			set output to (do shell script command & space & "2>&1")
			if output is not equal to "" then echo(output)
		end sh
		
		on which(command)
			try
				do shell script "which" & space & command
				true
			on error
				ofail(command & space & "not found in" & space & (do shell script "echo $PATH"), "")
				false
			end try
		end which
	end script
	
	return BaseTask
end Task

------------------------------------------------------------------
-- Tasks
------------------------------------------------------------------

script api
	property parent : Task(me)
	property description : "Build the API documentation."
	
	owarn("HeaderDoc's support for AppleScript is definitely broken as of v8.9 (Xcode 5.0)")
	--Set LANG to get rid of warnings about missing default encoding
	sh("env LANG=en_US.UTF-8 headerdoc2html -q -o" & space & docDir & space & "ASUnit.applescript")
	sh("env LANG=en_US.UTF-8 gatherheaderdoc" & space & docDir)
	sh("open " & docDir & "/ASUnit_applescript/index.html")
end script

script asunit
	property parent : Task(me)
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
	rm({docDir, "ASUnit-*", "*.tar.gz", "*.html"})
end script

script doc
	property parent : Task(me)
	property description : "Build an HTML version of the old manual and the README."
	
	if which("markdow") then
		sh("markdown OldManual.md >OldManual.html")
		sh("markdown README.md >README.html")
	end if
end script

script dist
	property parent : Task(me)
	property description : "Prepare a directory for distribution."
	property dir : missing value
	try
		run clobber
		run asunit
		run doc
	on error errMsg number errNum
		log errMsg
		return errNum
	end try
	set dir to "ASUnit-" & TopLevel's version
	mkdir(dir)
	cp({"ASUnit.scpt", "COPYING", "OldManual.html", "README.html", "examples", "templates"}, dir)
end script

script gzip
	property parent : Task(me)
	property description : "Build a compressed archive for distribution."
	try
		run dist
		sh("tar czf" & space & dist's dir & ".tar.gz" & space & dist's dir & "/*")
	on error errMsg number errNum
		log errMsg
		return errNum
	end try
end script

script showHelp
	property parent : Task(me)
	property name : "help"
	property description : "Show this help and exit."
	
	repeat with t in tasks
		echo(my boldWhite & t's name & my reset & tab & tab & t's description)
	end repeat
end script

script install
	property parent : Task(me)
	property dir : POSIX path of Â
		((path to library folder from user domain) as text) & "Script Libraries"
	property description : "Install ASUnit in" & space & dir & "."
	try
		run asunit
		mkdir(dir)
		cp("ASUnit.scpt", dir)
		ohai(TopLevel's fullname & space & "installed in" & space & (dir as text))
	on error errMsg
		ofail("Could not install ASUnit", errMsg)
	end try
end script

script test
	property parent : Task(me)
	property description : "Run tests."
	run script "Test ASUnit.applescript"
end script

script showVersion
	property parent : Task(me)
	property name : "version"
	property description : "Print ASUnit's version and exit."
	ohai(TopLevel's fullname)
end script


------------------------------------------------------------------
-- End of tasks
------------------------------------------------------------------

on run {action}
	set workDir to (folder of file (path to me) of application "Finder") as text
	set {name, version} to {name, version} of (run script (workDir & "ASUnit.applescript") as alias)
	set fullname to name & space & "v" & version
	
	try
		set t to getTask(action)
	on error errMsg
		Stdout's ofail("Unknown task: " & action, errMsg)
		return
	end try
	try
		run t
	on error errMsg
		Stdout's ofail("Task failed", errMsg)
	end try
end run

on getTask(action)
	repeat with t in (a reference to tasks)
		if t's name = action then return t
	end repeat
	error
end getTask
