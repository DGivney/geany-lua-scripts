#! /usr/bin/env lua
-- Multi-clipboard support. Stores each chunk of copied text in a
-- new file in the 'support' subdirectory,
-- as well as copying to the regular clipboard.
-- See also 'multi-clipboard-paste.lua'
--
-- v0.2 - Fixed filename matching to handle dots in filename properly.
-- (c) 2013 by Carl Antuar.
-- Distribution is permitted under the terms of the GPLv3
-- or any later version.

---- Define functions ----
debugEnabled = false

dofile(geany.appinfo()["scriptdir"]..geany.dirsep.."util.lua")

local function getFileExtension(filename)
	debugMessage("Extracting file extension of "..filename)
	local startIndex,endIndex = string.find(filename, "\.[0-9]+$", 1)
	debugMessage("Starting dot index is "..startIndex)
	debugMessage("Ending dot index is "..endIndex)
	return tonumber(string.sub(filename, startIndex+1))
end

local function getNewClipboardFilename(clipboardFiles)
	local maxClipboardIndex = 0
	for key,value in pairs(clipboardFiles) do
		clipboardIndex = getFileExtension(value)
		if clipboardIndex > maxClipboardIndex then maxClipboardIndex = clipboardIndex end
	end
	debugMessage("Max clipboard index is "..maxClipboardIndex)
	return getSupportDir()..geany.dirsep.."multi-clipboard."..(maxClipboardIndex+1)
end

-- Start execution
local selection = geany.selection()
if selection == nil or selection == "" then return end
geany.copy()

local clipboardCount,clipboardFiles = getOutputLines(getListCommand(getSupportDir(), "multi-clipboard.*"))
debugMessage("Found "..clipboardCount.." clipboards")
clipboardFile = getNewClipboardFilename(clipboardFiles)
debugMessage("New clipboard file is "..clipboardFile)
setFileContents(clipboardFile, selection)
