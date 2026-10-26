--; IKEMEN:VOID Beta 3.0 | Mikazuki The Mugenite, Anonymous, scristopher
--; Community: https://mugen-cheap.fandom.com/wiki/MUGEN_Cheap_Community_Wikia
--;            https://mugen.doomjoshuaboy.com/categories/cheapie-guide/
--; See CREDITS.txt
local loadLuaModule = true
local includeLuaMatch = true --This module will be loaded during a match.

--Checks functions uses the CNS triggers
local function trophyTaunt()
	if (playerLeftSide and player(1) or not playerLeftSide and player(2)) and ailevel() == 0 and anim() == 195 then
		if not data.trophies.achievement1.clear then
			data.trophies.achievement1.clear = true
			f_saveAchievements()
			f_unlock(false)
			f_updateUnlocks()
		end
	end
end

function f_checkAchievements() --Need to be inside a loop
	trophyTaunt()
	achievements() --To display the achievements unlocked
end