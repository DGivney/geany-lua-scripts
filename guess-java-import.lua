#! /usr/bin/env lua
-- Attempt to guess import statements for the highlighted class name.
--
-- (c) 2014 Carl Antuar.
-- Distribution is permitted under the terms of the GPLv3
-- or any later version.

---- Define functions ----

debugEnabled = false

dofile(geany.appinfo()["scriptdir"]..geany.dirsep.."util.lua")

---- Start execution ----

local selectedText = geany.selection()
debugMessage("Selected text: ["..selectedText.."]")

if selectedText == nil or selectedText == "" then
	local oldCursorPos = geany.caret()
	debugMessage("No text selected; seeking current word for position "..oldCursorPos)
	navWordStartLeft(false)
	navWordEndRight(true)
	selectedText = geany.selection()
	geany.caret(oldCursorPos)
end

debugMessage("Class name is "..selectedText)

local searchCommand = "cat "..getSupportDir()..geany.dirsep.."*.index |sort |uniq | grep '\\b"..selectedText.."\\b'"
local count,imports = getOutputLines(searchCommand)

local import = geany.choose("Is one of these the class you want?", imports)
if not import then return end
debugMessage("Importing "..import)

local startIndex,stopIndex = geany.text():find("^package\s")
if not startIndex then startIndex = 1 end

local oldCursorPos = geany.caret()
geany.caret(startIndex)
geany.navigate("edge", 1)
geany.selection("\nimport "..import..";")
geany.caret(oldCursorPos)
