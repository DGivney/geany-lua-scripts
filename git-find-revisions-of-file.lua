#! /usr/bin/env lua
-- Use git to find all previous versions of current file - click to open them from tmp drive
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

local currentFile = geany.filename()

local function isProjectOpen()
    return not (geany.appinfo().project == nil)
end

local function getBaseDir()
    if not (basedir == nil) then return basedir
    elseif isProjectOpen() then return geany.appinfo()["project"]["base"]
    else return "/"
    end
end

local function getRelativeFilePath(filename)
    local relativeFilePath = "."..string.gsub(filename, getBaseDir(), "")
    return relativeFilePath
end

local function getGitLogCommand(filename)
    local gitCommand = "cd "..getBaseDir()..";".."git log --no-merges --pretty=format:\"%h%d\t%s\t[%cn]\" "..getRelativeFilePath(filename)
    --~ geany.message("DEBUG", "Git LOG is "..gitCommand)
    return gitCommand
end

local function getGitShowCommand(filename)
    local gitCommand = "cd "..getBaseDir()..";".."git show "..commit..":"..getRelativeFilePath(filename)
    --~ geany.message("DEBUG", "GIT SHOW is "..gitCommand)
    return gitCommand
end

local function findRevisions(filename)
    local files = {}
    local fileCount = 0
    local tempFile = os.tmpname()
    local result = os.execute(getGitLogCommand(filename).." >> "..tempFile)
    if result == 0 then
        for version in io.lines(tempFile) do
            -- need to index from 1 to show up properly in choose dialog
            fileCount = fileCount + 1
            files[fileCount] = version
        end
    end
    return fileCount,files
end

local function openFileFromCommit(commit, filename)
    local tempFile = os.tmpname().."_"..commit.."-"..geany.basename(filename)
    --~ geany.message("DEBUG", tempFile)
    local result = os.execute(getGitShowCommand(filename).." >> "..tempFile)
    if result == 0 then
        geany.open(tempFile)
    else
        geany.message("Could not open tmp file: "..tempFile)
    end
end

---- Start execution ----

if not isProjectOpen() then
    geany.message("WARNING: No project is open. Git can not run without a root directory set.")
else

    local fileCount,files = findRevisions(currentFile)

    if fileCount == 0 then
        geany.message("No revisions exist for this file.")
    else
        commit = geany.choose("\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\n"..fileCount.." revisions were found.", files)
        if not (commit == nil) then
            commit = string.gsub(string.sub(commit, 0, string.find(commit, "\t")), "%s+", "")
            --~ geany.message("DEBUG", "Commit is: "..commit)
            openFileFromCommit(commit, currentFile)
        end
    end

end