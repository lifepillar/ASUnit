#!/usr/bin/osascript
use AppleScript version "2.4"
use scripting additions
use ASMake : script "com.lifepillar/ASMake" version "0.2.2"
property parent : ASMake
property TopLevel : me

on run argv
	continue run argv
end run

------------------------------------------------------------------
-- Tasks
------------------------------------------------------------------

script api
	property parent : Task(me)
	property description : "Build the API documentation"
	property dir : "Documentation"
	
	ohai("Running HeaderDoc, please wait...")
	--Set LANG to get rid of warnings about missing default encoding
	shell for "env LANG=en_US.UTF-8 headerdoc2html" given options:{"-q", "-o", dir, "ASUnit.applescript"}
	shell for "env LANG=en_US.UTF-8 gatherheaderdoc" given options:dir
end script


script BuildASUnit
	property parent : Task(me)
	property name : "asunit"
	property description : "Build ASUnit"
	
	ohai("Creating script bundle...")
	makeScriptBundle from "ASUnit.applescript" at "build" with overwriting given encoding: my NSMacOSRomanStringEncoding
end script

script build
	property parent : Task(me)
	property description : "Build all source AppleScript scripts"
	
	tell BuildASUnit to exec:{}
	osacompile(glob({"examples/*.applescript", "templates/*.applescript"}), "scpt", {"-x"})
end script

script clean
	property parent : Task(me)
	property description : "Remove any temporary products"
	
	removeItems at {"build"} & glob({"**/*.scpt", "**/*.scptd", "tmp"}) with forcing
end script

script clobber
	property parent : Task(me)
	property description : "Remove any generated file"
	
	tell clean to exec:{}
	removeItems at glob({"ASUnit-*", "*.tar.gz", "*.html"}) with forcing
end script

script doc
	property parent : Task(me)
	property description : "Build an HTML version of the old manual and the README"
	property markdown : missing value
	
	set markdown to which("markdown")
	if markdown is missing value then set markdown to which("pandoc")
	if markdown is not missing value then
		shell for markdown given options:{"-o", "OldManual.html", "OldManual.md"}
		shell for markdown given options:{"-o", "README.html", "README.md"}
	else
		owarn("Skipping conversion from Markdown to HTML (no conversion tool found in $PATH).")
	end if
end script

script dist
	property parent : Task(me)
	property description : "Prepare a directory for distribution"
	property dir : missing value
	
	tell clobber to exec:{}
	tell BuildASUnit to exec:{}
	tell api to exec:{}
	tell doc to exec:{}
	
	set {n, v} to {name, version} of �
		(run script POSIX file (joinPath(workingDirectory(), "ASUnit.applescript")))
	set dir to n & "-" & v
	makePath(dir)
	copyItems at {"build/ASUnit.scptd", "COPYING", "Documentation", "examples", "templates"} into dir
	if pathExists("OldManual.html") and pathExists("README.html") then
		copyItems at {"OldManual.html", "README.html"} into dir
	end if
	copyItems at {"OldManual.md", "README.md"} into dir
end script

script gzip
	property parent : Task(me)
	property description : "Build a compressed archive for distribution"
	
	tell dist to exec:{}
	do shell script "tar czf " & quoted form of (dist's dir & ".tar.gz") & space & quoted form of dist's dir & "/*"
end script

script install
	property parent : Task(me)
	property dir : POSIX path of �
		((path to library folder from user domain) as text) & "Script Libraries"
	property description : "Install ASUnit in" & space & dir
	
	tell BuildASUnit to exec:{}
	set targetDir to joinPath(dir, "com.lifepillar")
	set targetPath to joinPath(targetDir, "ASUnit.scptd")
	if pathExists(targetPath) then
		display alert �
			"A version of ASUnit is already installed." message targetPath & space & �
			"exists. Overwrite?" as warning �
			buttons {"Cancel", "OK"} �
			default button "Cancel" cancel button "Cancel"
	end if
	
	copyItem at "build/ASUnit.scptd" into targetDir with overwriting
	ohai("ASUnit installed at" & space & targetPath)
end script

script BuildTests
	property parent : Task(me)
	property name : "test/build"
	property description : "Build tests, but do not run them"
	property dir : POSIX path of �
		((path to library folder from user domain) as text) & "Script Libraries"
	
	set targetDir to joinPath(dir, "com.lifepillar")
	set targetPath to joinPath(targetDir, "ASUnit.scptd")
	if not pathExists(targetPath) then
		owarn("Due to bugs in OS X Yosemite, building tests requires ASUnit to be installed.")
		tell install to exec:{}
	end if
	makeScriptBundle from "test/Test ASUnit.applescript" at "test" with overwriting
end script

script RunTests
	property parent : Task(me)
	property name : "test/run"
	property description : "Build and run tests"
	property printSuccess : false
	
	tell BuildTests to exec:{}
	-- The following causes a segmentation fault unless ASUnit in installed in a shared location
	set testSuite to load script POSIX file (joinPath(workingDirectory(), "test/Test ASUnit.scptd"))
	run testSuite
end script

script uninstall
	property parent : Task(me)
	property dir : POSIX path of �
		((path to library folder from user domain) as text) & "Script Libraries"
	property description : "Remove ASUnit from" & space & dir
	
	set targetPath to joinPath(dir, "com.lifepillar/ASUnit.scptd")
	if pathExists(targetPath) then
		removeItem at targetPath
	end if
	ohai(targetPath & space & "deleted.")
end script

script VersionTask
	property parent : Task(me)
	property name : "version"
	property description : "Print ASUnit's version and exit"
	property printSuccess : false
	
	set {n, v} to {name, version} of �
		(run script POSIX file (joinPath(workingDirectory(), "ASUnit.applescript")))
	ohai(n & space & "v" & v)
end script
