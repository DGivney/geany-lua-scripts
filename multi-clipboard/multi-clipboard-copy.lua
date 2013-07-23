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

function debugMessage(message)
	if debugEnabled then geany.message("DEBUG", message) end
end

local function getListCommand(dirname, fileFilter)
	return "ls "..dirname..geany.dirsep..fileFilter
end

local function ensureDirExists(dirname)
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

local function getOutputLines(command)
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
			debugMessage("Output line "..lineCount.." is "..line)
		end
	else debugMessage("Failed to run command ["..command.."]\n\nError code: "..result)
	end
	debugMessage("Returning "..lineCount.." output lines")
	return lineCount,lines
end

local function setFileContents(filename, contents)
	local fileHandle = io.open(filename, "w")
	fileHandle:write(contents)
	fileHandle:flush()
	fileHandle:close()
end

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
