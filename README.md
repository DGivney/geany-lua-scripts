geany-lua-scripts
=================

Collection of scripts for improved productivity in Geany

##Compare - Carl Antuar 2012

_File: compare.lua_

Invoke the script (I have mine mapped to CRTL+SHIFT+c) to compare the current file contents to any open file. If current changes in file are not saved the script will create a shadow file allowing you can compare your changes against the saved version.

##Open file by typing - Carl Antuar 2012

_File: open-file-by-typing.lua_

Invoke the script and begin typing the filename (I have mine mapped to CRTL+SHIFT+o replacing the open selected file behaviour). Script uses find & grep to find files with your keyword.  If only one file is found it opens immediately, if more than one is found the user is presented with a selection window to choose the correct file. Supports partial and wildcard names.

Works best with an open Geany Project with directory root set.

##Search for method definitions PHP - Daniel Givney 2013

_File: search-for-method-definitions-php.lua_

Modified from Carl Antuars script (open-file-by-typing.lua) this script works much like netbeans follow-in-function feature.  Highlight a method name or member in your code by double clicking on it and invoke the script (I have mine mapped to CRTL+SHIFT+d). Script uses grep to open it's class file and follow your cursor into that method's definition.  Could easily be modified to support other languages.

Works best with an open Geany Project with directory root set.

##Git find revisions of file - Daniel Givney 2012

_File: git-find-revisions-of-file.lua_

Invoke the script (I have mine mapped to CRTL+SHIFT+v) to get all versions of current file. Choose a commit and that version of the file will open in a new tab. Works great with Carl Antuar's Compare script.

##Compare 3 files - Daniel Givney 2012

_File: compare-3-files.lua_

Invoke the script (I have mine mapped to CRTL+SHIFT+c) to compare any open file to any other file (Choosing the Left, Right and an optional Middle file). Unsaved changes are compared to the original saved file by default. This script adds extra functionality to Carl Antuar's script.