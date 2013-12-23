#! /usr/bin/env lua
-- Provide a subset of vim keybindings.
--
-- v0.1
-- v0.2 - added commands: fF^$
-- (c) 2013 by Carl Antuar.
-- Distribution is permitted under the terms of the GPLv3
-- or any later version.

---- Define constants
debugEnabled = false
keyGroups = { ["nav"]="hjklwe", ["lower"]="abcdefghijklmnopqrstuvwxyz", ["upper"]="ABCDEFGHIJKLMNOPQRSTUVWXYZ", ["whitespace"]=" \t\n\r" }
symbolKeys = {
 ["numbersign"]="#",
 ["slash"]="/",
 ["exclam"]="!",
 ["backslash"]="\\",
 ["at"]="@",
 ["dollar"]="$",
 ["percent"]="%",
 ["asciicircum"]="^",
 ["ampersand"]="&",
 ["asterisk"]="*",
 ["parenleft"]="(",
 ["parenright"]=")",
 ["minus"]="-",
 ["underscore"]="_",
 ["equal"]="=",
 ["plus"]="+",
 ["bar"]="|",
 ["colon"]=":",
 ["semicolon"]=";",
 ["comma"]=",",
 ["period"]=".",
 ["question"]="?",
 ["less"]="<",
 ["greater"]=">",
 ["apostrophe"]="'",
 ["quotedbl"]="\"",
 ["bracketleft"]="[",
 ["bracketright"]="]",
 ["braceleft"]="{",
 ["braceright"]="}",
 ["grave"]="`",
 ["asciitilde"]="~"
}

---- Define functions ----

function atDocumentEdge()
	return geany.caret() == 1 or geany.caret() == geany.length()
end

function isLowerCase(charCode)
	return string.find(keyGroups["lower"], string.char(charCode), 1, true)
end

function isUpperCase(charCode)
	return string.find(keyGroups["upper"], string.char(charCode), 1, true)
end

function isWhitespace(charCode)
	return string.find(keyGroups["whitespace"], string.char(charCode), 1, true)
end

function debugMessage(message)
	if debugEnabled then geany.message("DEBUG", message) end
end

local function getCharWithRepeats(prompt)
	local n = 0
	local char = geany.keygrab(prompt)
	while string.match(char, "^[0-9]$") do
		if n == 0 then n = tonumber(char)
		else n = (n * 10) + tonumber(char)
		end
		char = geany.keygrab(prompt..n)
	end
	if n == 0 then n = 1 end
	return n,char
end

-- Navigating by word parts almost matches Vim word navigation, except:
-- - if the cursor starts on whitespace, it goes to the closer end of the next word, not the further end
-- - if a word is camel-cased, it steps through each segment.
local function navWordEndRight(extend)
	if extend then geany.select() end
	debugMessage("Character at caret is "..geany.byte().." ["..string.char(geany.byte()).."]")
	repeat
		geany.navigate("part", 1, extend)
		local charCode, previousCharCode = geany.byte(), geany.byte(geany.caret() - 1)
		debugMessage("Current char is "..charCode.." ["..string.char(charCode).."]")
		debugMessage("Previous char is "..previousCharCode.." ["..string.char(previousCharCode).."]")
	until not isWhitespace(previousCharCode) and not (isUpperCase(charCode) and isLowerCase(previousCharCode)) or atDocumentEdge()
end

local function navWordEndLeft(extend)
	if extend then geany.select() end
	debugMessage("Character at caret is "..geany.byte().." ["..string.char(geany.byte()).."]")
	repeat
		geany.navigate("part", -1, extend)
		local charCode, previousCharCode = geany.byte(), geany.byte(geany.caret() - 1)
		debugMessage("Current char is "..charCode.." ["..string.char(charCode).."]")
		debugMessage("Previous char is "..previousCharCode.." ["..string.char(previousCharCode).."]")
	until not isWhitespace(previousCharCode) and not (isUpperCase(charCode) and isLowerCase(previousCharCode)) or atDocumentEdge()
end

local function navWordStartRight(extend)
	if extend then geany.select() end
	debugMessage("Character at caret is "..geany.byte().." ["..string.char(geany.byte()).."]")
	repeat
		geany.navigate("part", 1, extend)
		local charCode, previousCharCode = geany.byte(), geany.byte(geany.caret() - 1)
		debugMessage("Current char is "..charCode.." ["..string.char(charCode).."]")
		debugMessage("Previous char is "..previousCharCode.." ["..string.char(previousCharCode).."]")
	until not isWhitespace(charCode) and not (isUpperCase(charCode) and isLowerCase(previousCharCode)) or atDocumentEdge()
