#! /usr/bin/env lua
-- Use git to find all previous versions of current file - click to open them from tmp folder
--
-- (c) 2013 by Daniel Givney.
--
-- Distribution is permitted under the terms of the GPLv3
-- or any later version.

---- Define functions ----

local currentFile = geany.filename()

local function getGitLogCommand(filename)
    local gitCommand = "cd "..geany.fileinfo().path..";".."git log --no-merges --pretty=format:\"%h%d\t%s\t[%cn]\" ./"..geany.fileinfo().name
    --~ geany.message("DEBUG", "Git LOG is "..gitCommand)
    return gitCommand
end

local function getGitShowCommand(filename)
    local gitCommand = "cd "..geany.fileinfo().path..";".."git show "..commit..":./"..geany.fileinfo().name
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