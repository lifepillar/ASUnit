(*!
	@header
	@abstract
		AppleScript's Variable Types and You: What you don't know about AppleScript's variable types can hurt you (or slow down your scripts!)

		See also:
		http://www.mactech.com/articles/mactech/Vol.22/22.03/AdvAppleScript/index.html
		http://macscripter.net/viewtopic.php?id=41680

	@discussion
		This is an ASUnit implementation of the tests from the MacTech article mentioned above (benchmarks excluded). All the tests have been designed by the author's article Ryan Wilcox: I have just copied them into an ASUnit test set, with minor modifications.

	@charset macintosh
*)
---------------------------------------------------------------------------------------
property suitename : "AppleScript's Variable Types and You"
---------------------------------------------------------------------------------------
property parent : load script (((path to library folder from user domain) as text) Â
	& "Script Libraries:ASUnit.scpt") as alias
(* For OS X 10.9 or later you may use the following instead:
use AppleScript
use scripting additions
property parent : script "ASUnit"
*)
property TopLevel : me
property suite : makeTestSuite(suitename)

autorun(suite)

script test
	property parent : TestSet(me)
	
	script xAnYScalars
		property parent : UnitTest(me)
		set x to true
		set y to x
		set y to false
		ok(x)
		notOk(y)
	end script
	
	script xAndYList
		property parent : UnitTest(me)
		set x to {true}
		set y to x
		set item 1 of y to false
		assertEqual({false}, x)
		assertEqual({false}, y)
	end script
	
	script xAndYListCopy
		property parent : UnitTest(me)
		set x to true
		copy x to y
		set y to false
		ok(x)
		notOk(y)
	end script
	
	script copyWithLists
		property parent : UnitTest(me)
		set x to {true}
		copy x to y -- y to x
		set item 1 of y to false
		assertEqual({true}, x)
		assertEqual({false}, y)
	end script
	
	script changeDataReferenced
		property parent : UnitTest(me)
		set a to {1}
		set b to {a}
		set item 1 of item 1 of b to 42
		assertEqual({{42}}, b)
		assertEqual({42}, a)
	end script
	
	script changeReference
		property parent : UnitTest(me)
		set a to {1}
		set b to {a}
		set item 1 of b to 42
		assertEqual({42}, b)
		assertEqual({1}, a)
	end script
	
	script setEndOfSharedData
		property parent : UnitTest(me)
		set a to {1}
		set b to a
		set end of b to 45
		assertEqual({1, 45}, a)
		assertEqual({1, 45}, b)
	end script
	
	script addToOneNotShared
		property parent : UnitTest(me)
		set a to {1}
		set b to a
		set b to a & {45}
		assertEqual({1}, a)
		assertEqual({1, 45}, b)
	end script
	
	script changeScalarListContents
		property parent : UnitTest(me)
		set myList to {}
		set myItem to 1
		repeat with i from 1 to 5
			copy myList & myItem to myList
			set myItem to 2
		end repeat
		assertEqual({1, 2, 2, 2, 2}, myList)
	end script
	
	script twiddleScalarListContents
		property parent : UnitTest(me)
		set myList to {}
		set myItem to 1
		repeat with i from 1 to 5
			copy myList to myVar
			if i = 2 then
				set item 1 of myList to 5
				--but won't be at the end because we have a copy which gets thrown away when this loop ends
			end if
			set myList to myVar & myItem
			set myItem to 2
		end repeat
		assertEqual({1, 2, 2, 2, 2}, myList)
	end script
	
	script changeListCopyListContents
		property parent : UnitTest(me)
		set myList to {}
		set myItem to {1}
		repeat with i from 1 to 5
			copy myList & myItem to myList
			set item 1 of myItem to 2
		end repeat
		assertEqual({1, 2, 2, 2, 2}, myList)
	end script
	
	script changeListContentsList
		property parent : UnitTest(me)
		set myList to {}
		set myItem to {1}
		repeat with i from 1 to 5
			set myList to (contents of myList) & myItem
			set item 1 of myItem to 2
		end repeat
		assertEqual({2, 2, 2, 2, 2}, myList)
	end script
	
	script changeListContentsListContents
		property parent : UnitTest(me)
		set myList to {}
		set myItem to {1}
		repeat with i from 1 to 5
			set myList to (contents of myList) & (contents of myItem)
			set item 1 of myItem to 2
		end repeat
		assertEqual({1, 2, 2, 2, 2}, myList)
	end script
	
	script changeScalarListAndScalar
		property parent : UnitTest(me)
		set myList to {}
		set myItem to 123
		repeat with i from 1 to 5
			copy myList & myItem to myList
			set myItem to 124
		end repeat
		assertEqual({123, 124, 124, 124, 124}, myList)
	end script
	
	script |changeListItemListAndList (will fail)|
		property parent : UnitTest(me)
		set myList to {}
		set myItem to {1}
		set biggerList to false
		repeat with i from 1 to 5
			set myList to myList & myItem
			if not biggerList then --only do it once
				set end of myItem to {2}
				set biggerList to true
			end if
		end repeat
		assertEqual({1, 2, 1, 2, 1, 2, 1, 2, 1, 2}, myList)
	end script
	
	script twiddleListItemListAndList
		property parent : UnitTest(me)
		set myList to {}
		set myItem to {1}
		repeat with i from 1 to 5
			set referTo to myList
			if i = 2 then
				set item 1 of myList to 234
				--change the shared data
			end if
			set myList to referTo & myItem
		end repeat
		assertEqual({234, 234, 234, 234, 234}, myList)
	end script
	
	script twiddleReferenceItem
		property parent : UnitTest(me)
		set myList to {}
		set shallowCopy to missing value
		repeat with i from 1 to 5
			set end of myList to i
		end repeat
		set shallowCopy to myList
		set item 4 of shallowCopy to 42
		assertEqual({1, 2, 3, 42, 5}, myList)
		assertEqual({1, 2, 3, 42, 5}, shallowCopy)
	end script
	
	script twiddleCopyListItemList
		set a to 1
		set myList to {{a}, {a}, {a}, {a}, {a}}
		copy myList to deepCopy
		set shallowCopy to items of myList
		set item 1 of item 4 of deepCopy to 42 -- not reflected
		set item 1 of item 5 of myList to 23 -- reflected
		assertEqual({{1}, {1}, {1}, {1}, {23}}, myList)
		assertEqual({{1}, {1}, {1}, {42}, {1}}, deepCopy)
		assertEqual({{1}, {1}, {1}, {1}, {23}}, shallowCopy)
	end script
	
	script twiddleListsWithThreeLists
		property parent : UnitTest(me)
		set myList to {}
		set L1 to {1}
		set L2 to myList & L1
		set item 1 of L2 to 234
		assertEqual({234}, L1)
	end script
	
	script changeListListAndList
		property parent : UnitTest(me)
		set myList to {}
		set myItem to {1}
		repeat with i from 1 to 5
			set myList to myList & myItem
			set myItem to {1, 2}
		end repeat
		assertEqual({1, 1, 2, 1, 2, 1, 2, 1, 2}, myList)
	end script
	
	script setListToListAndContainerListItemAppend
		property parent : UnitTest(me)
		set a to {1, 3}
		set b to {2}
		set b to a & b
		assertEqual({1, 3, 2}, b)
	end script
	
	script testSimpleEndOfWorksScalar
		property parent : UnitTest(me)
		set a to 2
		set b to {1}
		set end of b to a
		assertEqual({1, 2}, b)
	end script
	
	script setEndOfWithContainerContainerAppend
		property parent : UnitTest(me)
		set a to {2}
		set b to {1}
		set end of b to a
		assertEqual({1, {2}}, b)
	end script
	
	script changeScalarListEndOfList
		property parent : UnitTest(me)
		set myList to {}
		set myItem to 1
		repeat with i from 1 to 5
			set myList to myList & myItem
			set myItem to 2
		end repeat
		assertEqual({1, 2, 2, 2, 2}, myList)
	end script
	
	script changeListListEndOfList
		property parent : UnitTest(me)
		set myList to {}
		set myItem to {1, 2}
		repeat with i from 1 to 5
			set end of myList to myItem
			set item 2 of myItem to 3
		end repeat
		assertEqual({{1, 3}, {1, 3}, {1, 3}, {1, 3}, {1, 3}}, myList)
	end script
	
	script changeScalarEndOfList
		property parent : UnitTest(me)
		set myItem to 1
		set myList to {}
		set end of myList to myItem
		set myItem to 45
		--set myItem to {46}
		set theIt to item 1 of myList
		assertEqual(1, theIt)
		assertEqual(45, myItem)
	end script
	
	script testFirstOfReassignRefItem
		property parent : UnitTest(me)
		set a to 1
		set myList to {a, 2, 3, 4, 5, 6}
		set first item of myList to 42
		--get end of myList
		assertEqual(1, a)
		assertEqual({42, 2, 3, 4, 5, 6}, myList)
	end script
	
	script deepCopyChangeOne
		property parent : UnitTest(me)
		set a to {1}
		set b to {2}
		set myList to {a, b}
		copy myList to deepCopy -- deepCopy contains new list with duplicate contents
		set item 1 of a to 42
		assertEqual({{42}, {2}}, myList)
		assertEqual({42}, a)
		assertEqual({{1}, {2}}, deepCopy)
	end script
	
	script shallowCopyChangeOne
		property parent : UnitTest(me)
		set a to {1}
		set b to {2}
		set myList to {a, b}
		set shallowCopy to items of myList
		set item 1 of myList to 0
		assertEqual({0, {2}}, myList)
		assertEqual({1}, a)
		assertEqual({{1}, {2}}, shallowCopy)
	end script
	
	script shallowCopyChangeSharedValue
		property parent : UnitTest(me)
		set a to {1}
		set b to {2}
		set myList to {a, b}
		set shallowCopy to items of myList
		copy myList to deepCopy
		set item 1 of item 1 of myList to 0
		assertEqual({{0}, {2}}, myList)
		assertEqual({{0}, {2}}, shallowCopy)
		assertEqual({{1}, {2}}, deepCopy)
	end script
	
	script shallowCopyChangeScalarValue
		property parent : UnitTest(me)
		set a to 42
		set myList to {a}
		set myShallowCopy to items of myList
		set item 1 of myList to 45
		assertEqual({45}, myList)
		assertEqual({42}, myShallowCopy)
		assertEqual(42, a)
	end script
	
	script changeValueOfParameterScalarList
		property parent : UnitTest(me)
		
		to changeScalarInList(val)
			set item 1 of val to 67
			--just changing the reference
		end changeScalarInList
		
		set ftwo to 42
		set myParam to {ftwo}
		changeScalarInList(myParam)
		assertEqual(42, ftwo)
		assertEqual({67}, myParam)
		--the value stays the same, but myParam has a diferent reference in it
	end script
	
	script changeValueOfParameterListList
		property parent : UnitTest(me)
		
		to changeList(lst)
			set item 1 of item 1 of lst to 67
			--change the value associated with the reference
		end changeList
		
		set ftwo to {42}
		set myParam to {ftwo}
		changeList(myParam)
		assertEqual({67}, ftwo)
		assertEqual({{67}}, myParam)
	end script
	
	script changeValueOfParameterScalar
		property parent : UnitTest(me)
		
		to changeScalar(val)
			set val to 124
		end changeScalar
		
		set ftwo to 42
		changeScalar(ftwo)
		assertEqual(42, ftwo)
	end script
	
	script changeAReferenceType
		property parent : UnitTest(me)
		property refProp : "world"
		set y to a reference to refProp
		set z to a reference to refProp
		set y to "hello"
		set contents of z to "foo"
		assertNotReference(y)
		assertReference(z)
		assertEqual("foo", refProp)
		assertEqual("hello", y)
		assertEqual("foo", contents of z)
	end script
	
	script testEmptyListsChangesContents
		property parent : UnitTest(me)
		--counterpoint to testContainerItemsShareScalars
		--and testNonEmptyListCorrectlyChangesContents
		--change item 1 of myList and see myItem change
		--one would have expected our changes to 
		--have simply changed what item 1 was sharing
		--(ala: figure 6 in Part 1), but instead it changes
		--the contents of the shared item (ala Figure 5 in Part 1)
		set emptyList to {}
		set myItem to {1}
		set myList to emptyList & myItem
		set item 1 of myList to 123
		set myList to myList & myItem
		assertEqual({123}, myItem)
		assertEqual({123, 123}, myList)
	end script
	
	script testEmptyListsChangesContentsChangesNotBack
		property parent : UnitTest(me)
		--same test as testEmptyListsChangesContents, but
		--but we change where item 1 of myItem points to, and we
		--don't see the change reflected in myList
		set emptyList to {}
		set myItem to {1}
		set myList to emptyList & myItem
		set item 1 of myList to 123
		set myList to myList & myItem
		set item 1 of myItem to 45
		assertEqual({45}, myItem)
		assertEqual({123, 123}, myList)
	end script
	
	script testNonEmptyListCorrectlyChangesContents
		property parent : UnitTest(me)
		--counterpoint to testEmptyListsIncorrectlyChangesContents
		--myItem changes because myList is just sharing the
		--myItem, and changes to one affect the other 
		set myItem to {1}
		set myList to myItem
		set item 1 of myList to 45 --directly changes myItem because myList shares all of it
		set myList to myList & myItem
		assertEqual({45, 45}, myList)
		assertEqual({45}, myItem)
	end script
	
	script testContainerItemsShareScalars
		property parent : UnitTest(me)
		set myItem to {1}
		set myList to myItem
		set myList to myList & myItem
		set item 1 of myItem to 45
		assertEqual(myList, {1, 1})
		assertEqual(myItem, {45})
		assertEqual(1, item 1 of myList)
	end script
	
	script testContainersShareScalars
		property parent : UnitTest(me)
		--counterpoint to testContainerItemsShareScalars
		--change myItem and see myList not change
		--except this time myItem is a container holding another
		--container (but it works just like testContainerItemsShareScalars
		set myItem to {{1}}
		set myList to myItem
		set myList to myList & myItem
		set item 1 of myItem to 45
		assertEqual({{1}, {1}}, myList)
		assertEqual({45}, myItem)
	end script
	
	script testContainerItemChangeReflectedInShared
		property parent : UnitTest(me)
		--counterpoint to testContainerItemsShareScalars()
		--45 should get reflected in myList because we are
		--changing the contents of it
		set myItem to {{1}}
		set myList to myItem
		set myList to myList & myItem
		set item 1 of item 1 of myItem to 45
		assertEqual({{45}}, myItem)
		assertEqual({{45}, {45}}, myList)
	end script
	
	script appendTwoItemsUsingEndOf
		property parent : UnitTest(me)
		set a to {1}
		set end of a to {3, 2}
		assertEqual({1, {3, 2}}, a)
	end script
	
	(* This causes a stack overflow and crashes AppleScript Editor.
	script simpleAddSelfToEndOfSelfErr
		property parent : UnitTest(me)
		script LogErr
			set a to {1}
			set end of a to {a, 2}
			log a
		end script
		shouldntRaise({}, LogErr, "")
	end script
	*)
	
	script |AppleScript: The Definitive Guide, ¤11.5|
		property parent : UnitTest(me)
		script RefError
			set x to true
			set y to a reference to x
			set the contents of y to false -- AS runtime error
		end script
		-- AS Editor and osascript raise different exceptions!
		shouldRaise({-1700, -10006}, RefError, Â
			"Should have raised: Can't make 'x' into type reference or Can't set x to false.")
	end script
	
end script -- Test Set
