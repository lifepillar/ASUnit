script OuterTestSuite
	
	|@Test|(S1, "This is test S1")
	script S1
		log "S1"
		should(true)
	end script
	
	|@TestSet|(UserTestSuite, "This is UserTestSuite")
	script UserTestSuite
		
		|@Test|(W1, "This is test W1")
		script W1
			log "W1"
			should(false)
		end script
		
		|@TestSet|(UserTestCase, "This is UserTestCase")
		script UserTestCase
			property x : missing value
			
			on setUp()
				set x to 3
			end setUp
			
			|@Test|(T1, "And this is test T1")
			script T1
				log "T1"
				should(x = 3)
			end script
			
			|@Test|(T2, "This is test T2")
			script T2
				log "T2"
				should(true)
			end script
		end script
		
		|@TestSet|(UserTestCaseBis, "This is UserTestCaseBis")
		script UserTestCaseBis
			
			|@Test|(T3, "This is the description of test T3")
			script T3
				log "T3"
				should(1 + 1 = 2)
			end script
			
			|@Test|(T4, "Finally, test T4!")
			script T4
				log "T4"
				should(true)
			end script
		end script
		
	end script -- UserTestSuite
end script

-------------------------------------------------
set MiniTest to MiniTest of (run script file Â
	((folder of file (path to me) of application "Finder" as text) & "ASUnit.applescript"))
MiniTest's autorun(OuterTestSuite)

