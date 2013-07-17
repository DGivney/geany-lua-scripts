#! /usr/bin/env lua
-- Prompt the user to remove clipboard files if they exist.
-- Prompting is incompatible with the 'confirm exit' preference;
-- if that is enabled, then either prompting should be disabled,
-- or the plugin should be unloaded and reloaded (to safely trigger
-- the prompt) before exiting.
--
-- v0.1
-- (c) 2013 by Carl Antuar.
-- Distribution is permitted under the terms of the GPLv3
-- or any later version.

---- Define functions ----
debugEnabled = false
confirm = false

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

function getOutputLines(command)
	local lines = {}
	local lineCount = 0
	local result = io.popen(command, 'r')
	if result == nil then
		geany.message("ERROR", "Failed to get output of command ["..command.."]")
		return
	end
	for line in result:lines() do
		-- need to index from 1 to show up properly in choose dialog
		lineCount = lineCount + 1
		lines[lineCount] = line
	end
	result:close()
	debugMessage("Returning "..lineCount.." output lines")
	return lineCount,lines
end

-- Start execution
local clipboardCount,clipboardFiles = getOutputLines(getListCommand(getSupportDir(), "multi-clipboard.*"))
if clipboardCount > 0 then
	if (not confirm) or geany.confirm(clipboardCount.." clipboard(s) found", "Do you wish to delete your clipboards now?", false) then
		os.execute("rm "..getSupportDir()..geany.dirsep.."multi-clipboard.*")
	end
end
