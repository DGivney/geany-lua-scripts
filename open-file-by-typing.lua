#! /usr/bin/env lua
-- Open files by partial file name and/or path.
--
-- (c) 2012 by Carl Antuar.
-- Distribution is permitted under the terms of the GPLv3
-- or any later version.

---- Define functions ----

local function isProjectOpen()
    return not (geany.appinfo().project == nil)
end

local function getBaseDir()
    if not (basedir == nil) then return basedir
    elseif isProjectOpen() then return geany.appinfo()["project"]["base"]
    else return "/"
    end
end

local function getFilterUnlessExplicit(searchString, filterPattern)
    if string.find(searchString, filterPattern) then return ""
    else
        return " | grep -v '"..filterPattern.."'"
    end
end

local fileFilters = {"\\.class$", "\\.pyc$", "\\.svn-base$", "\\.o$", "~$"}

local function getFindCommand(searchString)
    local findCommand = "find "..getBaseDir().." -iname '"..searchString.."*'"
    for i,filterPattern in pairs(fileFilters) do
        findCommand = findCommand..getFilterUnlessExplicit(searchString, filterPattern)
    end
    --~ geany.message("DEBUG", "Find command is "..findCommand)
    return findCommand
end

local function findFiles(searchString)
    local files = {}
    local fileCount = 0
    local tempFile = os.tmpname()
    local result = os.execute(getFindCommand(searchString).." >> "..tempFile)
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
        os.execute(getFindCommand(searchString).." >> "..tempFile)
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
    basedir = geany.input("WARNING: No project is open. Searching the entire filesystem may be very slow.\nPlease choose the base directory to search.")
end

local searchString = geany.selection()

if searchString == "" then
    searchString = geany.input("Please enter all or part of the filename that you wish to open.\nYou can use shell wildcards * and ?", geany.selection())
end

if not (searchString == nil) then
    --~ geany.message("DEBUG", getFindCommand(searchString))
    local fileCount,files = findFiles(searchString)
    if fileCount == 0 then
        --~ geany.message("DEBUG", "No results in search directory, checking open files")
        -- check open files
        fileCount,files = findOpenFiles(searchString)
    end

    if fileCount == 0 then
        geany.message("No files found matching "..searchString..".\nPlease check your search parameters and try again.")
    elseif fileCount == 1 then
        --~ geany.message("DEBUG", "Opening "..files[1])
        geany.open(files[1])
    else
        filename = geany.choose("\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\n"..fileCount.." files were found matching "..searchString, files)
        if not (filename == nil) then geany.open(filename) end
    end
end
