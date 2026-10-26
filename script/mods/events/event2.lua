--; IKEMEN:VOID Beta 3.0 | Mikazuki The Mugenite, Anonymous, scristopher
--; Community: https://mugen-cheap.fandom.com/wiki/MUGEN_Cheap_Community_Wikia
--;            https://mugen.doomjoshuaboy.com/categories/cheapie-guide/
--; See CREDITS.txt
--;=====================================================================
--; 					EVENT 2 [TITAN ATTACK]
--; 		(Challenge a formidable Giant Boss Character)
--;=====================================================================
data.gameMode = "singleboss"
data.versusScreen = false
data.victoryscreen = false
setRoundTime(-1)
setRoundsToWin(1)
--data.stage = "stage/"
--data.bgm = "sound/"
textImgSetText(txt_mainSelect, "TITAN ATTACK")
data.p2In = 1
data.p2TeamMenu = {mode = 0, chars = 1}
data.p2Char = {"Red Dragon"}
data.p2Pal = 1
setLifebarDisplay(false)
setPauseVar("nogiveup") --Set special pause variable config to remove give up option
f_selectSimple()