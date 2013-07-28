#! /usr/bin/env lua
-- Delete duplicate lines from current file.
--
-- v0.1
-- (c) 2013 by Carl Antuar.
-- Distribution is permitted under the terms of the GPLv3
-- or any later version.

-- Define functions --
debugEnabled = false

function debugMessage(message)
	if debugEnabled then geany.message("DEBUG", message) end
end

function chompLine(lineIndex)
	return string.gsub(geany.lines(lineIndex), "\n", "")
end

---- Start execution ----
if geany.height() == nil then
	debugMessage("No file was open.")
	return
end

local previousLine = chompLine(1)
local oldCaret = geany.caret()
geany.caret(1)
local lineIndex = 2
geany.batch(true)
while lineIndex <= geany.height() do
	local line = chompLine(lineIndex)
	debugMessage("Line "..lineIndex.." is ["..line.."]")
	if line == previousLine then
		debugMessage("Deleting line "..lineIndex)
		geany.keycmd("EDITOR_DELETELINE")
	else
		previousLine = line
		geany.navigate("line", 1)
		lineIndex = lineIndex + 1
	end
end
geany.caret(oldCaret)
geany.batch(false)
