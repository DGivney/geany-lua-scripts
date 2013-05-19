#! /usr/bin/env lua
-- Use git to find all changes to a line in the current file.
-- Uses a simple similarity check function to discover possible changes
-- to that line beyond possible refactoring and up until a certain threshold.
--
-- (c) 2013 by Daniel Givney.
--
-- Distribution is permitted under the terms of the GPLv3
-- or any later version.

---- Define variables ----

local showMaxChanges = 20
local threshold = 80
local showRefactoringCommits = true
local denoteRefactoringCommitsBySymbol = "~"

---- Define 3rd party functions ----

-- This is an independent implementation of an algorithm for string
-- similarity search published by Qi Xiao Yang, Sung Sam Yuan, Li Zhao,
-- Lu Chun and Sun Peng in a paper called "Faster Algorithm of String
-- Comparision".
-- This version was programmed by Tiago Tresoldi and the authors of that
-- paper are in no way related to it.
-- This program can be distributed under the terms of the GNU Library
-- General Public License.
-- version 0.01 fixed stupid superfluous 'w' variable in string_simil()

-- Return a value between 0 and 1 for the similarity of 'fx' with 'fy'.
-- 1 means identical strings, 0 completely different strings
local function string_simil(fx, fy)
  local n = string.len(fx)
  local m = string.len(fy)
  local ssnc = 0

  if n > m then
    fx, fy = fy, fx
    n, m = m, n
  end

  for i = n, 1, -1 do
    if i <= string.len(fx) then
    for j = 1, n-i+1, 1 do
        local pattern = string.sub(fx, j, j+i-1)
        if string.len(pattern) == 0 then break end
        local found_at = string.find(fy, pattern, 0, true)
        if found_at ~= nil then
          ssnc = ssnc + (2*i)^2
          fx = string.sub(fx, 0, j-1) .. string.sub(fx, j+i)
          fy = string.sub(fy, 0, found_at-1) .. string.sub(fy, found_at+i)
          break
        end
      end
    end
  end

  return (ssnc/((n+m)^2))^(1/2)

end

---- Define functions ----

local function parseFieldsFromOutput(output)
    if output==nil or output=="" then
        return "","",""
    else
        local commit = string.gsub(string.sub(output, 0, string.find(output, "%s")), "%s+", "")
        if showRefactoringCommits then
            commit = string.gsub(commit, "^"..denoteRefactoringCommitsBySymbol, "")
        end
        local author = string.sub(output, string.find(output, "(", 0, true), string.find(output, ")", 0, true))
        local patch = string.gsub(string.gsub(string.sub(output, string.find(output, ")", 0, true) + 1, -1), "^%s+", ""), "%s+$", "")
        --~ geany.message("DEBUG", commit.." :: "..author.." :: "..patch)
        return commit,author,patch
    end
end

local function parseLineNumberFromOutput(output)
    if output==nil or output=="" then
        return ""
    else
        local line = string.gsub(string.sub(output, string.find(output, "%s")+1, string.find(output, "%s", string.find(output, "%s")+1)), "%s+", "")
        --~ geany.message("DEBUG","Line is "..line)
        return line
    end
end

local function getGitBlameCommand(line, commit, regex)
    local gitCommand = "cd "..geany.fileinfo().path..";".."git blame -n -L "..(regex and "'/"..string.gsub(regex, "'", "\'").."/'" or line)..",+1 "..commit.." -- ./"..string.gsub(geany.fileinfo().name, "%s", "\\ ")
    --~ geany.message("DEBUG", "GIT BlAME is "..gitCommand)
    return gitCommand
end

local function getGitShowCommand(commit)
    local gitCommand = "cd "..geany.fileinfo().path..";".."git show "..commit..":./"..string.gsub(geany.fileinfo().name, "%s", "\\ ")
    --~ geany.message("DEBUG", "GIT SHOW is "..gitCommand)
    return gitCommand
end

local function executeBlameCommand(line, commit, regex)
    local regex = regex or nil
    local stream = assert(io.popen(getGitBlameCommand(line, commit, regex), 'r'))
    local output = stream:read('*all')
    stream:close()
    return output
end

local function compareOutputs(output1, output2)
    local commit1,author1,patch1 = parseFieldsFromOutput(output1)
    local commit2,author2,patch2 = parseFieldsFromOutput(output2)
    --~ geany.message("DEBUG", "patch1: /"..patch1.."/\patch2: /"..patch2.."/")
    --~ geany.message("DEBUG", "string_siml check="..(string_simil(patch1, patch2)*100).." < "..threshold)
    return string_simil(patch1, patch2)*100
end

local function findChangesToLine(line)
    local files = {}
    local tempFile = os.tmpname()
    local fileCount,lineCount = 0,0
    local output,nextOutput = "",""

    local file = io.open(tempFile, "w")

    repeat
        local commit,author,patch = parseFieldsFromOutput(output)
        if string.len(commit) > 0 then
            commit = commit.."^"
        end

        nextOutput = executeBlameCommand(line, commit)
        if string.len(nextOutput) > 0 then

            if lineCount > 0 and compareOutputs(nextOutput, output) < threshold then
                local regexOutput = executeBlameCommand(line, commit, string.gsub(patch,"^%s|%s$", ""))
                if (string.len(regexOutput) > 0) then
                    if showRefactoringCommits then
                        file:write(denoteRefactoringCommitsBySymbol..nextOutput)
                    end
                    nextOutput = regexOutput
                    line = parseLineNumberFromOutput(nextOutput)
                end
            end
            output = nextOutput
            file:write(output)
        end

        lineCount = lineCount + 1
    until string.len(nextOutput) <= 0 or lineCount >= showMaxChanges

    file:close()

    for changes in io.lines(tempFile) do
        -- need to index from 1 to show up properly in choose dialog
        fileCount = fileCount + 1
        files[fileCount] = changes
    end

    return fileCount,files
end

local function openFileFromCommit(commit, line)
    local tempFile = os.tmpname().."_"..commit.."-"..geany.fileinfo().name
    --~ geany.message("DEBUG", tempFile)
    local result = os.execute(getGitShowCommand(commit).." >> "..tempFile)
    if (result == 0) then
        geany.open(tempFile)
        geany.caret(geany.rowcol(line, 0));
    else
        geany.message("Could not open tmp file: "..tempFile)
    end
end

---- Start execution ----

local line,column = geany.rowcol()
local fileCount,files = findChangesToLine(line)

if (fileCount == 0) then
    geany.message("No revisions exist for this file.")
else
    local output = geany.choose("\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\n"..fileCount.." line changes were found.", files)
    if not (output == nil) then
        local commit,author,patch = parseFieldsFromOutput(output)
        --~ geany.message("DEBUG", "Commit is: "..commit)
        openFileFromCommit(commit, parseLineNumberFromOutput(output))
    end
end