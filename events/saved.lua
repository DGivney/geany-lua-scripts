#! /usr/bin/env lua
-- Synchronise the hexadecimal representation of a file
-- with the original whenever the hex is saved.
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
	return "xxd "
end

function getHexdumpReverseCommand()
	return "xxd -r "
end

function isCurrentFileShadow()
	local filename = geany.basename(geany.filename())
	return string.sub(filename, 1, 2) == ".#" and string.sub(filename, -4) == ".hex"
end

local function getBinaryFilename(shadowFilename)
	return geany.dirname(shadowFilename)..geany.dirsep..string.sub(string.sub(geany.basename(shadowFilename), 3), 1, -5)
end

function patchFile(shadowFilename)
	local binaryFilename = getBinaryFilename(shadowFilename)
	local tempFilename = os.tmpname();
	--~ geany.message("DEBUG", "Patching shadow file "..geany.basename(shadowFilename).." back to binary.")
	local result = os.execute(getHexdumpReverseCommand()..shadowFilename.." > "..tempFilename)
	if result == 0 then
		--~ geany.message("DEBUG", "Writing binary result back to "..binaryFilename)
		result = os.execute("mv "..tempFilename.." "..binaryFilename)
		if not result == 0 then
			geany.message("ERROR "..result, "Failed to write binary result back to "..binaryFilename)
		end
	else
		geany.message("ERROR "..result, "Failed to patch shadow file "..shadowFilename.." back to binary. The shadow file may be corrupted.")
	end
	return result == 0
end

function refreshShadowFile(shadowFilename)
	local binaryFilename = getBinaryFilename(shadowFilename)
	--~ geany.message("DEBUG", "Refreshing shadow file "..shadowFilename.." from "..binaryFilename)
	local result = os.execute(getHexdumpCommand()..binaryFilename.." > "..shadowFilename)
	if not (result == 0) then
		geany.message("ERROR "..result, "Failed to refresh shadow file")
	end
end

if isCurrentFileShadow() and calcHexSupportLevel() == 2 then
	local shadowFilename = geany.filename()
	
	local result = patchFile(shadowFilename)
	if result then
		refreshShadowFile(shadowFilename)
		geany.open(shadowFilename)
	else
		geany.message("Patch failed")
	end
end
