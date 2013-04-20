geany-lua-scripts
=================

Collection of scripts for improved productivity in Geany

##Open file by typing - Carl Antuar 2012

_File: open-file-by-typing.lua_

Invoke the script and begin typing the filename (I have mine mapped to CRTL+SHIFT+o replacing the open selected file behaviour). Script uses find & grep to find files with your keyword.  If only one file is found it opens immediately, if more than one is found the user is presented with a selection window to choose the correct file. Supports partial and wildcard names.

Works best with an open Geany Project with directory root set.

##Search for method definitions PHP - Daniel Givney 2013

_File: search-for-method-definitions-php.lua_

Modified from Carl Antuars script (open-file-by-typing.lua) this script works much like netbeans follow-in-function feature.  Highlight a method or public member name in your code by double clicking on it and invoke the script (I have mine mapped to CRTL+SHIFT+d). Script uses grep to open it's class file and follow your cursor into that method's definition.  Could easily be modified to support other languages.

Works best with an open Geany Project with directory root set.