-- Start ASMake library

script Stdout
	property parent : AppleScript
	property esc : "\\033["
	property black : esc & "0;30m"
	property blue : esc & "0;34m"
	property cyan : esc & "0;36m"
	property green : esc & "0;32m"
	property magenta : esc & "0;35m"
	property purple : esc & "0;35m"
	property red : esc & "0;31m"
	property yellow : esc & "0;33m"
	property white : esc & "0;37m"
	property reset : esc & "0m"
	
	on col(s, kolor)
		set s to kolor & s & reset
	end col
	
	-- Make color bold
	on bb(kolor)
		esc & "1;" & text -3 thru -1 of kolor
	end bb
	
	on echo(msg)
		set msg to do shell script "echo " & quoted form of msg without altering line endings
		log text 1 thru -2 of msg -- Remove last linefeed
	end echo
	
	on ohai(msg)
		echo(green & "==>" & space & bb(white) & msg & reset)
	end ohai
	
	on ofail(msg, info)
		set msg to red & "Fail:" & space & bb(white) & msg & reset
		if info is not "" then set msg to msg & linefeed & info
		echo(msg)
	end ofail
	
	on owarn(msg)
		echo(red & "Warn:" & space & bb(white) & msg & reset)
	end owarn
	
end script -- Stdout

script ASMake
	property parent : Stdout
	property tasks : {}
	property pwd : missing value
	
	on parseTask(action)
		repeat with t in (a reference to tasks)
			if t's name = action then return t
		end repeat
		error
	end parseTask
	
	on runTask(action)
		set pwd to do shell script "pwd"
		try
			set t to parseTask(action)
		on error errMsg number errNum
			ofail("Unknown task: " & action, "")
			error errMsg number errNum
		end try
		try
			run t
			if t's name is not in {"help", "test", "version"} then ohai("Success!")
		on error errMsg number errNum
			ofail("Task failed", "")
			error errMsg number errNum
		end try
	end runTask
	
	-- Registers a task.
	on Task(t)
		set the end of my tasks to t
		
		script BaseTask
			property parent : ASMake
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
				local output
				echo(command)
				-- Execute command in working directory
				set command to Â
					"cd" & space & quoted form of pwd & ";" & space & command
				set output to (do shell script command & space & "2>&1")
				if output is not equal to "" then echo(output)
			end sh
			
			on which(command)
				try
					do shell script "which" & space & command
					true
				on error
					false
				end try
			end which
		end script
		
		return BaseTask
	end Task
	
end script -- ASMake

-- End ASMake library

-- Main
property parent : ASMake
property name : missing value
property version : missing value
property fullName : missing value
property TopLevel : me

on run {action}
	set workDir to (folder of file (path to me) of application "Finder") as text
	set {name, version} to {name, version} of Â
		(run script (workDir & "ASUnit.applescript") as alias)
	set fullName to name & space & "v" & version
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
	sh("env LANG=en_US.UTF-8 headerdoc2html -q -o" & space & dir & space & "ASUnit.applescript")
	sh("env LANG=en_US.UTF-8 gatherheaderdoc" & space & dir)
	sh("open " & dir & "/ASUnit_applescript/index.html")
end script

script asunit
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
	cp({"ASUnit.scpt", "COPYING", "OldManual.html", "README.html", "examples", "templates"}, dir)
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
	ohai(TopLevel's fullName & space & "installed in" & space & (dir as text))
end script

script test
	property parent : Task(me)
	property description : "Run tests."
	run script "Test ASUnit.applescript"
end script

script versionTask
	property parent : Task(me)
	property name : "version"
	property description : "Print ASUnit's version and exit."
	ohai(TopLevel's fullName)
end script
