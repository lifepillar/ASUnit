(*!
	@header
	@abstract
		Template test loader.
	@discussion
		Loads all the compiled test scripts in the current folder.
	@charset macintosh
*)
property parent : ASUnit of Â
	(load script file (((path to library folder from user domain) as text) Â
		& "Script Libraries:ASUnit.scpt"))

set pwd to (the folder of file (path to me) of application "Finder")
set suite to makeTestLoader()'s loadTestsFromFolder(pwd)
autorun(suite)
