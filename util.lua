#! /usr/bin/env lua
-- Provide utility functions
--
-- v0.1
-- (c) 2013 by Carl Antuar.
-- Distribution is permitted under the terms of the GPLv3
-- or any later version.

---- Define constants ----

_SPACER = "\n\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t"
KEY_GROUPS = { ["lower"]="abcdefghijklmnopqrstuvwxyz", ["upper"]="ABCDEFGHIJKLMNOPQRSTUVWXYZ", ["whitespace"]=" \t\n\r" }

---- Define functions ----

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

function atDocumentEdge()
	return geany.caret() == 1 or geany.caret() == geany.length()
end

function isLowerCase(charCode)
	return string.find(KEY_GROUPS["lower"], string.char(charCode), 1, true)
end

function isUpperCase(charCode)
	return string.find(KEY_GROUPS["upper"], string.char(charCode), 1, true)
end

function isWhitespace(charCode)
	return string.find(KEY_GROUPS["whitespace"], string.char(charCode), 1, true)
end

-- Navigating by word parts almost matches Vim word navigation, except:
-- - if the cursor starts on whitespace, it goes to the closer end of the next word, not the further end
-- - if a word is camel-cased, it steps through each segment.
function navWordEndRight(extend)
	if extend then geany.select() end
	debugMessage("Character at caret is "..geany.byte().." ["..string.char(geany.byte()).."]")
	repeat
		geany.navigate("part", 1, extend)
		local charCode, previousCharCode = geany.byte(), geany.byte(geany.caret() - 1)
		debugMessage("Current char is "..charCode.." ["..string.char(charCode).."]")
		debugMessage("Previous char is "..previousCharCode.." ["..string.char(previousCharCode).."]")
	until not isWhitespace(previousCharCode) and not (isUpperCase(charCode) and isLowerCase(previousCharCode)) or atDocumentEdge()
end

function navWordEndLeft(extend)
	if extend then geany.select() end
	debugMessage("Character at caret is "..geany.byte().." ["..string.char(geany.byte()).."]")
	repeat
		geany.navigate("part", -1, extend)
		local charCode, previousCharCode = geany.byte(), geany.byte(geany.caret() - 1)
		debugMessage("Current char is "..charCode.." ["..string.char(charCode).."]")
		debugMessage("Previous char is "..previousCharCode.." ["..string.char(previousCharCode).."]")
	until not isWhitespace(previousCharCode) and not (isUpperCase(charCode) and isLowerCase(previousCharCode)) or atDocumentEdge()
end

function navWordStartRight(extend)
	if extend then geany.select() end
	debugMessage("Character at caret is "..geany.byte().." ["..string.char(geany.byte()).."]")
	repeat
		geany.navigate("part", 1, extend)
		local charCode, previousCharCode = geany.byte(), geany.byte(geany.caret() - 1)
		debugMessage("Current char is "..charCode.." ["..string.char(charCode).."]")
		debugMessage("Previous char is "..previousCharCode.." ["..string.char(previousCharCode).."]")
	until not isWhitespace(charCode) and not (isUpperCase(charCode) and isLowerCase(previousCharCode)) or atDocumentEdge()
end

function navWordStartLeft(extend)
	if extend then geany.select() end
	debugMessage("Character at caret is "..geany.byte().." ["..string.char(geany.byte()).."]")
	repeat
		geany.navigate("part", -1, extend)
		local charCode, previousCharCode = geany.byte(), geany.byte(geany.caret() - 1)
		debugMessage("Current char is "..charCode.." ["..string.char(charCode).."]")
		debugMessage("Previous char is "..previousCharCode.." ["..string.char(previousCharCode).."]")
	until not isWhitespace(charCode) and not (isUpperCase(charCode) and isLowerCase(previousCharCode)) or atDocumentEdge()
end

function navWORDEndRight(extend)
	if extend then geany.select() end
	debugMessage("Character at caret is "..geany.byte().." ["..string.char(geany.byte()).."]")
	repeat
		geany.navigate("part", 1, extend)
		local charCode, previousCharCode = geany.byte(), geany.byte(geany.caret() - 1)
		debugMessage("Current char is "..charCode.." ["..string.char(charCode).."]")
		debugMessage("Previous char is "..previousCharCode.." ["..string.char(previousCharCode).."]")
	until isWhitespace(charCode) or atDocumentEdge()
end

function navWORDEndLeft(extend)
	if extend then geany.select() end
	debugMessage("Character at caret is "..geany.byte().." ["..string.char(geany.byte()).."]")
	repeat
		geany.navigate("part", -1, extend)
		local charCode, previousCharCode = geany.byte(), geany.byte(geany.caret() - 1)
		debugMessage("Current char is "..charCode.." ["..string.char(charCode).."]")
		debugMessage("Previous char is "..previousCharCode.." ["..string.char(previousCharCode).."]")
	until isWhitespace(charCode) or atDocumentEdge()
end

function navWORDStartRight(extend)
	if extend then geany.select() end
	debugMessage("Character at caret is "..geany.byte().." ["..string.char(geany.byte()).."]")
	repeat
		geany.navigate("part", 1, extend)
		local charCode, previousCharCode = geany.byte(), geany.byte(geany.caret() - 1)
		debugMessage("Current char is "..charCode.." ["..string.char(charCode).."]")
		debugMessage("Previous char is "..previousCharCode.." ["..string.char(previousCharCode).."]")
	until isWhitespace(previousCharCode) or atDocumentEdge()
end

function navWORDStartLeft(extend)
	if extend then geany.select() end
	debugMessage("Character at caret is "..geany.byte().." ["..string.char(geany.byte()).."]")
	repeat
		geany.navigate("part", -1, extend)
		local charCode, previousCharCode = geany.byte(), geany.byte(geany.caret() - 1)
		debugMessage("Current char is "..charCode.." ["..string.char(charCode).."]")
		debugMessage("Previous char is "..previousCharCode.." ["..string.char(previousCharCode).."]")
	until isWhitespace(previousCharCode) or atDocumentEdge()
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

function getFileContents(filename)
	local stringBuilder = ""
	for line in io.lines(filename) do
		if not (stringBuilder == "") then stringBuilder = stringBuilder.."\n" end
		stringBuilder = stringBuilder..line
	end
	return stringBuilder
end

function setFileContents(filename, contents)
	local fileHandle = io.open(filename, "w")
	fileHandle:write(contents)
	fileHandle:flush()
	fileHandle:close()
end

