#! /usr/bin/env lua
-- Insert brackets, XML tags, etc, around the selected text.
--
-- v0.1 - Initial version.
-- v0.2 - Add double quotes to list of surrounds.
-- (c) 2013 by Carl Antuar.
-- Distribution is permitted under the terms of the GPLv3
-- or any later version.

---- Define functions ----
debugEnabled = false

function debugMessage(message)
	if debugEnabled then geany.message("DEBUG", message) end
end

---- Start execution ----
local selectedText = geany.selection()
if selectedText == nil then return
else debugMessage("Selected text was "..selectedText)
end

local surrounds = { [1]="( )", [2]="[ ]", [3]="{ }", [4]="< >", [5]="<tag> </tag>", [6]="\" \"", [7]="' '" }
local surround = geany.choose("What would you like to surround the selected text with?", surrounds)
if surround == nil then return
else
	if surround == surrounds[5] then
		local tag = geany.input("What tag name do you want to use?")
		if tag == nil then return end
		surround = string.gsub(surround, "tag", tag)
	end
	local startChunk,endChunk = nil,nil
	for chunk in string.gmatch(surround, "%S+") do
		if startChunk == nil then startChunk = chunk
		else endChunk = chunk
		end
	end
	debugMessage("Start chunk is "..startChunk)
	debugMessage("End chunk is "..endChunk)
	geany.selection(startChunk..selectedText..endChunk)
end
