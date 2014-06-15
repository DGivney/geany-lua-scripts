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

dofile(geany.appinfo()["scriptdir"]..geany.dirsep.."util.lua")

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
