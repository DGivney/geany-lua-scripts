#! /usr/bin/env lua
-- Build a list of all Java import statements in the project.
--
-- (c) 2014 Carl Antuar.
-- Distribution is permitted under the terms of the GPLv3
-- or any later version.

---- Define functions ----

debugEnabled = false

dofile(geany.appinfo()["scriptdir"]..geany.dirsep.."util.lua")

---- Start execution ----
local searchDir = geany.appinfo()["project"]["base"]
local indexFile = getSupportDir()..geany.dirsep..geany.appinfo()["project"]["name"].."-java-imports.index"

debugMessage("Base search directory is "..searchDir)
debugMessage("Index file is "..indexFile)
local searchCommand = "find "..searchDir.." -iname '*.java' | xargs grep -h '^import\\s\\+\\S\\+\\s*;' |grep -o '\\([a-zA-Z0-9]\\+\\.\\)\\+[a-zA-Z0-9*]\\+' |sort |uniq"
if debugEnabled then getOutputLines(searchCommand) end

local status = os.execute(searchCommand.." > '"..indexFile.."' &")
if not status == 0 then geany.message("ERROR", "Command returned "..status) end
