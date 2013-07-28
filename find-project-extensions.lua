#! /usr/bin/env lua
-- Identify all file extensions appearing in the current project.
--
-- v0.1
-- (c) 2013 by Carl Antuar.
-- Distribution is permitted under the terms of the GPLv3
-- or any later version.

---- Define functions ----
debugEnabled = false

function debugMessage(message)
	if debugEnabled then geany.message("DEBUG", message) end
end

function isProjectOpen()
	return not (geany.appinfo().project == nil)
end

local function getFindCommand()
	local command = "find '"..geany.appinfo()["project"]["base"].."' -type f |grep -o '\\.[^./]*$' | sort -u -"
	debugMessage("Find command is "..command)
	return command
end

---- Start execution ----
local command = getFindCommand()
local tempFile = os.tmpname()
debugMessage("Writing output of ["..command.."] to "..tempFile)
local result = os.execute(command.." > "..tempFile)
if result == 0 then
	geany.open(tempFile)
else debugMessage("Failed to run command ["..command.."]\n\nError code: "..result)
end
