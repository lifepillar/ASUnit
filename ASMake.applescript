(*!
 @header ASMake
 	A simple AppleScript build library with capabilities similar to rake.
 @abstract A draft of a primitive replacement for rake, make, etcÉ, in pure AppleScript.
 @author Lifepillar
 @copyright 2014 Lifepillar
 @version 0.0.0
 @charset macintosh
*)

on run
	return me
end run

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

property parent : Stdout
property tasks : {}
property pwd : missing value
property private : false -- Is this task an implementation detail?
property printSuccess : true -- Print "==> Success!" when a task finishes?

on parseTask(action)
	repeat with t in (a reference to my tasks)
		if t's name = action then return t
	end repeat
	error
end parseTask

on runTask(action)
	set my pwd to do shell script "pwd"
	try
		set t to parseTask(action)
	on error errMsg number errNum
		ofail("Unknown task: " & action, "")
		error errMsg number errNum
	end try
	try
		run t
		if t's printSuccess then ohai("Success!")
	on error errMsg number errNum
		ofail("Task failed", "")
		error errMsg number errNum
	end try
end runTask

on Task(t)
	if not t's private then set the end of my tasks to t -- Register task
	
	script BaseTask
		-- Inherits from top level script
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
				"cd" & space & quoted form of my pwd & ";" & space & command
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
