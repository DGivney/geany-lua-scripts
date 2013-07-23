#! /usr/bin/env lua
-- Provide Vim-style word navigation instead of Geany's implementation.
-- Geany treats all punctuation as whitespace, with the result that
-- punctuation surrounded by whitespace is totally skipped.
--
-- This script selects one Vim word left.
--
-- v0.1
-- (c) 2013 by Carl Antuar.
-- Distribution is permitted under the terms of the GPLv3
-- or any later version.

---- Define constants
keyGroups = { ["nav"]="hjklwe", ["lower"]="abcdefghijklmnopqrstuvwxyz", ["upper"]="ABCDEFGHIJKLMNOPQRSTUVWXYZ", ["whitespace"]=" \t\n\r" }

function atDocumentEdge()
	return geany.caret() == 1 or geany.caret() == geany.length()
end

function isLowerCase(charCode)
	return string.find(keyGroups["lower"], string.char(charCode), 1, true)
end

function isUpperCase(charCode)
	return string.find(keyGroups["upper"], string.char(charCode), 1, true)
end

function isWhitespace(charCode)
	return string.find(keyGroups["whitespace"], string.char(charCode), 1, true)
end

function navWordStartLeft(extend)
	if extend then geany.select() end
	repeat
		geany.navigate("part", -1, extend)
		local charCode, previousCharCode = geany.byte(), geany.byte(geany.caret() - 1)
	until not isWhitespace(charCode) and not (isUpperCase(charCode) and isLowerCase(previousCharCode)) or atDocumentEdge()
end

navWordStartLeft(true)
