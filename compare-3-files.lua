#! /usr/bin/env lua
-- Compare any open file including the current file's unsaved changes.
-- Improves the dialog allowing you to choose a Left, Right and optional Middle file
--
-- (c) 2013 by Daniel Givney.
--
-- ========================================================
-- Modified from a previous work by Carl Antuar (See below)
-- ========================================================
--
-- Modified File: compare.lua
-- Authored By: Carl Antuar 2012
--
-- Distribution is permitted under the terms of the GPLv3
-- or any later version.

---- Define functions ----

function createWindow(dlg, file1Default, file2Default)
    dlg:label("Choose the files to compare")
    dlg:select("file1", file1Default,  "Left file:     \t")
    dlg:select("file2", file2Default,  "Right file:   \t")
    dlg:heading("Leave blank to only diff two files")
    dlg:select("file3", "no-result-if-empty",  "Middle file:\t")
    for filename in geany.documents()
    do
        addOption(dlg, filename)
    end
end

function addOption(dlg, filename)
    dlg:option("file1", filename, geany.basename(filename))
    dlg:option("file2", filename, geany.basename(filename))
    dlg:option("file3", filename, geany.basename(filename))
end

function handleUnsavedChanges()
    local filename = "untitled"
    if not (geany.filename() == nil) then
        filename = os.tmpname().."_unsaved"..geany.basename(geany.filename())
    end
    -- copy current contents to temporary file
    local file1Handle = io.open(filename, "w")
    file1Handle:write(geany.text())
    file1Handle:flush()
    io.close(file1Handle)
    return filename
end

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

---- Start execution ----

local dlg=dialog.new("Compare Open Files", { "_Cancel", "_Ok" } )

if geany.fileinfo().changed then
    local tempFile = handleUnsavedChanges()
    createWindow(dlg, geany.filename(), tempFile)
    addOption(dlg, tempFile)
else
    createWindow(dlg, geany.filename(), "no-result-if-empty")
end

local button, results = dlg:run()

if (button == 2) and results then

    local file1,file2,file3 = nil

    for key,value in pairs(results)
    do
        if key == "file1" then file1 = value end
        if key == "file2" then file2 = value end
        if key == "file3" then file3 = value end
    end

    if file1 and file2 then
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
            if file3 then
                local ok,msg = geany.launch(diffCommand, file1, file3, file2)
                if not ok then geany.message(msg) end
            else
                local ok,msg = geany.launch(diffCommand, file1, file2)
                if not ok then geany.message(msg) end
            end
        end
    else
        geany.message("Please choose a left & right file")
    end

end