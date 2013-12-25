#! /usr/bin/env lua
-- Identify all file extensions appearing in the current project.
--
-- v0.1
-- (c) 2013 by Carl Antuar.
-- Distribution is permitted under the terms of the GPLv3
-- or any later version.

---- Define functions ----
debugEnabled = false

dofile(geany.appinfo()["scriptdir"]..geany.dirsep.."util.lua")

local function getFindCommand()
	local command = "find '"..geany.appinfo()["project"]["base"].."' -type f |grep -o '\\.[^./]*$' | sort -u -"
	debugMessage("Find command is "..command)
	return command
end

---- Start execution ----
local lineCount,lines = getOutputLines(getFindCommand())
if lineCount then
	geany.newfile()
	for index,line in ipairs(lines) do
		geany.selection(line.." ")
	end
end
