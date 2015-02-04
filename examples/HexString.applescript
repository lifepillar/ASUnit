-- Creates an object that represents a hexadecimal value.
-- hexValue is a hexadecimal string.
on new(hexValue)
	script
		property value : hexValue
		
		-- Interprets this hexadecimal value as a UTF8-encoded string.
		on toUTF8()
			run script "Çdata utf8" & value & "È as text"
		end toUTF8
		
		-- Interprets this hexadecimal value as an integer.
		on toDec()
			(run script "Çdata long" & reversebytes() & "È as text") as integer
		end toDec
		
		on reversebytes()
			value -- wrong implementation
		end reversebytes
		
	end script
end new

on run
	return me
end run
