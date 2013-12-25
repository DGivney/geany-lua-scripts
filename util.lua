#! /usr/bin/env lua
-- Provide utility functions
--
-- v0.1
-- (c) 2013 by Carl Antuar.
-- Distribution is permitted under the terms of the GPLv3
-- or any later version.

_SPACER = "\n\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t"

function debugMessage(message)
	if debugEnabled then geany.message("DEBUG", message) end
end

function isProjectOpen()
	return not (geany.appinfo().project == nil)
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
