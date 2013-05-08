#! /usr/bin/env lua
-- Compare the current file contents to any open file
-- (including the saved version of the current file).
--
-- (c) 2012 by Carl Antuar.
-- Distribution is permitted under the terms of the GPLv2
-- or any later version.

function getDiffCommand(file1, file2)
    if os.execute("meld --version") == 0 then return "meld"
    elseif os.execute("kompare --version") == 0 then return "kompare"
    elseif os.execute("kdiff3 --version") == 0 then return "kdiff3"
    elseif os.execute("diffuse --version") == 0 then return "diffuse"
    elseif os.execute("tkdiff --version") == 0 then return "tkdiff"
    elseif os.execute("opendiff --version") == 0 then return "opendiff"
    else
        return "diff"
    end
end

local file1 = geany.filename()
if geany.fileinfo().changed then
    if file1 == nil then
        file1 = "untitled"
    end
    file1 = os.tmpname().."_"..geany.basename(file1)
    -- copy current contents to temporary file
    local file1Handle = io.open(file1, "w")
    file1Handle:write(geany.text())
    file1Handle:flush()
    io.close(file1Handle)
end

local msg = "Which document do you want to compare "..geany.fileinfo().name.." to?\n"
local file2Index = 1
local files = {}
for filename in geany.documents()
do
    --msg = msg..file2Index..": "..filename.."\n"
    files[file2Index] = filename
    file2Index = file2Index + 1
end
file2 = geany.choose("\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\n"..msg, files)
if not (file2 == nil) then
    --~ file2 = geany.documents(file2Index)
    local diffCommand = getDiffCommand()
    if diffCommand == "diff" then
        -- no external program found; use diff
        diffFileName = os.tmpname()
        if not os.execute(diffCommand.." "..file1.." "..file2.." > "..diffFileName) then
            geany.message("Failed to perform diff")
            return
        end
        geany.open(diffFileName)
    else
        local ok,msg = geany.launch(diffCommand, file1, file2)
        if not ok then geany.message(msg) end
    end
else
    geany.message("Cancelling")
end