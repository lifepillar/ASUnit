property parent : load script (((path to library folder from user domain) as text) ¬
	& "Script Libraries:ASUnit.scpt") as alias

global HexString
property suite : makeTestSuite("Tests for HexString")
return autorun(suite)

-- Tests

script |Load script|
	property parent : TestSet(me)
	
	script |Loading the script|
		property parent : UnitTest(me)
		set HexString to run script ((folder of file (path to me) of application "Finder" as text) ¬
			& "HexString.applescript") as alias
		assertInstanceOf(script, HexString)
	end script
end script

script |Conversions to UTF8|
	property parent : TestSet(me)
	property x : missing value -- To store a hex string
	
	on setUp()
		set x to missing value -- Make sure x does not retain a value from a previous test
	end setUp
	
	script |Hex string should be 'abcde'|
		property parent : UnitTest(me)
		set x to HexString's new("6162636465")
		assertEqual("abcde", x's toUTF8())
	end script
	
	script |Hex string should be 'àèìòù'|
		property parent : UnitTest(me)
		set x to HexString's new("C3A0C3A8C3ACC3B2C3B9")
		assertEqual("àèìòù", x's toUTF8())
	end script
	
end script -- Test Set

script |Conversion to decimal|
	property parent : TestSet(me)
	property x : missing value -- To store a hex string
	
	on setUp()
		set x to missing value
	end setUp
	
	script |Class of toDec()'s result|
		property parent : UnitTest(me)
		set x to HexString's new("0")
		assertInstanceOf(integer, x's toDec())
	end script
	
	script |Convert zero|
		property parent : UnitTest(me)
		set x to HexString's new("0000")
		assertEqual(0, x's toDec())
	end script
	
	script |Convert one thousand (will fail)|
		property parent : UnitTest(me)
		set x to HexString's new("03E8")
		assertEqual(1000, x's toDec())
	end script
	
end script -- Test Set
