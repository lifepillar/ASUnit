property version : missing value
property workDir : missing value
property tasks : {}
property docDir : "Documentation"
property topLevel : me

-- Registers a task.
on Task(t)
	set the end of tasks to t
	script BaseTask
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
				sh("osacompile -d -x -o" & space & Â
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
			log command
			-- Execute command in working directory
			set command to Â
				"cd" & space & quoted form of POSIX path of workDir & ";" & space & command
			set output to (do shell script command & space & "2>&1")
			if output is not equal to "" then log output
		end sh
		
		on which(command)
			try
				do shell script "which" & space & command
				true
			on error
				log command & space & "not found in" & space & (do shell script "echo $PATH")
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
	
	log "Warning: HeaderDoc's support for AppleScript is definitely broken as of v8.9 (Xcode 5.0)"
	--Set LANG to get rid of warnings about missing default encoding
	sh("env LANG=en_US.UTF-8 headerdoc2html -q -o" & space & docDir & space & "ASUnit.applescript")
	sh("env LANG=en_US.UTF-8 gatherheaderdoc" & space & docDir)
	sh("open " & docDir & "/ASUnit_applescript/index.html")
end script

script build
	property parent : Task(me)
	property description : "Build ASUnit."
	osacompile({"ASUnit", "Test ASUnit", "Test ASUnit MiniTest"})
end script

script clean
	property parent : Task(me)
	property description : "Remove any temporary products."
	rm({"*.scpt", "*.scptd"})
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
	
	if which("markdown") then
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
		run build
		run doc
	on error errMsg number errNum
		log errMsg
		return errNum
	end try
	set dir to "ASUnit-" & topLevel's version
	mkdir(dir)
	cp({"ASUnit.scpt", "COPYING", "OldManual.html", "README.html"}, dir)
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
		log (t's name) & tab & tab & (t's description)
	end repeat
end script

script install
	property parent : Task(me)
	property description : "Install ASUnit in ~/Library/Script Libraries."
	property dir : POSIX path of Â
		((path to library folder from user domain) as text) & "Script Libraries"
	try
		run script build
		cp("ASUnit.scpt", dir)
	on error errMsg
		log errMsg
	end try
end script

script test
	property parent : Task(me)
	property description : "Run tests."
	run script "Test ASUnit.applescript"
	run script "Test ASUnit MiniTest.applescript"
end script

script showVersion
	property parent : Task(me)
	property name : "version"
	property description : "Print ASUnit's version and exit."
	log "ASUnit" & space & topLevel's version
end script


------------------------------------------------------------------
-- End of tasks
------------------------------------------------------------------

on run {action}
	set workDir to (folder of file (path to me) of application "Finder") as text
	set version to version of (run script file (workDir & "ASUnit.applescript"))
	try
		set t to getTask(action)
	on error errMsg
		log "Unknown task: " & action
		log errMsg
		return
	end try
	try
		run t
	on error errMsg
		log "Task failed:" & space & errMsg
	end try
end run

on getTask(action)
	repeat with t in (a reference to tasks)
		if t's name = action then return t
	end repeat
	error
end getTask
