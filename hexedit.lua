#! /usr/bin/env lua
-- Generate a hexadecimal version of a file, intended to be edited
-- and synchronised with the original.
--
-- (c) 2012 by Carl Antuar.
-- Distribution is permitted under the terms of the GPLv2
-- or any later version.

function calcHexSupportLevel()
	if os.execute("xxd --version") == 0 then return 2
	elseif os.execute("hexdump /dev/null") == 0 or os.execute("od --version") == 0 then return 1
	else return 0
	end
end

function getHexdumpCommand()
	if os.execute("xxd --version") == 0 then return "xxd"
	elseif os.execute("hexdump /dev/null") == 0 then return "hexdump"
	else return "od" 
	end
end

local hexSupportLevel = calcHexSupportLevel()
if hexSupportLevel == 0 then
	geany.message("No hex support was detected on your system. Please ensure that a tool such as xxd or hexdump is on your PATH")
	return
elseif hexSupportLevel == 1 and not geany.confirm("Read-only", "Hex-writing support was not detected on your system. Do you wish to make a read-only hex dump of the file?", true) then
	return
end

local filename = geany.pickfile()
if filename == nil then return end

geany.message("You chose "..filename)
local shadowFileName = geany.dirname(filename)..geany.dirsep..".#"..geany.basename(filename)..".hex"
if hexSupportLevel == 2 then
	geany.message("Generating hex shadow file "..geany.basename(shadowFileName)..". Changes to this file will be propagated back to the original file.")
else
	shadowFileName = shadowFileName..".dump"
	geany.message("Generating hex dump "..shadowFileName..".")
end

if os.execute(getHexdumpCommand().." "..filename.." > "..shadowFileName) == 0 then
	geany.open(shadowFileName)
else
	geany.message(msg)
end
