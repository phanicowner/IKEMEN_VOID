--; IKEMEN:VOID Beta 3.0 | Mikazuki The Mugenite, Anonymous, scristopher
--; Community: https://mugen-cheap.fandom.com/wiki/MUGEN_Cheap_Community_Wikia
--;            https://mugen.doomjoshuaboy.com/categories/cheapie-guide/
--; See CREDITS.txt
local loadLuaModule = false
function f_mainTitle()
	cmdInput()
	while true do
		--[[
		drawBottomMenuSP()
		drawMiddleMenuSP()
		]]
		animDraw(f_animVelocity(commonBG0, -1, -1))
		cmdInput()
		refresh()
	end
end