end

local function navWordStartLeft(extend)
	if extend then geany.select() end
	debugMessage("Character at caret is "..geany.byte().." ["..string.char(geany.byte()).."]")
	repeat
		geany.navigate("part", -1, extend)
		local charCode, previousCharCode = geany.byte(), geany.byte(geany.caret() - 1)
		debugMessage("Current char is "..charCode.." ["..string.char(charCode).."]")
		debugMessage("Previous char is "..previousCharCode.." ["..string.char(previousCharCode).."]")
	until not isWhitespace(charCode) and not (isUpperCase(charCode) and isLowerCase(previousCharCode)) or atDocumentEdge()
end

local function navWORDEndRight(extend)
	if extend then geany.select() end
	debugMessage("Character at caret is "..geany.byte().." ["..string.char(geany.byte()).."]")
	repeat
		geany.navigate("part", 1, extend)
		local charCode, previousCharCode = geany.byte(), geany.byte(geany.caret() - 1)
		debugMessage("Current char is "..charCode.." ["..string.char(charCode).."]")
		debugMessage("Previous char is "..previousCharCode.." ["..string.char(previousCharCode).."]")
	until isWhitespace(charCode) or atDocumentEdge()
end

local function navWORDEndLeft(extend)
	if extend then geany.select() end
	debugMessage("Character at caret is "..geany.byte().." ["..string.char(geany.byte()).."]")
	repeat
		geany.navigate("part", -1, extend)
		local charCode, previousCharCode = geany.byte(), geany.byte(geany.caret() - 1)
		debugMessage("Current char is "..charCode.." ["..string.char(charCode).."]")
		debugMessage("Previous char is "..previousCharCode.." ["..string.char(previousCharCode).."]")
	until isWhitespace(charCode) or atDocumentEdge()
end

local function navWORDStartRight(extend)
	if extend then geany.select() end
	debugMessage("Character at caret is "..geany.byte().." ["..string.char(geany.byte()).."]")
	repeat
		geany.navigate("part", 1, extend)
		local charCode, previousCharCode = geany.byte(), geany.byte(geany.caret() - 1)
		debugMessage("Current char is "..charCode.." ["..string.char(charCode).."]")
		debugMessage("Previous char is "..previousCharCode.." ["..string.char(previousCharCode).."]")
	until isWhitespace(previousCharCode) or atDocumentEdge()
end

local function navWORDStartLeft(extend)
	if extend then geany.select() end
	debugMessage("Character at caret is "..geany.byte().." ["..string.char(geany.byte()).."]")
	repeat
		geany.navigate("part", -1, extend)
		local charCode, previousCharCode = geany.byte(), geany.byte(geany.caret() - 1)
		debugMessage("Current char is "..charCode.." ["..string.char(charCode).."]")
		debugMessage("Previous char is "..previousCharCode.." ["..string.char(previousCharCode).."]")
	until isWhitespace(previousCharCode) or atDocumentEdge()
end

local function selectTextForCommand(n, char)
	debugMessage("Selecting text for "..n.." repetitions of "..char)
	geany.select()
	if char == "h" then
		geany.navigate("char", -1 * n, true)
	elseif char == "j" then
		geany.navigate("edge", -1)
		geany.navigate("line", n+1, true)
	elseif char == "k" then
		geany.navigate("edge", -1)
		geany.navigate("line", 1)
		geany.navigate("line", -1 * (n+1), true)
	elseif char == "l" then
		geany.navigate("char", n, true)
	end
end

