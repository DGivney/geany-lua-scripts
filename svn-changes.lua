#! /usr/bin/env lua
-- Retrieve changes from SVN for a specified revision number.
--
-- v0.3 - included commit comments when choosing revision,
-- added 'quick scan' option for choosing only the most recent commits,
-- added support for graphical diff viewers.
-- v0.4 - replace 'quick scan' and 'full scan'
-- with progressive disclosure of scan results;
-- add 'all changes since revision' option.
-- v0.5 - consolidate choices into custom preferences dialog.
-- v0.6 - rearranged to show revision list before choosing the revision
-- range type; fixed 'show more' handling for multiline commit comments.
-- v0.7 - allow selection of ending revision; fix revision list width.
-- v0.8 - add support for searching; add committer name and date to
-- revision list.
--
-- (c) 2013 by Carl Antuar.
-- Distribution is permitted under the terms of the GPLv3
-- or any later version.

---- Define constants ----

debugEnabled = false
_PREFERENCE_FILENAME = "file"
_PREFERENCE_SEARCHSTRING = "searchString"
_PREFERENCE_SCAN_SIZE = "scanCount"
_PREFERENCE_DIFF_VIEWER = "diffViewer"

---- Define functions ----

dofile(geany.appinfo()["scriptdir"]..geany.dirsep.."util.lua")

function getLogCommand(filename)
	local command = "svn log "..filename.." | sed -e 's/^r\\([0-9]\\+\\) |.*/\\1 /g' | tr -d '\\n' | sed -e 's/--\\+/\\n/g' | tail -n +2"
	debugMessage("Log command is "..command)
	return command
end

function getQuickLogCommand(filename, revisionCount, searchString)
	local _REGEXP_REVISION = "^r\\([0-9]\\+\\)"
	local _REGEXP_USERNAME = "\\([^ ]\\+\\)"
	local _REGEXP_DATE = "\\([0-9]\\+[-/][0-9]\\+[-/][0-9]\\+\\)"
	local command = "svn log "..filename.." | head -"..(revisionCount * 4).." | sed -e 's/".._REGEXP_REVISION.." | ".._REGEXP_USERNAME.." | ".._REGEXP_DATE..".*/\\1 \\2 \\3 /g' | tr -d '\\n' | sed -e 's/--\\+/\\n/g' | tail -n +2"
	if searchString then
		command = command.." | grep '"..searchString.."'"
	end
	debugMessage("Log command is "..command)
	return command
end

function getSVNDiffCommand(revision, filename, diffViewer)
	local command = "svn diff --diff-cmd="..diffViewer
	if string.find(revision, ":") then
		command =  command.." -r "..revision.." "..filename
	else
		command = command.." -c "..revision.." "..filename
	end
	debugMessage("Diff command is "..command)
	return command
end

local function addDiffViewer(dialogBox, application)
	if os.execute(application.." --version") == 0 then
		dialogBox:option("diffViewer", application, application)
	end
end

