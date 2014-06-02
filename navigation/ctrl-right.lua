#! /usr/bin/env lua
-- Provide Vim-style word navigation instead of Geany's implementation.
-- Geany treats all punctuation as whitespace, with the result that
-- punctuation surrounded by whitespace is totally skipped.
--
-- This script navigates one Vim word right.
--
-- (c) 2014 by Carl Antuar.
-- Distribution is permitted under the terms of the GPLv3
-- or any later version.

---- Define functions ----

dofile(geany.appinfo()["scriptdir"]..geany.dirsep.."util.lua")

---- Start execution ----

navWordEndRight(false)