---- Start execution ----
local prompt = "Please enter a vim command or Esc to exit.\nNB Typing slowly is recommended: "
geany.timeout(0)
while true do
	local n,char = getCharWithRepeats(prompt)
	debugMessage("Command was "..n..char)

	-- switching to edit mode (exiting script)
	if char == "Escape" then
		if geany.confirm("Escape", "Do you want to exit Vim mode?", true) then return end
	elseif char == "i" then return
	elseif char == "I" then
		geany.navigate("edge", -1)
		return
	elseif char == "a" then
		geany.navigate("char", 1)
		return
	elseif char == "A" then
		geany.navigate("edge", 1)
		return

	-- navigation
	elseif char == "h" then
		geany.navigate("char", -1 * n)
	elseif char == "j" then
		geany.navigate("line", n)
	elseif char == "k" then
		geany.navigate("line", -1 * n)
	elseif char == "l" then
		geany.navigate("char", n)
	elseif symbolKeys[char] == "^" then
		for i=2, n do
			geany.navigate("line", -1)
		end
		geany.navigate("edge", -1)
	elseif symbolKeys[char] == "$" then
		for i=2, n do
			geany.navigate("line", 1)
		end
		geany.navigate("edge", 1)
	elseif char == "e" then
		for i = 1, n do
			navWordEndRight(false)
		end
	elseif char == "E" then
		for i = 1, n do
			navWORDEndRight(false)
		end
	elseif char == "w" then
		for i = 1, n do
			navWordStartRight(false)
		end
	elseif char == "W" then
		for i = 1, n do
			navWORDStartRight(false)
		end
	elseif char == "b" then
		for i = 1, n do
			navWordStartLeft(false)
		end
	elseif char == "B" then
		for i = 1, n do
			navWORDStartLeft(false)
		end
	elseif char == "f" or char == "F" then
		searchChar = geany.keygrab("Please enter the character to find: ")
		-- translate descriptive character codes into symbols
		if symbolKeys[searchChar] then searchChar = symbolKeys[searchChar] end
		debugMessage("Search char is "..searchChar)
		if searchChar:len() == 1 then
			for i = 1, n do
				if char == "f" then
					local newIndex = geany.text():find(searchChar, geany.caret()+2, true)
					if newIndex then
						geany.caret(newIndex-1)
					else
						debugMessage("Could not find "..searchChar.." in document after position "..geany.caret())
					end
				else
					local newIndex = geany.text():reverse():find(searchChar, geany.length() - geany.caret() + 1, true)
					if newIndex then
						geany.caret(geany.length()-newIndex)
					else
						debugMessage("Could not find "..searchChar.." in document before position "..geany.caret())
					end
				end
				debugMessage("Caret is now at "..geany.caret())
			end
		end
	elseif char == "g" then
		local n2,char2 = getCharWithRepeats(prompt..n..char)
		debugMessage("Sub-command: "..n2.." repetition(s) of "..char2)
		if char2 == "g" then
			geany.caret(0)
		end
	elseif char == "G" then
		geany.caret(geany.length())
		geany.navigate("edge", -1)

	-- clipboard
	elseif char == "c" then
		local n2,char2 = getCharWithRepeats(prompt..n..char)
		debugMessage("Sub-command: "..n2.." repetition(s) of "..char2)
		n = n * n2

		if string.find(keyGroups["nav"], char2) then
			selectTextForCommand(n, char2)
		elseif char2 == "c" then
			selectTextForCommand(n-1, "j")
			geany.navigate("line", -1, true)
			geany.navigate("edge", 1, true)
		end

		debugMessage("Replacing ["..geany.selection().."]")
		geany.cut()
		return
	elseif char == "C" then
		selectTextForCommand(n-1, "j")
		geany.navigate("line", -1, true)
		geany.navigate("edge", 1, true)

		debugMessage("Replacing ["..geany.selection().."]")
		geany.cut()
		return
	elseif char == "y" then
		local n2,char2 = getCharWithRepeats(prompt..n..char)
		debugMessage("Sub-command: "..n2.." repetition(s) of "..char2)
		n = n * n2

		local oldCaret = geany.caret()
		if string.find(keyGroups["nav"], char2) then
			selectTextForCommand(n, char2)
		elseif char2 == "y" then
			selectTextForCommand(n-1, "j")
		end

		debugMessage("Copying ["..geany.selection().."]")
		geany.copy()
		geany.caret(oldCaret)
	elseif char == "d" then
		local n2,char2 = getCharWithRepeats(prompt..n..char)
		debugMessage("Sub-command: "..n2.." repetitions of "..char2)
		n = n * n2

		if string.find(keyGroups["nav"], char2) then
			selectTextForCommand(n, char2)
		elseif char2 == "d" then
			geany.navigate("edge", -1)
			geany.navigate("line", n, true)
		end

		debugMessage("Cutting ["..geany.selection().."]")
		geany.cut()
	elseif char == "p" then
		geany.batch(true)
		for i = 1, n do
			geany.paste()
		end
		geany.batch(false)

	-- Undo/redo
	elseif char == "u" then
		for i = 1, n do
			geany.keycmd("EDITOR_UNDO")
		end
	elseif char == "U" then
		for i = 1, n do
			geany.keycmd("EDITOR_REDO")
		end
	end
end
