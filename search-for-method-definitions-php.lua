#! /usr/bin/env lua
-- Lookup method|member definitions in PHP
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
    local findCommand = "grep -nHIrF "..excludeFilters.." "..searchString.." "..getBaseDir()
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

local function openFile(grepString, searchString)
    --~ geany.message("DEBUG", "Opening "..grepString)
    filename = string.sub(grepString, 1, string.find(grepString, ":", 0, true) - 1)
    geany.open(filename)
    text = string.gsub(string.sub(grepString, string.find(grepString, ":", string.find(grepString, ":", 0, true) + 1, true) + 1), "^%s+", "")
    --~ geany.message("DEBUG", "Text "..text)
    caretStart,caretEnd = geany.find(text, 0, geany.length(), {"posix"} )
    geany.caret(caretStart);
end

---- Start execution ----
if not isProjectOpen() then
    geany.message("WARNING: No project is open. Searching the entire filesystem will take too long.")
else

    local originalString = geany.selection()
    local searchString = ""

    if not (originalString == "" or originalString == nil) then

        if (string.char(geany.byte(geany.caret())) == '(') then
            searchString = "-e 'function "..originalString.."('"
            --~ geany.message("Searching for method definition:", originalString.."()")
        else
            searchString = "-e 'public $"..originalString.."' -e 'private $"..originalString.."' -e 'protected $"..originalString.."'"
            --~ geany.message("Searching for member definition:", "$"..originalString)
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
            openFile(files[1], searchString)
        else
            filename = geany.choose("\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\n"..fileCount.." files were found for definition: "..searchString, files)
            if not (filename == nil) then
                openFile(filename, searchString)
            end
        end
    end

end