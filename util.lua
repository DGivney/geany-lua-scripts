#! /usr/bin/env lua
-- Provide utility functions
--
-- v0.1
-- (c) 2013 by Carl Antuar.
-- Distribution is permitted under the terms of the GPLv3
-- or any later version.

function debugMessage(message)
	if debugEnabled then geany.message("DEBUG", message) end
end
