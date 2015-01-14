---------------------------------------------------
-- Format (or do anything per file type) on save --
---------------------------------------------------
--
-- What is this script?
--   + I made this script in order to format my code every time I save a file, inspired by CodeMaid for .Net.
--     However its format allows you to easily perform anything you want per file type on every save event
--
-- Requires
--   + A temporary file to read from/write to.  This file serves two purposes.
--     1) Due to geany.open() not triggering a refresh after using os.execute to modify the current file 
--        (cached documents maybe?), our other option is to os.execute to write to an external file then read from that.
--     2) geany.save() will retrigger this 'saved.lua' file.  We can then use this external file to keep track
--        of whether we've already ran our code.
--
-- Suggested
--   + I suggest you download the newest geany plusins code at https://github.com/geany/geany-plugins and compilie that
--     from source.  The steps are incredibly easy, and doing so will give you a new lua call I made 'geany.status(message)'.
--     This allows you to write a message to the status window which is nicer than displaying a popup for messages that don't
--     require your attention.


ext = geany.fileinfo()["ext"]

SAVE_FILE = "<absolute path to a safe temporary file here>"

onSaveExts = {
	[".js"] = function(file)
		-- this is just the script I used.  I'm leaving it in here as an example
		
		-- get the position so we can return to it after we save write to the file (which resets the caret)
		local pos = geany.caret()
		
		-- this part requires you to have npm and js-beautify installed (npm install js-beautify)
		local cmd = "js-beautify -f " .. geany.filename() .. " -o " .. SAVE_FILE
		os.execute(cmd)
		geany.status("formatting js file: " .. geany.filename()) 
		
		-- read in the formatted text via the temporary file (as noted above, this is to get around the limitation 
		--   of the plugin, where we can't just edit the file in place then re-open the file here.)
		local formatted = file:read("*all")
		
		-- set the entire file's text to the new formatted string.  Then save and return the caret to its 
		--   original (albeit slightly modified) position.
		geany.text(formatted)
		geany.save()
		geany.caret(pos)
	end
}

local file = assert(io.open(SAVE_FILE, "r"))
local fileSize = file:seek("end")

-- if the extension exists in our table (a valid hack for lack of a switch statement)
--   and our external file hasn't been written to
if (onSaveExts[ext] ~= nil and fileSize == 0) then
	onSaveExts[ext](file)
else

	-- otherwise empty the file's contents
	os.execute("> " .. SAVE_FILE)
end

file:close()
