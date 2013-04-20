#! /usr/bin/env lua
-- Lookup method|member definitions in PHP
--
-- NOTE: Only supports public member lookup
--
-- (c) 2013 by Daniel Givney.
--
-- ========================================================
-- Modified from a previous work by Carl Antuar (See below)
-- ========================================================
--
-- Modified File: Open files by partial file name and/or path.
-- Authored By: Carl Antuar 2012
--
-- Distribution is permitted under the terms of the GPLv3
-- or any later version.

---- Define functions ----

local excludeFilters = "--exclude-dir=\.svn --exclude-dir=tmp --exclude-dir=\.git --exclude-dir=Test"

local function isProjectOpen()
    return not (geany.appinfo().project == nil)
end

local function getBaseDir()
    if not (basedir == nil) then return basedir
    elseif isProjectOpen() then return geany.appinfo()["project"]["base"]
    else return "/"
    end
end

local function getGrepCommand(searchString)
    local findCommand = "grep -nHIrF "..excludeFilters.." '"..searchString.."' "..getBaseDir()
    --~ geany.message("DEBUG", "Grep command is "..findCommand)
    return findCommand
end

local function findFiles(searchString)
    local files = {}
    local fileCount = 0
    local tempFile = os.tmpname()
    local result = os.execute(getGrepCommand(searchString).." >> "..tempFile)
    if result == 0 then
        for filename in io.lines(tempFile) do
            -- need to index from 1 to show up properly in choose dialog
            fileCount = fileCount + 1
            files[fileCount] = filename
        end
    end
    return fileCount,files
end

local function findOpenFiles(searchString)
    local files = {}
    local fileCount = 0
    local tempFile = os.tmpname()
    for filename in geany.documents() do
        --~ geany.message("DEBUG", "Checking file "..filename)
        basedir = filename
        os.execute(getGrepCommand(searchString).." >> "..tempFile)
    end
    for filename in io.lines(tempFile) do
        -- need to index from 1 to show up properly in choose dialog
        fileCount = fileCount + 1
        files[fileCount] = filename
    end
    return fileCount,files
end

---- Start execution ----
if not isProjectOpen() then
    geany.message("WARNING: No project is open. Searching the entire filesystem will take too long.")
else

    local originalString = geany.selection()
    local searchString = ""

    if not (originalString == "" or originalString == nil) then

        if (string.char(geany.byte(geany.caret())) == '(') then
            searchString = "function "..originalString.."("
            geany.message("Searching for method definition:", originalString.."()")
        else
            searchString = "public $"..originalString
            geany.message("Searching for member definition:", "$"..originalString)
        end

        --~ geany.message("DEBUG", getGrepCommand(searchString))
        local fileCount,files = findFiles(searchString)
        if fileCount == 0 then
            --~ geany.message("DEBUG", "No results in search directory, checking open files")
            -- check open files
            fileCount,files = findOpenFiles(searchString)
        end

        if fileCount == 0 then
            geany.message("Definition could not be found in this project path.\nLooking for: "..searchString)
        elseif fileCount == 1 then
            --~ geany.message("DEBUG", "Opening "..files[1])
            geany.open(string.sub(files[1], 1, string.find(files[1], ":", 0, true) - 1, true))
            caretStart,caretEnd = geany.find(searchString, 0, geany.length(), {"regexp"} )
            geany.caret(caretEnd);
        else
            filename = geany.choose("\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\n"..fileCount.." files were found for definition: "..originalString.."()", files)
            if not (filename == nil) then
                geany.open(string.sub(filename, 1, string.find(filename, ":", 0, true) - 1, true))
                caretStart,caretEnd = geany.find(searchString, 0, geany.length(), {"regexp"} )
                geany.caret(caretEnd);
            end
        end
    end

end