local function getRevisionOptions()
	local buttons = {[1]="_Cancel", [2]="_OK"}
	local svnDialog = dialog.new("SVN Revisions", buttons)

	-- choose file type
	svnDialog:group("fileType", "currentFile", "File/directory to review:")
	if geany.filename() then
		svnDialog:radio("fileType", "currentFile", "Current file ("..geany.filename()..")")
		svnDialog:radio("fileType", "currentDir", "Current directory ("..geany.dirname(geany.filename())..")")
	end
	if isProjectOpen() then
		svnDialog:radio("fileType", "projectBaseDir", "Project base directory ("..geany.appinfo()["project"]["base"]..")")
	end
	svnDialog:radio("fileType", "customFile", "Other:")
	svnDialog:file("customFile", geany.wkdir(), "")

	svnDialog:hr()

	-- choose search parameters
	svnDialog:text("searchString", "", "Search for text (optional):")
	svnDialog:text("scanCount", "30", "Initial # of revisions to scan  \n(0 = unlimited)")

	svnDialog:hr()

	-- choose diff viewer
	svnDialog:select("diffViewer", "diff", "Diff viewer")
	addDiffViewer(svnDialog, "diff")
	addDiffViewer(svnDialog, "meld")
	addDiffViewer(svnDialog, "kompare")
	addDiffViewer(svnDialog, "kdiff3")
	addDiffViewer(svnDialog, "diffuse")
	addDiffViewer(svnDialog, "tkdiff")
	addDiffViewer(svnDialog, "opendiff")
	svnDialog:option("diffViewer", "customDiffViewer", "Other...")
	svnDialog:text("customDiffViewer", "", "Custom diff viewer")

	-- execute

	local resultIndex,resultTable = svnDialog:run()
	if not (resultIndex == 2) then return nil end
	debugMessage("Result ["..resultIndex.."]: ["..buttons[resultIndex].."]")

	local preferences = {}
	if resultTable["fileType"] == "currentFile" then
		preferences[_PREFERENCE_FILENAME] = geany.filename()
	elseif resultTable["fileType"] == "currentDir" then
		preferences[_PREFERENCE_FILENAME] = geany.dirname(geany.filename())
	elseif resultTable["fileType"] == "projectBaseDir" then
		preferences[_PREFERENCE_FILENAME] = geany.appinfo()["project"]["base"]
	elseif resultTable["fileType"] == "customFile" then
		if (resultTable["customFile"] == nil) or resultTable["customFile"] == "" then
			geany.message("ERROR", "You must specify a target file.")
			return nil
		end
		preferences[_PREFERENCE_FILENAME] = resultTable["customFile"]
	end

	if resultTable["searchString"] then
		preferences[_PREFERENCE_SEARCHSTRING] = resultTable["searchString"]
		preferences[_PREFERENCE_SEARCHSTRING] = string.gsub(preferences[_PREFERENCE_SEARCHSTRING], "'", "\\'", string.len(resultTable["searchString"]))
	end
	preferences[_PREFERENCE_SCAN_SIZE] = resultTable["scanCount"]

	if resultTable["diffViewer"] == "customDiffViewer" then
		if (resultTable["customDiffViewer"] == nil) or resultTable["customDiffViewer"] == "" then
			geany.message("ERROR", "You must specify a diff viewer.")
			return nil
		end
		preferences[_PREFERENCE_DIFF_VIEWER] = resultTable["customDiffViewer"]
	else
		preferences[_PREFERENCE_DIFF_VIEWER] = resultTable["diffViewer"]
	end

	return preferences
end

local function pickRevision(filename, scanCount, searchString, prompt)
	local revision
	local increaseScanItem = "Show more.."
	local previousRevisionCount = 0
	if not prompt then prompt = "Please choose the starting revision to review".._SPACER end
	repeat
		local revisionCount,revisions = getOutputLines(getQuickLogCommand(filename, scanCount, searchString))
		if not (revisionCount == previousRevisionCount) then
			debugMessage("Adding 'Show more' item to revision list")
			revisions[revisionCount + 1] = increaseScanItem
			previousRevisionCount = revisionCount
		else
			debugMessage("Same result count as last time; all revisions retrieved")
		end
		if revisionCount == 0 then
			geany.message("Unable to get revision log for "..filename..". Please ensure that this file is under version control.")
			return nil
		else
			revision = geany.choose(prompt, revisions)
			if not revision then return nil
			elseif revision == increaseScanItem then
				scanCount = scanCount * 2
			else
				revision = string.match(revision, "^[0-9]+")
			end
		end
	until not (revision == increaseScanItem)
	return revision
end

---- Start execution ----

local preferences = getRevisionOptions()
if not preferences then
	debugMessage("No results; cancelling")
	return
end

if debugEnabled then
	for key,value in pairs(preferences) do
		debugMessage("Key ["..key.."] has value ["..value.."]")
	end
end

local filename = preferences[_PREFERENCE_FILENAME]
local searchString = preferences[_PREFERENCE_SEARCHSTRING]
local scanCount = preferences[_PREFERENCE_SCAN_SIZE]
local diffViewer = preferences[_PREFERENCE_DIFF_VIEWER]

local revision = pickRevision(filename, scanCount, searchString)
if not revision then return end

local revisionTypes = {[1]="Single revision", [2]="All changes since revision", [3]="Choose end revision", [4]="Custom"}
local revisionType = geany.choose("What revision range would you like to view?", revisionTypes)

if revisionType == nil then return end

debugMessage("Revision type is "..revisionType)
if revisionType == revisionTypes[2] then
	revision = (revision - 1)..":HEAD"
elseif revisionType == revisionTypes[3] then
	local endRevision = pickRevision(filename, scanCount, searchString, "Please choose the end revision".._SPACER)
	if not endRevision then return end
	revision = (revision - 1)..":"..endRevision
elseif revisionType == revisionTypes[4] then
	revision = geany.input("Please enter a revision or range to review", (revision-1)..":"..revision)
	if not revision then return end
end
debugMessage("Revision was "..revision)

if diffViewer == "diff" then
	local lineCount,lines = getOutputLines(getSVNDiffCommand(revision, filename, diffViewer))
	geany.newfile("Revision "..revision)
	geany.selection(table.concat(lines, "\n"))
else
	geany.timeout(0)
	os.execute(getSVNDiffCommand(revision, filename, diffViewer))
end
