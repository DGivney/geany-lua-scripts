#! /usr/bin/env lua
-- Provide a subset of vim keybindings.
--
-- (c) 2013 by Carl Antuar.
-- Distribution is permitted under the terms of the GPLv3
-- or any later version.

---- Import library ----

dofile(geany.appinfo()["scriptdir"]..geany.dirsep.."util.lua")

---- Define constants
debugEnabled = false
KEY_GROUPS["nav"] = "hjklwWeEbBfF"
SYMBOL_KEYS = {
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

local function getChar(prompt) do
	local char = geany.keygrab(prompt)
	if SYMBOL_KEYS[char] then char = SYMBOL_KEYS[char] end
	return char
end

local function getCharWithRepeats(prompt)
	local n = 0
	local char = getChar(prompt)
	while string.match(char, "^[0-9]$") do
		if n == 0 then n = tonumber(char)
		else n = (n * 10) + tonumber(char)
		end
		char = getChar(prompt..n)
	end
	if n == 0 then n = 1 end
	return n,char
end

local function vimNavigate(n, char, extend)
	if not extend then extend = true end
	if extend then
		debugMessage("Selecting text for "..n.." repetitions of "..char)
	else
		debugMessage("Navigating "..n.." repetitions of "..char)
	end
	geany.select()
	if char == "h" then
		geany.navigate("char", -1 * n, extend)
	elseif char == "j" then
		geany.navigate("edge", -1)
		geany.navigate("line", n+1, extend)
	elseif char == "k" then
		geany.navigate("edge", -1)
		geany.navigate("line", 1)
		geany.navigate("line", -1 * (n+1), extend)
	elseif char == "l" then
		geany.navigate("char", n, extend)
	else
		for i = 1, n do
			if char == "e" then navWordEndRight(extend)
			elseif char == "E" then navWORDEndRight(extend)
			elseif char == "w" then navWordStartRight(extend)
			elseif char == "W" then navWORDStartRight(extend)
			elseif char == "b" then navWordStartLeft(extend)
			elseif char == "B" then navWORDStartLeft(extend)
			elseif char == "f" or char == "F" then
				local searchText = getChar()
				local text = geany.text()
				if char == "F" then text = text:reverse() end
				local newIndex = text:find(searchText, geany.caret(), extend)
				geany.navigate("char", newIndex - geany.caret(), extend)
			end
		end
	end
end

---- Start execution ----
local prompt = "Please enter a vim command or Esc to exit.\nNB Typing slowly is recommended: "
geany.timeout(0)
while true do
	local n,char = getCharWithRepeats(prompt)
	debugMessage("Command was "..n..char)

	-- switching to edit mode (exiting script)
	if char == "Escape" then return
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
	elseif SYMBOL_KEYS[char] == "^" then
		for i=2, n do
			geany.navigate("line", -1)
		end
		geany.navigate("edge", -1)
	elseif SYMBOL_KEYS[char] == "$" then
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
		searchText = geany.keygrab("Please enter the character to find: ")
		-- translate descriptive character codes into symbols
		if SYMBOL_KEYS[searchText] then searchText = SYMBOL_KEYS[searchText] end
		debugMessage("Search char is "..searchText)
		if searchText:len() == 1 then
			for i = 1, n do
				if char == "f" then
					local newIndex = geany.text():find(searchText, geany.caret()+2, true)
					if newIndex then
						geany.caret(newIndex-1)
					else
						debugMessage("Could not find "..searchText.." in document after position "..geany.caret())
					end
				else
					local newIndex = geany.text():reverse():find(searchText, geany.length() - geany.caret() + 1, true)
					if newIndex then
						geany.caret(geany.length()-newIndex)
					else
						debugMessage("Could not find "..searchText.." in document before position "..geany.caret())
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

		if string.find(KEY_GROUPS["nav"], char2) then
			vimNavigate(n, char2)
		elseif char2 == "c" then
			vimNavigate(n-1, "j")
			geany.navigate("line", -1, true)
			geany.navigate("edge", 1, true)
		end

		debugMessage("Replacing ["..geany.selection().."]")
		geany.cut()
		return
	elseif char == "C" then
		vimNavigate(n-1, "j")
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
		if string.find(KEY_GROUPS["nav"], char2) then
			vimNavigate(n, char2)
		elseif char2 == "y" then
			vimNavigate(n-1, "j")
		end

		debugMessage("Copying ["..geany.selection().."]")
		geany.copy()
		geany.caret(oldCaret)
	elseif char == "d" then
		local n2,char2 = getCharWithRepeats(prompt..n..char)
		debugMessage("Sub-command: "..n2.." repetitions of "..char2)
		n = n * n2

		if string.find(KEY_GROUPS["nav"], char2) then
			vimNavigate(n, char2)
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
