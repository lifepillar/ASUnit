(*!
	@header
	@abstract
		Template test loader.
	@discussion
		Runs all the test scripts in the current folder.
	@charset macintosh
*)
property parent : script "com.lifepillar/ASUnit"

set pwd to (the folder of file (path to me) of application "Finder")
set suite to makeTestLoader()'s loadTestsFromFolder(pwd)
autorun(suite)
