--; IKEMEN:VOID Beta 3.0 | Mikazuki The Mugenite, Anonymous, scristopher
--; Community: https://mugen-cheap.fandom.com/wiki/MUGEN_Cheap_Community_Wikia
--;            https://mugen.doomjoshuaboy.com/categories/cheapie-guide/
--; See CREDITS.txt
local loadLuaModule = true
--[[=============================================================================
This Lua Module has been specifically designed for I.K.E.M.E.N. PLUS ULTRA Engine.
		Therefore, it may NOT be compatible with I.K.E.M.E.N. GO Engine.
=================================================================================]]
--Insert new item to t_mainMenu table loaded by screenpack.lua
table.insert(t_mainMenu, #t_mainMenu, {text = "CHECK UPDATES", gotomenu = "f_checkUpdates()", id = textImgNew()})
--;===========================================================
--; CHECK UPDATES ITEM
--;===========================================================
function f_checkUpdates()
	webOpen("https://ikemen-void.neocities.org/")
end