#! /usr/bin/env lua
-- Multi-clipboard support. Retrieves text from multiple clipboards,
-- stored as files in the 'support' subdirectory,
-- and allows the user to choose one to paste.
-- See also 'multi-clipboard-copy.lua'
--
-- v0.2 - sorted clipboards by modification date (newest first);
-- fixed retrieval of line breaks from clipboard files;
-- add pasted text to regular clipboard to make multiple pastes easier.
-- (c) 2013 by Carl Antuar.
-- Distribution is permitted under the terms of the GPLv3
-- or any later version.

---- Define functions ----
debugEnabled = false

function debugMessage(message)
	if debugEnabled then geany.message("DEBUG", message) end
end

function getListCommand(dirname, fileFilter)
	return "ls -t "..dirname..geany.dirsep..fileFilter
end

function ensureDirExists(dirname)
	if not (os.execute(getListCommand(dirname, "")) == 0) then
		debugMessage("Creating directory "..dirname)
		os.execute("mkdir -p "..dirname)
	end
end

function getSupportDir()
	local dir = geany.appinfo().scriptdir..geany.dirsep.."support"
	ensureDirExists(dir)
	return dir
end

function getOutputLines(command)
	local lines = {}
	local lineCount = 0
	local tempFile = os.tmpname()
	debugMessage("Writing output of ["..command.."] to "..tempFile)
	local result = os.execute(command.." >> "..tempFile)
	if result == 0 then
		for line in io.lines(tempFile) do
			-- need to index from 1 to show up properly in choose dialog
			lineCount = lineCount + 1
			lines[lineCount] = line
		end
	else debugMessage("Failed to run command ["..command.."]\n\nError code: "..result)
	end
	debugMessage("Returning "..lineCount.." output lines")
	return lineCount,lines
end

function getFileContents(filename)
	local stringBuilder = ""
	for line in io.lines(filename) do
		if not (stringBuilder == "") then stringBuilder = stringBuilder.."\n" end
		stringBuilder = stringBuilder..line
	end
	return stringBuilder
end

local function getClipboards()
	local clipboardContents = {}
	local clipboardCount,clipboardFiles = getOutputLines(getListCommand(getSupportDir(), "multi-clipboard.*"))
	for index,filename in pairs(clipboardFiles) do
		clipboardContents[index] = getFileContents(filename)
		debugMessage("Clipboard ["..index.."] has content "..clipboardContents[index])
	end
	return clipboardContents
end

-- Start execution
local clipboardContents = getClipboards()
local selectedClipboardText = geany.choose("Please choose a clipboard to paste from:", clipboardContents)
if selectedClipboardText == nil or selectedClipboardText == "" then return end
geany.copy(selectedClipboardText)
geany.selection(selectedClipboardText)
