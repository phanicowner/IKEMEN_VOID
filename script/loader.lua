--; IKEMEN:VOID Beta 3.0 | Mikazuki The Mugenite, Anonymous, scristopher
--; Community: https://mugen-cheap.fandom.com/wiki/MUGEN_Cheap_Community_Wikia
--;            https://mugen.doomjoshuaboy.com/categories/cheapie-guide/
--; See CREDITS.txt
--;===========================================================
--; LOAD CHARACTERS DATA
--;===========================================================
local function f_getCharPath(baseDir, targetPathLower)
	for file in lfs.dir(baseDir) do
		if file ~= "." and file ~= ".." then
			local fullPath = baseDir .. "/" .. file
			local attr = lfs.attributes(fullPath)
			if attr ~= nil then
				if attr.mode == "directory" then
				--Recursively search in subdirectories
					local found = f_getCharPath(fullPath, targetPathLower)
					if found then
						return found
					end
				else
				--Compare without uppercase
					if string.lower(fullPath) == targetPathLower then
						return fullPath:gsub('[^/]+%.def$', '') --remove .def from file
					end
				end
			end
		end
	end
	return nil
end
--parse character data
function f_parseChar(t, cel)
	local line = ''
	local displayname = getCharName(cel):gsub('^["%s]*(.-)["%s]*$', '%1')
	local def = getCharFileName(cel)
	if displayname ~= '' and def ~= 'randomselect' then
		local dir = def:gsub('[^/]+%.def$', '')
		t['displayname'] = displayname
		t['def'] = def
		t['dir'] = dir
		--t['ikanim'] = f_getCharPath("chars", def) --Because getCharFileName() return in lowercase
		local sffPath = ''
		local sndPath = ''
		local airPath = ''
		local cnsPath = ''
		local stPath = ''
		local introPath = ''
		local endingPath = ''
		local row = ''
		local section = ''
		local defF = io.open(def, 'r')
		if defF == nil then
			t['failed'] = true
			if f_logFailedChar then f_logFailedChar(def, "missing .def") end
			return
		end
		for line in defF:lines() do
			line = line:lower()
			if line:match('^%s*%[%s*info%s*%]') then
				section = 1
			elseif line:match('^%s*%[%s*ja.info%s*%]') then --This will avoid error when reading the sff path of a character with his section declared
				section = 2
			elseif line:match('^%s*%[%s*files%s*%]') then
				section = 3
			elseif line:match('^%s*%[%s*ja.files%s*%]') then
				section = 4
			elseif line:match('^%s*%[%s*palette%s*keymap%s*%]') then
				section = 5
			elseif line:match('^%s*%[%s*arcade%s*%]') then
				section = 6
			elseif line:match('^%s*%[%s*unlock%s*%]') then
				section = 7
			elseif line:match('^%s*%[%s*portraits%s*%]') then
				section = 8
			elseif line:match('^%s*%[') then --in case character shares DEF file with other files
				section = 9
				--break
		--[Info]
			elseif section == 1 then
				if line:match('^%s*name%s*=') then
					line = line:gsub('%s*;.*$', '')
					if not line:match('=%s*$') then
						t['name'] = line:gsub('^%s*name%s*=%s*["]*%s*(.-)%s*["]*%s*$', '%1')
					end
				end
				if line:match('^%s*author%s*=') then
					line = line:gsub('%s*;.*$', '')
					if not line:match('=%s*$') then
						t['author'] = line:gsub('^%s*author%s*=%s*["]*%s*(.-)%s*["]*%s*$', '%1')
					end
				end
				if line:match('^%s*discordkey%s*=') then
					line = line:gsub('%s*;.*$', '')
					if not line:match('=%s*$') then
						t['discordkey'] = line:gsub('^%s*discordkey%s*=%s*["]*%s*(.-)%s*["]*%s*$', '%1')
					end
				end
				if line:match('^%s*glossaryname%s*=') then
					line = line:gsub('%s*;.*$', '')
					if not line:match('=%s*$') then
						t['glossaryname'] = line:gsub('^%s*glossaryname%s*=%s*["]*%s*(.-)%s*["]*%s*$', '%1')
					end
				end
		--[Ja.Info]
			elseif section == 2 then
				if line:match('^%s*name%s*=') then
					line = line:gsub('%s*;.*$', '')
					if not line:match('=%s*$') then
						t['namejp'] = line:gsub('^%s*name%s*=%s*["]*%s*(.-)%s*["]*%s*$', '%1')
					end
				end
				if line:match('^%s*displayname%s*=') then
					line = line:gsub('%s*;.*$', '')
					if not line:match('=%s*$') then
						t['displaynamejp'] = line:gsub('^%s*displayname%s*=%s*["]*%s*(.-)%s*["]*%s*$', '%1')
					end
				end
				if line:match('^%s*discordkey%s*=') then
					line = line:gsub('%s*;.*$', '')
					if not line:match('=%s*$') then
						t['discordkeyjp'] = line:gsub('^%s*discordkey%s*=%s*["]*%s*(.-)%s*["]*%s*$', '%1')
					end
				end
				if line:match('^%s*author%s*=') then
					line = line:gsub('%s*;.*$', '')
					if not line:match('=%s*$') then
						t['authorjp'] = line:gsub('^%s*author%s*=%s*["]*%s*(.-)%s*["]*%s*$', '%1')
					end
				end
		--[Files]
			elseif section == 3 then
				if line:match('^%s*sprite%s*=') then
					line = line:gsub('%s*;.*$', '')
					if not line:match('=%s*$') then
						line = line:gsub('\\', '/')
						sffPath = dir .. line:gsub('^%s*sprite%s*=%s*(.-)%s*$', '%1')
						t['sff'] = sffPath
					end
				elseif line:match('^%s*sound%s*=') then
					line = line:gsub('%s*;.*$', '')
					if not line:match('=%s*$') then
						line = line:gsub('\\', '/')
						sndPath = dir .. line:gsub('^%s*sound%s*=%s*(.-)%s*$', '%1')
						t['snd'] = sndPath
					end
				elseif line:match('^%s*anim%s*=') then
					line = line:gsub('%s*;.*$', '')
					if not line:match('=%s*$') then
						line = line:gsub('\\', '/')
						airPath = dir .. line:gsub('^%s*anim%s*=%s*(.-)%s*$', '%1')
						t['air'] = airPath
					end
				elseif line:match('^%s*cns%s*=') then
					line = line:gsub('%s*;.*$', '')
					if not line:match('=%s*$') then
						line = line:gsub('\\', '/')
						cnsPath = dir .. line:gsub('^%s*cns%s*=%s*(.-)%s*$', '%1')
						t['cns'] = cnsPath
					end
				elseif line:match('^%s*st[0-9]*%s*=') then
					line = line:gsub('%s*;.*$', '')
					if not line:match('=%s*$') then
						line = line:gsub('\\', '/')
						if t['st'] == nil then
							t['st'] = {}
						end
						stPath = dir .. line:gsub('^%s*st[0-9]*%s*=%s*(.-)%s*$', '%1')
						t.st[#t.st + 1] = stPath
					end
				end
		--[ja.Files]
			elseif section == 4 then
				if line:match('^%s*sprite%s*=') then
					line = line:gsub('%s*;.*$', '')
					if not line:match('=%s*$') then
						line = line:gsub('\\', '/')
						sffPath = dir .. line:gsub('^%s*sprite%s*=%s*(.-)%s*$', '%1')
						t['sffjp'] = sffPath
					end
				elseif line:match('^%s*sound%s*=') then
					line = line:gsub('%s*;.*$', '')
					if not line:match('=%s*$') then
						line = line:gsub('\\', '/')
						sndPath = dir .. line:gsub('^%s*sound%s*=%s*(.-)%s*$', '%1')
						t['sndjp'] = sndPath
					end
				elseif line:match('^%s*anim%s*=') then
					line = line:gsub('%s*;.*$', '')
					if not line:match('=%s*$') then
						line = line:gsub('\\', '/')
						airPath = dir .. line:gsub('^%s*anim%s*=%s*(.-)%s*$', '%1')
						t['airjp'] = airPath
					end
				elseif line:match('^%s*cns%s*=') then
					line = line:gsub('%s*;.*$', '')
					if not line:match('=%s*$') then
						line = line:gsub('\\', '/')
						cnsPath = dir .. line:gsub('^%s*cns%s*=%s*(.-)%s*$', '%1')
						t['cnsjp'] = cnsPath
					end
				elseif line:match('^%s*st[0-9]*%s*=') then
					line = line:gsub('%s*;.*$', '')
					if not line:match('=%s*$') then
						line = line:gsub('\\', '/')
						if t['stjp'] == nil then
							t['stjp'] = {}
						end
						stPath = dir .. line:gsub('^%s*st[0-9]*%s*=%s*(.-)%s*$', '%1')
						t.stjp[#t.stjp + 1] = stPath
					end
				end
		--[Palette Keymap]
			elseif section == 5 then
				--nothing until palletes swap function is implemented
		--[Arcade]
			elseif section == 6 then
			--Load Storyboard Files
				if line:match('^%s*intro%.storyboard%s*=') then
					line = line:gsub('%s*;.*$', '')
					if not line:match('=%s*$') then
						line = line:gsub('\\', '/')
						introPath = dir .. line:gsub('^%s*intro%.storyboard%s*=%s*(.-)%s*$', '%1')
						t['intro'] = introPath
					end
				elseif line:match('^%s*ending%.storyboard%s*=') then
					line = line:gsub('%s*;.*$', '')
					if not line:match('=%s*$') then
						line = line:gsub('\\', '/')
						endingPath = dir .. line:gsub('^%s*ending%.storyboard%s*=%s*(.-)%s*$', '%1')
						t['ending'] = endingPath
					end
			--Load Video Files
				elseif line:match('^%s*intro%.video%s*=') then
					line = line:gsub('%s*;.*$', '')
					if not line:match('=%s*$') then
						line = line:gsub('\\', '/')
						introPath = dir .. line:gsub('^%s*intro%.video%s*=%s*(.-)%s*$', '%1')
						t['intro2'] = introPath
					end
				elseif line:match('^%s*ending%.video%s*=') then
					line = line:gsub('%s*;.*$', '')
					if not line:match('=%s*$') then
						line = line:gsub('\\', '/')
						endingPath = dir .. line:gsub('^%s*ending%.video%s*=%s*(.-)%s*$', '%1')
						t['ending2'] = endingPath
					end
				end
		--[Unlock]
			elseif section == 7 then
				if line:match('^%s*condition%s*=') then
					line = line:gsub('%s*;.*$', '')
					if not line:match('=%s*$') then
						t['UnlockCondition'] = line:gsub('^%s*condition%s*=%s*["]*%s*(.-)%s*["]*%s*$', '%1')
					end
				end
			--Load Storyboard Files for Unlock Screen
				if line:match('^%s*storyboard%s*=') then
					line = line:gsub('%s*;.*$', '')
					if not line:match('=%s*$') then
						line = line:gsub('\\', '/')
						unlockPath = dir .. line:gsub('^%s*storyboard%s*=%s*(.-)%s*$', '%1')
						t['UnlockStoryboard'] = unlockPath
					end
			--Load Video Files for Unlock Screen
				elseif line:match('^%s*video%s*=') then
					line = line:gsub('%s*;.*$', '')
					if not line:match('=%s*$') then
						line = line:gsub('\\', '/')
						unlockPath = dir .. line:gsub('^%s*video%s*=%s*(.-)%s*$', '%1')
						t['UnlockVideo'] = unlockPath
					end
				end
		--[Portraits]
			elseif section == 8 then
			--Load Select Face Icon Portrait Data
				if line:match('^%s*face.portrait.spr%s*=') then
					line = line:gsub('%s*;.*$', '')
					if not line:match('=%s*$') then
						t['faceSpr'] = {line:gsub('^%s*face.portrait.spr%s*=%s*["]*%s*(.-)%s*["]*%s*$', '%1') .. ", 0,0, -1"}
					end
				end
				if line:match('^%s*face.portrait.scale%s*=') then
					line = line:gsub('%s*;.*$', '')
					if not line:match('=%s*$') then
						t['faceSprScale'] = line:gsub('^%s*face.portrait.scale%s*=%s*["]*%s*(.-)%s*["]*%s*$', '%1')
					end
				end
			--Load Select Big Portrait Data
				if line:match('^%s*select.portrait.spr%s*=') then
					line = line:gsub('%s*;.*$', '')
					if not line:match('=%s*$') then
						t['selectSpr'] = {line:gsub('^%s*select.portrait.spr%s*=%s*["]*%s*(.-)%s*["]*%s*$', '%1') .. ", 0,0, -1"}
					end
				end
				if line:match('^%s*select.portrait.scale%s*=') then
					line = line:gsub('%s*;.*$', '')
					if not line:match('=%s*$') then
						t['selectSprScale'] = line:gsub('^%s*select.portrait.scale%s*=%s*["]*%s*(.-)%s*["]*%s*$', '%1')
					end
				end
			--Load Order Select Portrait Data
				if line:match('^%s*order.portrait.spr%s*=') then
					line = line:gsub('%s*;.*$', '')
					if not line:match('=%s*$') then
						t['orderSpr'] = {line:gsub('^%s*order.portrait.spr%s*=%s*["]*%s*(.-)%s*["]*%s*$', '%1') .. ", 0,0, -1"}
					end
				end
				if line:match('^%s*order.portrait.scale%s*=') then
					line = line:gsub('%s*;.*$', '')
					if not line:match('=%s*$') then
						t['orderSprScale'] = line:gsub('^%s*order.portrait.scale%s*=%s*["]*%s*(.-)%s*["]*%s*$', '%1')
					end
				end
			--Load Versus Portrait Data
				if line:match('^%s*vs.portrait.spr%s*=') then
					line = line:gsub('%s*;.*$', '')
					if not line:match('=%s*$') then
						t['vsSpr'] = {line:gsub('^%s*vs.portrait.spr%s*=%s*["]*%s*(.-)%s*["]*%s*$', '%1') .. ", 0,0, -1"}
					end
				end
				if line:match('^%s*vs.portrait.scale%s*=') then
					line = line:gsub('%s*;.*$', '')
					if not line:match('=%s*$') then
						t['vsSprScale'] = line:gsub('^%s*vs.portrait.scale%s*=%s*["]*%s*(.-)%s*["]*%s*$', '%1')
					end
				end
			--Load Winner Portrait Data
				if line:match('^%s*win.portrait.spr%s*=') then
					line = line:gsub('%s*;.*$', '')
					if not line:match('=%s*$') then
						t['winSpr'] = {line:gsub('^%s*win.portrait.spr%s*=%s*["]*%s*(.-)%s*["]*%s*$', '%1') .. ", 0,0, -1"}
					end
				end
				if line:match('^%s*win.portrait.scale%s*=') then
					line = line:gsub('%s*;.*$', '')
					if not line:match('=%s*$') then
						t['winSprScale'] = line:gsub('^%s*win.portrait.scale%s*=%s*["]*%s*(.-)%s*["]*%s*$', '%1')
					end
				end
			--Load Loser Portrait Data
				if line:match('^%s*lose.portrait.spr%s*=') then
					line = line:gsub('%s*;.*$', '')
					if not line:match('=%s*$') then
						t['loseSpr'] = {line:gsub('^%s*lose.portrait.spr%s*=%s*["]*%s*(.-)%s*["]*%s*$', '%1') .. ", 0,0, -1"}
					end
				end
				if line:match('^%s*lose.portrait.scale%s*=') then
					line = line:gsub('%s*;.*$', '')
					if not line:match('=%s*$') then
						t['loseSprScale'] = line:gsub('^%s*lose.portrait.scale%s*=%s*["]*%s*(.-)%s*["]*%s*$', '%1')
					end
				end
			--Load Results Portrait Data
				if line:match('^%s*result.portrait.spr%s*=') then
					line = line:gsub('%s*;.*$', '')
					if not line:match('=%s*$') then
						t['resultSpr'] = {line:gsub('^%s*result.portrait.spr%s*=%s*["]*%s*(.-)%s*["]*%s*$', '%1') .. ", 0,0, -1"}
					end
				end
				if line:match('^%s*result.portrait.scale%s*=') then
					line = line:gsub('%s*;.*$', '')
					if not line:match('=%s*$') then
						t['resultSprScale'] = line:gsub('^%s*result.portrait.scale%s*=%s*["]*%s*(.-)%s*["]*%s*$', '%1')
					end
				end
			--Load Intermission Portrait Data
				if line:match('^%s*intermission.portrait.spr%s*=') then
					line = line:gsub('%s*;.*$', '')
					if not line:match('=%s*$') then
						t['intermissionSpr'] = {line:gsub('^%s*intermission.portrait.spr%s*=%s*["]*%s*(.-)%s*["]*%s*$', '%1') .. ", 0,0, -1"}
					end
				end
				if line:match('^%s*intermission.portrait.scale%s*=') then
					line = line:gsub('%s*;.*$', '')
					if not line:match('=%s*$') then
						t['intermissionSprScale'] = line:gsub('^%s*intermission.portrait.scale%s*=%s*["]*%s*(.-)%s*["]*%s*$', '%1')
					end
				end
		--[???]
			elseif section == 9 then
				--This will avoid error when loading a character with an unknown section declared
			end
			if stPath ~= '' and section ~= 3 and section ~= 4 and section ~= 5 and section ~= 6 and section ~= 7 and section ~= 8 and section ~= 9 then
				break
			end
		end
		defF:close()
	--Extract Character Victory Quotes
		local quotes = false
		local cnsF = nil
		if cnsPath ~= nil and cnsPath ~= '' then cnsF = io.open(cnsPath, 'r') end
		if cnsF ~= nil then
			for line in cnsF:lines() do
				if line:match('"%s*;.*$') then
					line = line:gsub('"%s*;.*$', '"')
				end
				if line:match('^%s*[Xx][Ss][Cc][Aa][Ll][Ee]%s*=') then
					line = line:gsub('%s*;.*$', '')
					t['xscale'] = line:gsub('^%s*[Xx][Ss][Cc][Aa][Ll][Ee]%s*=%s*(.-)%s*$', '%1')
				elseif line:match('^%s*[Yy][Ss][Cc][Aa][Ll][Ee]%s*=') then
					line = line:gsub('%s*;.*$', '')
					t['yscale'] = line:gsub('^%s*[Yy][Ss][Cc][Aa][Ll][Ee]%s*=%s*(.-)%s*$', '%1')
				elseif line:match('^%s*%[%s*[Qq][Uu][Oo][Tt][Ee][Ss]%s*%]') then
					t['quotes'] = {}
					quotes = true
					cnt = 1
				elseif quotes then
					if line:match('^%s*[Vv][Ii][Cc][Tt][Oo][Rr][Yy][0-9]+%s*=') then
						local tmp, tmp2 = line:match('^%s*[Vv][Ii][Cc][Tt][Oo][Rr][Yy]([0-9]+)%s*=%s*"%s*(.-)%s*"%s*$')
						if tmp ~= nil and tmp2 ~= nil then
							t.quotes[cnt] = {}
							t.quotes[cnt]['txt'] = tmp2
							t.quotes[cnt]['num'] = tonumber(tmp)
							cnt = cnt + 1
						end
					elseif line:match('^%s*%[') then
						break
					end
				end
			end
			cnsF:close()
		end
	--Extract Character Anims
		local airF = nil
		if airPath ~= nil and airPath ~= '' then airF = io.open(airPath, 'r') end
		if airF ~= nil then
			for line in airF:lines() do
				line = line:lower()
				line = line:gsub('%s*;.*$', '')
			--Standing Animation [Begin Action 0]
				if line:match('^%s*%[%s*begin%s*action%s*0%s*%]') then
					row = 'stand'
					t[row] = {}
					cnt = 1
			--Win [Begin Action 181]
				elseif line:match('^%s*%[%s*begin%s*action%s*181%s*%]') then
					row = 'win'
					t[row] = {}
					cnt = 1
			--LieDown Hit (stay down) [Begin Action 5080]
				elseif line:match('^%s*%[%s*begin%s*action%s*5080%s*%]') then
					row = 'lieDown'
					t[row] = {}
					cnt = 1
			--Dizzy [Begin Action 5300]
				elseif line:match('^%s*%[%s*begin%s*action%s*5300%s*%]') then
					row = 'dizzy'
					t[row] = {}
					cnt = 1
			--Cheese kill [Begin Action 5950]
				elseif line:match('^%s*%[%s*begin%s*action%s*5950%s*%]') then
					row = 'cheese'
					t[row] = {}
					cnt = 1
				elseif line:match('^%s*%[') then
					row = ''
				elseif row ~= '' then
					if line:match('^%s*[0-9%-]+%s*,%s*[0-9%-]+%s*,%s*[0-9%-]+%s*,%s*[0-9%-]+%s*,%s*[0-9%-]+') then
						t[row][cnt] = line:gsub('^%s*([0-9%-]+%s*,%s*[0-9%-]+%s*,%s*[0-9%-]+%s*,%s*[0-9%-]+%s*,%s*[%-0-9]+).*$', '%1')
						cnt = cnt + 1
					elseif line:match('^%s*loopstart') then
						t[row][cnt] = line:gsub('^%s*(loopstart).*$', '%1')
						cnt = cnt + 1
					end
				end
			end
			airF:close()
		end
		if t['sff'] ~= nil and t['sff'] ~= '' and not f_fileExists(t['sff']) then
			t['critical'] = true
			t['warnReason'] = "missing .sff"
		end
		if t['snd'] ~= nil and t['snd'] ~= '' and not f_fileExists(t['snd']) then
			t['warn'] = true
			if t['warnReason'] == nil then t['warnReason'] = "missing sound" end
			t['snd'] = nil
		end
		if t['air'] ~= nil and t['air'] ~= '' and not f_fileExists(t['air']) then
			t['warn'] = true
			if t['warnReason'] == nil then t['warnReason'] = "missing .air" end
		end
		if t['cns'] ~= nil and t['cns'] ~= '' and not f_fileExists(t['cns']) then
			t['warn'] = true
			if t['warnReason'] == nil then t['warnReason'] = "missing .cns" end
		end
		return
	end
end

function f_forceScanChars()
	if not forceShow then return 0 end
	if t_selChars == nil then return 0 end
	local seen = {}
	local function mark(s)
		if s == nil then return end
		s = string.lower(tostring(s):gsub("\\", "/"):gsub("%.[Dd][Ee][Ff]$", ""))
		s = s:gsub("^chars/", "")
		seen[s] = true
		local leaf = s:match("([^/]+)$")
		if leaf then seen[leaf] = true end
	end
	for i = 1, #t_selChars do
		if t_selChars[i] ~= nil then
			mark(t_selChars[i].char)
			mark(t_selChars[i].def)
		end
	end
	local added = 0
	local function walk(path)
		if lfs.attributes(path, "mode") ~= "directory" then return end
		for item in lfs.dir(path) do
			if item ~= "." and item ~= ".." and item ~= ".keep" then
				local full = path .. "/" .. item
				local mode = lfs.attributes(full, "mode")
				if mode == "directory" then
					walk(full)
				elseif mode == "file" and item:match("%.[Dd][Ee][Ff]$") then
					local rel = full:gsub("\\", "/"):gsub("^%./", "")
					rel = rel:gsub("^chars/", "")
					local key = rel:gsub("%.[Dd][Ee][Ff]$", ""):lower()
					local leaf = key:match("([^/]+)$")
					if seen[key] ~= true and (leaf == nil or seen[leaf] ~= true) then
						local row = #t_selChars + 1
						local label = f_slotLabel(full)
						t_selChars[row] = {
							char = key,
							displayname = label,
							name = label,
							unlock = "true",
							extra = true
						}
						-- keep engine index == row - 1 (WinMUGEN 1:1 cell mapping)
						if (rosterEngineCount or 0) == row - 1 and pcall(addChar, f_engineCharPath(f_charDefPath(t_selChars[row])) or key) then
							t_selChars[row].engineCel = row - 1
							rosterEngineCount = row
						end
						seen[key] = true
						if leaf then seen[leaf] = true end
						added = added + 1
					end
				end
			end
		end
	end
	pcall(walk, "chars")
	if voidDumpActive then pcall(walk, "temp_screenpack/chars") end
	local lf = io.open("save/motif_load.log", "a")
	if lf then
		lf:write("force show scanned extra chars ", tostring(added), "\n")
		lf:close()
	end
	return added
end

function f_slotLabel(path)
	if path == nil then return "" end
	local n = tostring(path):gsub('\\', '/')
	n = n:match('([^/]+)$') or n
	n = n:gsub('%.[Dd][Ee][Ff]$', '')
	return n
end

t_failedChars = t_failedChars or {}

function f_logErrorReport(path, kind, reason)
	local f = io.open("save/error_report.log", "a")
	if f then
		f:write(os.date("%Y-%m-%d %H:%M:%S"), "\t", tostring(kind or "info"), "\t", tostring(path or ""), "\t", tostring(reason or ""), "\n")
		f:close()
	end
end

function f_logFailedChar(path, reason)
	t_failedChars[#t_failedChars + 1] = {path = tostring(path or ""), reason = tostring(reason or "")}
	local f = io.open("save/failed_chars.log", "a")
	if f then
		f:write(tostring(path or ""), "\t", tostring(reason or ""), "\n")
		f:close()
	end
	f_logErrorReport(path, "critical", reason)
end

function f_charWarn(slot, reason)
	if slot == nil then return end
	slot.warn = true
	if slot.warnReason == nil or slot.warnReason == "" then
		slot.warnReason = tostring(reason or "error")
	end
	f_logErrorReport(slot.char or slot.displayname or "?", "warn", reason)
end

function f_fileExists(path)
	if path == nil or path == "" then return false end
	if f_dumpExists and f_dumpExists(path) then return true end
	local f = io.open(path, "r")
	if f == nil then return false end
	f:close()
	return true
end

function f_findStagePath(c)
	if c == nil or c == "" then return nil end
	c = tostring(c):gsub('\\', '/')
	if f_dumpResolve then
		local hit = f_dumpResolve(c)
		if hit then return hit end
		hit = f_dumpResolve("stages/" .. (c:match("([^/]+)$") or c))
		if hit then return hit end
	end
	local tries = { c }
	local def = selectDef
	if def ~= nil and def ~= "" then
		local dir = def:match("^(.*)[/\\]")
		if dir ~= nil then
			tries[#tries + 1] = dir .. "/" .. c
			tries[#tries + 1] = dir .. "/../" .. c
			tries[#tries + 1] = dir .. "/stages/" .. (c:match("([^/]+)$") or c)
		end
	end
	local base = c:match("([^/]+)$") or c
	tries[#tries + 1] = "stages/" .. base
	tries[#tries + 1] = "data/stages/" .. base
	local i = 1
	while i <= #tries do
		if f_fileExists(tries[i]) then return tries[i] end
		i = i + 1
	end
	return nil
end

function f_addStageFile(c)
	if c == nil or c == "" then return nil end
	c = tostring(c):gsub('\\', '/')
	local resolved = f_findStagePath(c) or c
	if t_stageDef[resolved] ~= nil then return t_stageDef[resolved] end
	if t_stageDef[c] ~= nil then return t_stageDef[c] end
	if not f_fileExists(resolved) then return nil end
	if t_selStages == nil then t_selStages = {} end
	if data.includestage == nil then data.includestage = 0 end
	local row = #t_selStages + 1
	t_selStages[row] = {}
	pcall(addStage, resolved)
	data.includestage = data.includestage + 1
	t_selStages[row]['name'] = f_slotLabel(resolved)
	t_selStages[row]['stage'] = resolved
	t_selStages[row]['unlock'] = "true"
	t_stageDef[resolved] = row
	t_stageDef[c] = row
	return row
end

function f_ensureStages()
	if t_selStages == nil then t_selStages = {} end
	if t_stageDef == nil then t_stageDef = {} end
	if data.includestage == nil then data.includestage = 0 end
	if #t_selStages > 0 and data.includestage > 0 then return end
	local fallbacks = {
		"stages/kfm.def",
		"stages/stage0.def",
		"stages/stage0-720.def",
		"stages/stage1.def"
	}
	local i = 1
	while i <= #fallbacks do
		f_addStageFile(fallbacks[i])
		i = i + 1
	end
	if #t_selStages < 1 and lfs ~= nil then
		pcall(function()
			for n in lfs.dir("stages") do
				if n ~= "." and n ~= ".." and string.lower(n):match("%.def$") then
					f_addStageFile("stages/" .. n)
					if data.includestage >= 1 then break end
				end
			end
		end)
	end
	if data.includestage < 1 and #t_selStages > 0 then
		data.includestage = #t_selStages
	end
end

function f_ensureRandomRoster()
	if t_randomChars == nil then t_randomChars = {} end
	if #t_randomChars > 0 then return end
	if t_selChars ~= nil then
		local i = 1
		while i <= #t_selChars do
			local s = t_selChars[i]
			local ch = ""
			if s ~= nil and s.char ~= nil then ch = string.lower(tostring(s.char)) end
			if s ~= nil and s.empty ~= true and ch ~= "" and ch ~= "empty" and ch ~= "blank" and ch ~= "-" and ch ~= "randomselect" then
				t_randomChars[#t_randomChars + 1] = i - 1
			end
			i = i + 1
		end
	end
	if #t_randomChars < 1 then
		t_randomChars[1] = 0
	end
end

function f_peekDisplayName(slot)
	if slot == nil then return "" end
	if slot.nameReady then return slot.displayname or slot.name or "" end
	slot.nameReady = true
	if slot.empty == true then return "" end
	if slot.char == "randomselect" then
		slot.displayname = "Random"
		slot.name = "Random"
		return "Random"
	end
	local def = f_charDefPath(slot)
	if def == nil or def == "randomselect" then return slot.displayname or slot.name or "" end
	local f = io.open(def, "r")
	if f == nil then return slot.displayname or slot.name or "" end
	local sec = ""
	local shown = nil
	local nm = nil
	local n = 0
	for line in f:lines() do
		n = n + 1
		if n > 80 then
			break
		end
		line = tostring(line or ""):gsub("%s*;.*$", "")
		local h = line:match("^%s*%[%s*([^%]]+)%s*%]")
		if h ~= nil then
			sec = string.lower(h)
			if sec ~= "info" and (shown ~= nil or nm ~= nil) then
				break
			end
		elseif sec == "info" then
			local v = line:match("^%s*displayname%s*=%s*(.+)$")
			if v ~= nil then
				shown = v:gsub('^["%s]*(.-)["%s]*$', '%1')
			else
				v = line:match("^%s*name%s*=%s*(.+)$")
				if v ~= nil then
					nm = v:gsub('^["%s]*(.-)["%s]*$', '%1')
				end
			end
		end
	end
	f:close()
	if shown ~= nil and shown ~= "" then
		slot.displayname = shown
		if slot.name == nil or slot.name == "" then slot.name = shown end
	elseif nm ~= nil and nm ~= "" then
		slot.displayname = nm
		slot.name = nm
	end
	return slot.displayname or slot.name or ""
end

function f_charDefPath(slot)
	if slot == nil or slot.char == nil then return nil end
	if slot.char == "randomselect" then return "randomselect" end
	local d = slot.char
	if not d:match("%.[Dd][Ee][Ff]$") then
		if d:find("/") then d = d .. ".def" else d = d .. "/" .. d .. ".def" end
		if not d:match("^%a:[/\\]") and not d:match("^[/\\]") and not d:match("^[Cc]hars/") then
			d = "chars/" .. d
		end
	end
	if f_dumpCharPath and voidDumpActive then
		local dumped = f_dumpCharPath(d)
		if dumped ~= nil then return dumped end
	end
	return d
end

function f_ensureCharParsed(cel)
	local row = (cel or 0) + 1
	local slot = t_selChars and t_selChars[row]
	if slot == nil then return false end
	if slot.empty == true then
		slot.parsed = true
		return false
	end
	local ch = string.lower(tostring(slot.char or ""))
	if ch == "" or ch == "empty" or ch == "blank" or ch == "-" then
		slot.empty = true
		slot.parsed = true
		return false
	end
	if slot.failed then return false end
	if slot.parsed then return true end
	if slot.char == "randomselect" then
		slot.parsed = true
		return true
	end
	local okBind = true
	if f_bindCharRow then
		okBind = pcall(f_bindCharRow, row)
	end
	if not okBind then
		slot.failed = true
		f_logFailedChar(slot.char, "addChar failed")
		slot.parsed = true
		return false
	end
	local def = f_charDefPath(slot)
	if def == nil or def == "randomselect" then
		slot.parsed = true
		return true
	end
	local probe = io.open(def, "r")
	if probe == nil then
		slot.failed = true
		f_logFailedChar(def, "missing .def")
		slot.parsed = true
		return false
	end
	probe:close()
	local ok, err = pcall(f_parseChar, slot, cel)
	if not ok then
		f_charWarn(slot, err)
	elseif slot.critical then
		slot.failed = true
		f_logFailedChar(slot.char or def, slot.warnReason or "critical")
	elseif slot.warn then
		f_charWarn(slot, slot.warnReason or "non-critical error")
	end
	slot.parsed = true
	if f_resolveCharStages then f_resolveCharStages(slot) end
	if f_cacheTouch then f_cacheTouch(row) end
	return not slot.failed
end

function f_resolveCharStages(slot)
	if slot == nil or slot.stage == nil then return end
	if slot.stagesReady then return end
	local j = 1
	while j <= #slot.stage do
		local stagePath = slot.stage[j]
		if type(stagePath) == "number" then
			j = j + 1
		elseif t_stageDef ~= nil and t_stageDef[stagePath] ~= nil then
			slot.stage[j] = t_stageDef[stagePath]
			j = j + 1
		else
			local probe = io.open(stagePath, "r")
			if probe == nil then
				j = j + 1
			else
				probe:close()
				local row = #t_selStages + 1
				t_selStages[row] = {}
				pcall(addStage, stagePath)
				if slot.includestage == nil or slot.includestage == 1 then
					data.includestage = (data.includestage or 0) + 1
				end
				t_selStages[row]['name'] = f_slotLabel(stagePath)
				t_selStages[row]['stage'] = stagePath
				t_stageDef[stagePath] = row
				slot.stage[j] = row
				j = j + 1
			end
		end
	end
	slot.stagesReady = true
end

-- The engine's addChar puts "chars/" in front of any relative path that has
-- a folder in it, so "chars/kfm/kfm.def" would become "chars/chars/kfm/kfm.def".
-- A drive-letter path is left alone.
function f_engineCharPath(def)
	if def == nil then return nil end
	local d = tostring(def):gsub("\\", "/")
	if d:match("^%a:/") then return d end
	if not d:match("%.[Dd][Ee][Ff]$") then return d end
	if voidCwdCache == nil then
		voidCwdCache = false
		if lfs ~= nil and lfs.currentdir ~= nil then
			local ok, dir = pcall(lfs.currentdir)
			if ok and dir ~= nil and dir ~= "" then voidCwdCache = dir end
		end
	end
	local cwd = voidCwdCache or nil
	if cwd ~= nil and cwd ~= "" then
		return (cwd:gsub("\\", "/"):gsub("/$", "")) .. "/" .. d:gsub("^%./", "")
	end
	return (d:gsub("^[Cc]hars/", ""))
end

function f_bindCharRow(row)
	-- WinMUGEN: the cell -> character link is fixed when select.def is read.
	-- No lazy addChar here (that assigned engine slots in hover order).
	local slot = t_selChars and t_selChars[row]
	if slot == nil or slot.failed then return nil end
	if slot.engineCel == nil then
		-- Row added after load without registering (should not happen); register it now
		-- only if it is the next engine slot, so indices stay 1:1.
		if (rosterEngineCount or 0) == row - 1 then
			local def = slot.char
			if def ~= "randomselect" then def = f_engineCharPath(f_charDefPath(slot)) or slot.char end
			if pcall(addChar, def) then
				slot.engineCel = row - 1
				rosterEngineCount = row
			end
		end
	end
	return slot.engineCel
end

function f_fileToEngine(cel)
	if cel == nil or cel < 0 then return -1 end
	local slot = t_selChars and t_selChars[cel + 1]
	if slot == nil or slot.failed then return -1 end -- WinMUGEN cell.char == -1 (empty)
	if slot.engineCel == nil then return -1 end
	return slot.engineCel
end

function f_catEnsureEngine()
	local cat = nil
	if f_catCurrent then cat = f_catCurrent() end
	if cat ~= nil then cat.engineReady = true end
end

function f_drawCharErrorWarn()
	if motifHideGrid and f_catActive and f_catActive() then return end
	local cel = p1Cell
	if cel == nil then return end
	local slot = t_selChars and t_selChars[(cel or 0) + 1]
	if slot == nil or not slot.warn then return end
	if jgFnt == nil then return end
	f_drawQuickText(txt_charErrWarn, jgFnt, 1, 0, "! Character has detected errors, limited functionality.", 159, 228, 0.4, 0.4)
end

do
	local nativeName = getCharName
	local nativeFile = getCharFileName
	local nativeFace = drawFace
	local nativePort = drawPortrait
	local nativeSel = selectChar
	function getCharName(cel)
		local slot = t_selChars and t_selChars[(cel or 0) + 1]
		if slot == nil then return "" end
		if slot.empty == true then return "" end
		local ch = string.lower(tostring(slot.char or ""))
		if ch == "" or ch == "empty" or ch == "blank" or ch == "-" then return "" end
		if slot.failed then return slot.displayname or slot.name or "" end
		if slot.char == "randomselect" then return "Random" end
		-- MUGEN Purity: no file I/O here. slot.displayname is the folder name
		-- set at parse time. The real [Info] name loads lazily via void.name_lazy
		-- hook for cursor cells only (one open/frame max).
		return slot.displayname or slot.name or ""
	end
	function getCharFileName(cel)
		local slot = t_selChars and t_selChars[(cel or 0) + 1]
		if slot == nil or slot.empty == true then return "" end
		local d = f_charDefPath(slot)
		if d ~= nil then return d end
		return ""
	end
	function drawFace(x, y, offset)
		if motifHideGrid then return end
		-- MUGEN Purity: only stream SFF portraits for cursor cells (lazy portrait loading).
		-- voidPortraitCells is populated each frame by void.portrait_lazy hook.
		local off = offset or 0
		if voidPortraitCells ~= nil and not voidPortraitCells[off] then return end
		pcall(nativeFace, x, y, off)
	end
	function drawPortrait(n, x, y, xs, ys)
		if f_packCaptureFace and f_packCaptureFace(n, x) then return end
		local slot = t_selChars and t_selChars[(n or 0) + 1]
		if slot ~= nil and slot.failed then return end
		if slot ~= nil and slot.empty == true then return end
		n = f_fileToEngine(n)
		if n == nil or n < 0 then return end
		local ok
		if ys ~= nil then
			ok = pcall(nativePort, n, x, y, xs, ys)
		elseif xs ~= nil then
			ok = pcall(nativePort, n, x, y, xs)
		else
			ok = pcall(nativePort, n, x, y)
		end
		if not ok and slot ~= nil then
			f_charWarn(slot, "portrait load failed")
		end
	end
	function selectChar(player, cel, pal)
		local slot = t_selChars and t_selChars[(cel or 0) + 1]
		if slot ~= nil and slot.failed then return end
		if f_perfCompileOnSelect() and f_ensureCharParsed then f_ensureCharParsed(cel) end
		slot = t_selChars and t_selChars[(cel or 0) + 1]
		if slot ~= nil and (slot.failed or slot.empty == true) then return end
		local eng = f_fileToEngine(cel)
		if eng == nil or eng < 0 then return end
		pcall(nativeSel, player, eng, pal)
	end
end

rosterReady = false
rosterEngineCount = 0
t_gen = {}
generate = false
batch = 'mkdir data\\charAnim\nmkdir debug'
t_selChars = {}
t_selStages = {}
t_selOptions = {}
t_orderChars = {}
t_charDef = {}
t_stageDef = {}
t_trainingChar = {}
t_tutorialChar = {}
t_bossChars = {}
t_bonusChars = {}
t_randomChars = {}
t_randomTourneyChars = {}
t_intermissionChars = {}
data.includestage = 0

function f_loadSelectDef()
if rosterReady then return true end
-- VOID roster cache: skip full parse if select.def hasn't changed
if not _voidRosterCache then
	local ok, mod = pcall(require, "script.void_roster_cache")
	_voidRosterCache = ok and mod or false
end
local _cacheData = nil
if _voidRosterCache then
	local _ok, _result = pcall(_voidRosterCache.load, selectDef)
	if _ok and type(_result) == "table" and _result.chars then
		_cacheData = _result
	end
end
if _cacheData then
	-- Cache hit: replay addChar here in loader.lua where Go functions are visible
	local chars = _cacheData.chars
	if type(clog)=="function" then clog("[VOID cache] HIT - replaying " .. #chars .. " entries") else print("[VOID cache] HIT - replaying " .. #chars .. " entries") end
	t_selChars = {}
	t_charDef  = t_charDef  or {}
	t_orderChars = t_orderChars or {}
	for i = 1, #chars do
		local s = chars[i]
		t_selChars[i] = s
		if s.empty or s.failed or s.char == "empty" or s.char == "" then
			pcall(addChar, "empty")
		else
			local addPath = s._addPath or s.char
			local ok2 = pcall(addChar, addPath)
			if not ok2 then pcall(addChar, "empty") end
		end
		if s.char and s.char ~= "" and s.char ~= "empty" then
			t_charDef[s.char] = (s.engineCel or (i - 1))
		end
		if s.order and not s.empty and s.char ~= "empty" then
			if t_orderChars[s.order] == nil then t_orderChars[s.order] = {} end
			t_orderChars[s.order][#t_orderChars[s.order] + 1] = (s.engineCel or (i - 1))
		end
	end
	rosterEngineCount = _cacheData.roster_count or #chars
	if type(clog)=="function" then clog("[VOID cache] restored " .. rosterEngineCount .. " roster slots") else print("[VOID cache] restored " .. rosterEngineCount .. " roster slots") end
	if f_selOptionDefaults then f_selOptionDefaults() end
	f_generateUnlocks()
	if f_ensureStages then f_ensureStages() end
	if f_ensureRandomRoster then f_ensureRandomRoster() end
	if f_padSelectGrid then f_padSelectGrid() end
	if f_forceShowRebuild then f_forceShowRebuild() end
	if f_classicParse then f_classicParse() end
	if f_catPreview then f_catPreview() end
	if f_loadTowers then f_loadTowers(true) end
	rosterReady = true
	return true
end
--;===========================================================
--; LOADING SCREEN 1 (LOAD SELECT.DEF DATA)
--;===========================================================
data.includestage = 0
rosterEngineCount = 0
t_failedChars = {}
local failLog = io.open("save/failed_chars.log", "w")
if failLog then
	failLog:write("path\treason\n")
	failLog:close()
end
local errLog = io.open("save/error_report.log", "w")
if errLog then
	errLog:write("time\tkind\tpath\treason\n")
	errLog:close()
end
t_orderChars = {}
t_charDef = {}
t_stageDef = {}
local section = 0
local row = 0
local file = io.open(selectDef,"r")
if file == nil then return false end
-- (huge-roster "textRoster" lazy binding removed: see VOID_HugeRoster_WinMUGEN_Fix.md)
voidMissingChars = {}
-- Infinite-loop guard: if the select.def parser sees more than _VOID_EMPTY_STREAK
-- consecutive blank/empty/- entries in a row, it stops reading [Characters].
-- This kills the wildcard-expansion / grid-padding loop that inflates the roster
-- counter to 52,880+. Real huge rosters have real character names mixed in, so
-- 1000 consecutive blanks means we've left the real roster behind.
local _consEmpty = 0
local _VOID_EMPTY_STREAK = 1000
-- Time-gate: track last refresh() timestamp so GPU buffer swaps don't throttle
-- the parse loop for large select.def files. The old code called refresh() every
-- 80 rows, meaning 661 GPU flushes for a 52,880-line file (~10 s of overhead).
-- Now we refresh at most every 150 ms regardless of row count.
local _lastRefreshClock = 0
for rawLine in file:lines() do
	local line = tostring(rawLine or "")
	line = line:gsub('%s*;.*$', "")
	line = line:gsub('^%s+', ""):gsub('%s+$', "")
	if line == "" then
	elseif #line > 4096 then
		f_logErrorReport(selectDef, "select", "skipped overlong line")
	else
	line = line:lower()
	if line:match('^%s*%[%s*characters%s*%]') then
		t_selChars = {}
		section = 1
		row = 0
	elseif line:match('^%s*%[%s*extrastages%s*%]') then
		t_selStages = {}
		section = 2
	elseif line:match('^%s*%[%s*options%s*%]') then
		t_selOptions = {}
		section = 3
--[Characters]
	elseif section == 1 then
		row = row + 1
		-- Lazy proxy stub: allocate minimal slot; heavy metadata (stages, music,
		-- arcade routes) is written into the same table by the CSV parser below.
		-- The setmetatable guard ensures future reads of unset keys return nil
		-- cleanly without triggering any preload logic.
		t_selChars[row] = {}
		for i, c in ipairs(strsplit(',', line)) do
			c = c:gsub('^%s*(.-)%s*$', '%1')
		--charname = path
			if i == 1 then
				c = c:gsub('\\', '/')
				c = tostring(c)
				t_selChars[row]['char'] = c
				t_selChars[row]['unlock'] = "true" --character unlocked by default
				--t_selChars[row]['intermissionSpr'] = {"9000,9, 0,0, -1"}
				t_selChars[row]['engineCel'] = nil
				local low = string.lower(c)
				-- Wildcard/padding overflow guard: count consecutive blank-looking entries.
				-- 1000+ in a row = padding or runaway wildcard expansion; halt the loop.
				if c == "" or low == "empty" or low == "blank" or low == "-" or low == "randomselect" then
					_consEmpty = (_consEmpty or 0) + 1
					if _consEmpty > _VOID_EMPTY_STREAK then
						clog("roster-ceil: " .. _consEmpty .. " consecutive empty/blank slots ending at row " .. row .. " -- wildcard/padding loop halted")
						file:close()
						goto f_loadSelectDef_done
					end
				else
					_consEmpty = 0
				end
				-- VOID huge-roster fix (WinMUGEN FUN_0040cf80): every select.def entry is
				-- registered now, in file order, so engine index == row - 1 forever.
				-- Native addChar does no file I/O, so this is cheap even for 8000+ rows.
				if c == "" or low == "empty" or low == "blank" or low == "-" then
					t_selChars[row]['char'] = "empty"
					t_selChars[row]['empty'] = true
					t_selChars[row]['displayname'] = ""
					t_selChars[row]['name'] = ""
					pcall(addChar, "empty")
				else
					local addPath = c
					-- WinMUGEN (FUN_0040cf80): if the character's .def can't be opened,
					-- the cell stays empty (-1). It is not part of the roster, so
					-- arcade / random never pick it.
					local exists = true
					if f_dumpCharPath and voidDumpActive then
						local found = f_dumpCharPath(c)
						if found == nil or found == c then
							exists = false
							if c:match("%.[Dd][Ee][Ff]$") then
								local probe = io.open(c, "r")
								if probe then probe:close() exists = true end
							end
						end
						if exists then addPath = f_engineCharPath(found) or c end
					end
					if not exists then
						t_selChars[row]['char'] = "empty"
						t_selChars[row]['empty'] = true
						t_selChars[row]['missing'] = c
						t_selChars[row]['displayname'] = ""
						t_selChars[row]['name'] = ""
						pcall(addChar, "empty")
						voidMissingChars[#voidMissingChars + 1] = c
					else
						local okAdd = pcall(addChar, addPath)
						if not okAdd then
							pcall(addChar, "empty") -- keep the slot so later indices never shift
							f_logFailedChar(addPath, "addChar failed")
							t_selChars[row]['failed'] = true
						else
							t_selChars[row]['_addPath'] = addPath -- saved for void_roster_cache
						end
					end
				end
				t_selChars[row]['engineCel'] = row - 1
				rosterEngineCount = row
				t_charDef[c] = row - 1
		--unlock = lua condition
			elseif c:match('unlock%s*=%s*') then
				local unlockData = c:match('^unlock%s*=%s*(.-)%s*$')
				t_selChars[row]['unlock'] = unlockData
		--music = path
			elseif c:match('music%s*=%s*') then
				c = c:gsub('\\', '/')
				local bgmvolume = c:match('%s([0-9]+)$')
				if bgmvolume == nil then
					bgmvolume = 100
				else
					bgmvolume = tonumber(bgmvolume)
					c = c:gsub('%s*[0-9]+$','')
				end
				local bgmusic = c:match('^music%s*=%s*(.-)%s*$')
				if t_selChars[row]['music'] == nil then
					t_selChars[row]['music'] = {}
				end
				t_selChars[row].music[#t_selChars[row].music + 1] = {}
				t_selChars[row].music[#t_selChars[row].music]['bgmusic'] = bgmusic
				t_selChars[row].music[#t_selChars[row].music]['bgmvolume'] = bgmvolume
		--1, 2, (...)/Arcade Route = charname
			elseif c:match('[0-9]+%s*=%s*[^%s]') then
				local var1, var2 = c:match('([0-9]+)%s*=%s*(.+)%s*$')
				t_selChars[row][tonumber(var1)] = var2:lower()
		--stages/mybg.def
			elseif c:match('%.[Dd][Ee][Ff]') then
				c = c:gsub('\\', '/')
				if t_selChars[row]['stage'] == nil then
					t_selChars[row]['stage'] = {}
				end
				t_selChars[row].stage[#t_selChars[row].stage + 1] = c
		--Extra Paramvalues
			else
				local param, value = c:match('^(.-)%s*=%s*(.-)$')
				if param ~= nil and param ~= '' and t_selChars[row] ~= nil then
					t_selChars[row][param] = tonumber(value)
				end
			end
		end
		local slot = t_selChars[row] and t_selChars[row]['char']
		if slot ~= nil then
			local n = f_slotLabel(slot)
			t_selChars[row]['displayname'] = n
			t_selChars[row]['name'] = n
		else
			t_selChars[row]['char'] = "empty"
			t_selChars[row]['displayname'] = ""
			t_selChars[row]['name'] = ""
			t_selChars[row]['empty'] = true
			if t_selChars[row]['engineCel'] == nil then
				pcall(addChar, "empty")
				t_selChars[row]['engineCel'] = row - 1
				rosterEngineCount = row
			end
		end
	--force order entry
		if t_selChars[row] ~= nil then
		local tmp = t_selChars[row].char
		if tmp ~= nil and tmp ~= '' and tmp ~= 'randomselect' and tmp ~= 'empty' and t_selChars[row].empty ~= true and t_selChars[row].name ~= '"Training"' then
		--Arcade Order
			if t_selChars[row].order == nil then
				t_selChars[row]['order'] = 1 --Add order 1 is order paramvalue is not detected
			end
			if t_orderChars[t_selChars[row].order] == nil then
				t_orderChars[t_selChars[row].order] = {}
			end
			t_orderChars[t_selChars[row].order][#t_orderChars[t_selChars[row].order] + 1] = row - 1
		end
		end
--[ExtraStages]
	elseif section == 2 then
		textImgSetText(txt_loading, "REGISTERING STAGES...")
		row = #t_selStages + 1
		for i, c in ipairs(strsplit(',', line)) do
			c = c:gsub('^%s*(.-)%s*$', '%1')
			local exists = false
			if i == 1 then
				c = c:gsub('\\', '/')
				local resolved = f_findStagePath(c)
				if resolved == nil then
					-- missing ExtraStages file - keep reading; f_ensureStages fills a fallback later
				else
				t_selStages[row] = {}
				pcall(addStage, resolved)
				data.includestage = data.includestage + 1
				t_selStages[row]['name'] = f_slotLabel(resolved)
				t_selStages[row]['stage'] = resolved
				t_selStages[row]['unlock'] = "true"
				t_stageDef[resolved] = row
				t_stageDef[c] = row
				end
		--unlock = lua condition
			elseif t_selStages[row] == nil then
			elseif c:match('unlock%s*=%s*') then
				local unlockData = c:match('^unlock%s*=%s*(.-)%s*$')
				t_selStages[row]['unlock'] = unlockData
		--music = path
			elseif c:match('music%s*=%s*') then
				c = c:gsub('\\', '/')
				local bgmvolume = c:match('%s([0-9]+)$')
				if bgmvolume == nil then
					bgmvolume = 100
				else
					bgmvolume = tonumber(bgmvolume)
					c = c:gsub('%s*[0-9]+$','')
				end
				local bgmusic = c:match('^music%s*=%s*(.-)%s*$')
				if t_selStages[row]['music'] == nil then
					t_selStages[row]['music'] = {}
				end
				t_selStages[row].music[#t_selStages[row].music + 1] = {}
				t_selStages[row].music[#t_selStages[row].music]['bgmusic'] = bgmusic
				t_selStages[row].music[#t_selStages[row].music]['bgmvolume'] = bgmvolume
		--Extra Paramvalues
			else
				local param, value = c:match('^(.-)%s*=%s*(.-)$')
				if param ~= nil and param ~= '' and t_selStages[row] ~= nil then
					t_selStages[row][param] = tonumber(value)
				end
			end
		end
--[Options]
	elseif section == 3 then
		textImgSetText(txt_loading, "LOADING ARCADE SETTINGS...")
		if line:match('^%s*.-%.maxmatches%s*=%s*') then
			local rowName, line = line:match('^%s*(.-)%.maxmatches%s*=%s*(.+)')
			if rowName ~= nil and line ~= nil then
				t_selOptions[rowName .. 'maxmatches'] = {}
				for i, c in ipairs(strsplit(',', line:gsub('%s*(.-)%s*', '%1'))) do
					t_selOptions[rowName .. 'maxmatches'][i] = tonumber(c)
				end
			end
		elseif line:match('^%s*.-%.airamp%..-%s*=%s*') then
			local rowName, rowName2, wins, offset = line:match('^%s*(.-)%.airamp%.(.-)%s*=%s*([0-9]+)%s*,%s*([0-9-]+)')
			t_selOptions[rowName .. rowName2] = {}
			t_selOptions[rowName .. rowName2]['wins'] = tonumber(wins)
			t_selOptions[rowName .. rowName2]['offset'] = tonumber(offset)
		end
	end
	if row == nil then row = 0 end
	-- Time-gated refresh: update screen at most every 150 ms.
	-- Replaces the old every-80-row refresh() that caused ~661 GPU flushes for a
	-- 52,880-line select.def, adding ~10 seconds of pure buffer-swap overhead.
	do
		local _now = os.clock()
		if _now - _lastRefreshClock >= 0.15 then
			_lastRefreshClock = _now
			if section == 1 then
				textImgSetText(txt_loading, "LOADING CHARACTERS... " .. row)
			end
			textImgDraw(txt_loading)
			refresh()
		end
	end
	end
end
::f_loadSelectDef_done::
file:close()
do
	local mf = io.open("save/missing_chars.log", "w")
	if mf then
		mf:write("select.def entries with no character installed (empty cells, never picked): ", #voidMissingChars, "\n")
		for i = 1, #voidMissingChars do mf:write(voidMissingChars[i], "\n") end
		mf:close()
	end
end
if f_selOptionDefaults then f_selOptionDefaults() end
--end_time = os.time()
--elapsed_time = os.difftime(end_time - start_time)
--f_printVar(elapsed_time)

function f_charAnim(t, compare, add)
	local ret = ''
	if t ~= nil then
		for i=1, #t do
			if t[i]:match('^%s*[0-9]+%s*,%s*[0-9]+%s*,.+$') then
				if compare:match('^%s*' .. t[i]:gsub('^%s*([0-9]+)%s*,.+$', '%1') .. '%s*,%s*' .. t[i]:gsub('^%s*[0-9]+%s*,%s*([0-9]+)%s*,.+$', '%1') .. '%s*,%s*') then
					ret = ret .. '\n' .. compare
				end
			end
		end
	end
	return ret
end
--;====================================================================================
--; LOADING SCREEN 2 (STORE CHARACTER DATA BASED ON PREVIOUS LOADED FROM SELECT.DEF)
--;====================================================================================
local sff2png = [[
[Output]
 ;Filename of the SFF file to create (required).
;filename = 

[Option]
input.dir =
sprite.compress.5 = lz5 ;none/lz5/rle5
sprite.compress.8 = png8 ;none/rle8/png8
sprite.compress.24 = png24 ;none/png24
sprite.compress.32 = png32 ;none/png32
sprite.decompressonload = 0 ;0/1
sprite.detectduplicates = 0 ;0/1
sprite.autocrop = 1 ;0/1
pal.detectduplicates = 1 ;0/1
pal.discardduplicates = 1 ;0/1

[Pal]
;Enter pals here (png or act files)
;0,0, filename.png, 0,255 ;grp,idx, fname, startcol,endcol

[Option]
sprite.usepal = -1 ;Set this to the right pal

[Sprite]
]]
generate = false
name = ''
batch = 'mkdir data\\charAnim\nmkdir debug'
t_gen = {}
t_trainingChar = {}
t_tutorialChar = {}
t_bossChars = {}
t_bonusChars = {}
t_randomChars = {}
t_randomTourneyChars = {}
t_intermissionChars = {}
if t_selChars ~= nil then
--for each character loaded
	for i=1, #t_selChars do
		if t_selChars[i] == nil then
			-- skip nil slots
		elseif t_selChars[i].empty == true then
			-- Lazy stub: empty/blank/randomselect cells carry no metadata.
			-- Skip all processing for them to avoid 52,000+ iterations of no-op
			-- table lookups on heavily-padded select.def files.
		else
		if t_selChars[i].stage ~= nil and not voidNativeGrid then
			if f_resolveCharStages then f_resolveCharStages(t_selChars[i]) end
		end
	--if character's name has been stored
		if t_selChars[i].displayname ~= nil then
			local charCel = i - 1
		--generate table for fixed training character
			if t_selChars[i].training ~= nil and t_selChars[i].training == 1 then
				t_trainingChar[#t_trainingChar + 1] = charCel
			end
		--generate table for fixed tutorial character
			if t_selChars[i].tutorial ~= nil and t_selChars[i].tutorial == 1 then
				t_tutorialChar[#t_tutorialChar + 1] = charCel
			end
		--detects stage viewer character
			if t_selChars[i].name == "stage viewer" then
				stageviewer = true
			end
		--generate table for boss rush mode
			if t_selChars[i].boss ~= nil and t_selChars[i].boss == 1 then
				t_bossChars[#t_bossChars + 1] = charCel
			end
		--generate table for bonus games mode
			if t_selChars[i].bonus ~= nil and t_selChars[i].bonus == 1 then
				t_bonusChars[#t_bonusChars + 1] = charCel
			end
		--generate table with characters allowed to be random selected
			local ch = string.lower(tostring(t_selChars[i].char or ""))
			if t_selChars[i].empty ~= true and ch ~= "empty" and ch ~= "blank" and ch ~= "-" and ch ~= "randomselect" then
				if t_selChars[i].exclude == nil or t_selChars[i].exclude == 0 then
					t_randomChars[#t_randomChars + 1] = charCel
				end
			end
		--generate table with characters allowed to be random selected in tournament mode
			if t_selChars[i].excludetourney == nil or t_selChars[i].excludetourney == 0 then
				t_randomTourneyChars[#t_randomTourneyChars + 1] = charCel
			end
		--generate table for intermissions
			if t_selChars[i].intermission ~= nil and t_selChars[i].intermission == 1 then
				t_intermissionChars[#t_intermissionChars + 1] = {['cel'] = charCel, ['name'] = t_selChars[i].name, ['displayname'] = t_selChars[i].displayname, ['author'] = t_selChars[i].author, ['path'] = t_selChars[i].char}
			end
		--create variable with character's name, whitespace replaced with underscore
			if t_selChars[i].name == nil then
				t_selChars[i].name = t_selChars[i].displayname
			end
			if t_selChars[i].name == nil or t_selChars[i].sff == nil then
				-- skip anim table generation for incomplete roster slots
			elseif not f_perfPreloadPortraits() then
				-- preload_portraits=0: stream faces on demand, do not build every sff/anim now
			else
			displayname = t_selChars[i].name:gsub('%s+', '_')
		--if data/charAnim/displayname.def doesn't exist
			--local charAnimPath = t_selChars[i].ikanim --chars/charName/
			--local charAnimPathWin = t_selChars[i].ikanim:gsub('/', '\\') --this convert chars/charName/ to chars\\charName\\
			if io.open('data/charAnim/' .. displayname .. '.def','r') == nil then
			--create a batch variable used to create 'data/charTrash/charName' folder and to extract all character's sprites there
				batch = batch .. '\n' .. 'mkdir "data\\charTrash\\' .. displayname .. '"' .. '\n' .. 'tools\\sff2png.exe "' .. t_selChars[i].sff:gsub('/+', '\\') .. '" "data\\charTrash\\' .. displayname .. '\\s"'
			--store character's reference that needs conversion into table to save time later on
				t_gen[#t_gen + 1] = i
			--enable sprite generation later on
				generate = true
		--otherwise load SFF file generated
			else
				t_selChars[i]['sffData'] = sffNew('data/charAnim/' .. displayname .. '.sff')
				--t_selChars[i]['sffData'] = sffNew(t_selChars[i].sff) --Load data from original character.sff (Not recommended because will increase RAM Usage)
				if t_selChars[i].stand ~= nil then
					t_selChars[i]['p1AnimStand'] = f_animFromTable(t_selChars[i].stand, t_selChars[i].sffData, 30, 150, t_selChars[i].xscale, t_selChars[i].yscale, 0, 1)
					t_selChars[i]['p2AnimStand'] = f_animFromTable(t_selChars[i].stand, t_selChars[i].sffData, 30, 150, t_selChars[i].xscale, t_selChars[i].yscale, 'H', 1)
				end
				if t_selChars[i].win ~= nil then
					t_selChars[i]['p1AnimWin'] = f_animFromTable(t_selChars[i].win, t_selChars[i].sffData, 30, 150, t_selChars[i].xscale, t_selChars[i].yscale, 0, 1)
					t_selChars[i]['p2AnimWin'] = f_animFromTable(t_selChars[i].win, t_selChars[i].sffData, 30, 150, t_selChars[i].xscale, t_selChars[i].yscale, 'H', 1)
				end
				if t_selChars[i].cheese ~= nil then
					t_selChars[i]['p1AnimCheese'] = f_animFromTable(t_selChars[i].cheese, t_selChars[i].sffData, 30, 150, t_selChars[i].xscale, t_selChars[i].yscale, 0, 1)
					t_selChars[i]['p2AnimCheese'] = f_animFromTable(t_selChars[i].cheese, t_selChars[i].sffData, 30, 150, t_selChars[i].xscale, t_selChars[i].yscale, 'H', 1)
				end
				if t_selChars[i].lieDown ~= nil then
					t_selChars[i]['p1AnimLieDown'] = f_animFromTable(t_selChars[i].lieDown, t_selChars[i].sffData, 30, 150, t_selChars[i].xscale, t_selChars[i].yscale, 0, 1)
					t_selChars[i]['p2AnimLieDown'] = f_animFromTable(t_selChars[i].lieDown, t_selChars[i].sffData, 30, 150, t_selChars[i].xscale, t_selChars[i].yscale, 'H', 1)
				end
				if t_selChars[i].dizzy ~= nil then
					t_selChars[i]['p1AnimDizzy'] = f_animFromTable(t_selChars[i].dizzy, t_selChars[i].sffData, 30, 150, t_selChars[i].xscale, t_selChars[i].yscale, 0, 1)
					t_selChars[i]['p2AnimDizzy'] = f_animFromTable(t_selChars[i].dizzy, t_selChars[i].sffData, 30, 150, t_selChars[i].xscale, t_selChars[i].yscale, 'H', 1)
				end
				if t_selChars[i].intermissionSpr ~= nil then
					t_selChars[i]['p1IntermissionPortrait'] = f_animFromTable(t_selChars[i].intermissionSpr, t_selChars[i].sffData, 30, 150, t_selChars[i].xscale, t_selChars[i].yscale, 0, 1)
					t_selChars[i]['p2IntermissionPortrait'] = f_animFromTable(t_selChars[i].intermissionSpr, t_selChars[i].sffData, 30, 150, t_selChars[i].xscale, t_selChars[i].yscale, 'H', 1)
				end
				textImgSetText(txt_loading, "GENERATING CHARS TABLES...")
				textImgDraw(txt_loading)
				refresh()
			end
			end
		end
		end
	end
end
if f_ensureStages then f_ensureStages() end
if f_ensureRandomRoster then f_ensureRandomRoster() end
if f_forceShowRebuild then f_forceShowRebuild() end
if f_classicParse then f_classicParse() end
if f_catPreview then f_catPreview() end
if f_loadTowers then f_loadTowers(true) end
if f_perfPreloadPortraits() and f_perfBackgroundLoading() and f_runSpriteConversion then f_runSpriteConversion() end
-- VOID roster cache: persist resolved paths so next boot skips this parse
if _voidRosterCache and _voidRosterCache ~= false then
	pcall(_voidRosterCache.write, selectDef, t_selChars, rosterEngineCount)
end
rosterReady = true
return true
end
--;===========================================================
--; LOAD SELECT.DEF TOWER DATA
--;===========================================================
function f_loadTowers(bool)
--The loading of the towers should be after generate t_randomChars table to more comfortably add randomselect combats using that table..
t_selTower = {} --Here to avoid issues if you don?t declare [TowerMode] section in select.def
local loadingScreen = bool or false --To manage loading screen
local section = 0
local file = io.open(selectDef,"r")
if file == nil then return end
local content = file:read("*all")
file:close()
content = content:gsub('([^\r\n]*)%s*;[^\r\n]*', '%1')
content = content:gsub('\n%s*\n', '\n')
	for line in content:gmatch('[^\r\n]+') do
		line = line:lower()
		if line:match('^%s*%[%s*towermode%s*%]') then
			section = 1
	--[TowerMode]
		elseif section == 1 then
			if line:match('^%s*sfx.announcer%s*=') then
				t_selTower['data'] = {}
				local data = line:gsub('%s*;.*$', '')
				if not data:match('=%s*$') then
					t_selTower['data']['sfxannouncer'] = data:gsub('^%s*sfx.announcer%s*=%s*["]*%s*(.-)%s*["]*%s*$', '%1')
				end
			end
			if line:match('^%s*%[%s*[Tt][Oo][Ww][Ee][Rr]%s+[0-9]+$*%]') then
				row = #t_selTower + 1
				t_selTower[row] = {}
				t_selTower[row]['kombats'] = {}
			end
			if line:match('^%s*displayname%s*=') then
				local data = line:gsub('%s*;.*$', '')
				if not data:match('=%s*$') then
					t_selTower[row]['ID'] = textImgNew()
					t_selTower[row]['displayname'] = data:gsub('^%s*displayname%s*=%s*["]*%s*(.-)%s*["]*%s*$', '%1')
				end
			end
			if line:match('^%s*sfx%s*=') then
				local data = line:gsub('%s*;.*$', '')
				if not data:match('=%s*$') then
					t_selTower[row]['sfxplay'] = data:gsub('^%s*sfx%s*=%s*["]*%s*(.-)%s*["]*%s*$', '%1')
				end
			end
			if line:match('[0-9]+%s*=%s*[^%s]') then
				local var1, var2 = line:match('([0-9]+)%s*=%s*(.+)%s*$')
				--t_selTower[row]['kombats'][tonumber(var1)] = var2:lower() --store chars name
				if var2:lower() == "randomselect" then --if there is a random char detected on a tower floor
					t_selTower[row]['kombats'][tonumber(var1)] = var2:lower() --store "randomselect" name 
				else
					t_selTower[row]['kombats'][tonumber(var1)] = t_charDef[var2] --instead of store chars name, save from t_selChars "cel" value that will be used to make roster and battle plan stuff
				end
			end
		end
	end
--Set random chars
	for k,v in ipairs(t_selTower) do --For each item stored in t_selTower
		for i, val in ipairs(v.kombats) do --For each subtable [kombats]
			if val == "randomselect" then --If the char stored is randomselect
				local randomChar = f_pickRandom(t_randomChars, 0) --t_randomChars table will be used to replace randomselect slot. (In online mode this random logic will cause desync if is not loaded in real time)
				while f_tableContains(v.kombats, randomChar) do --if random char selected matches one stored
					if #t_randomChars < 1 or #v.kombats > #t_randomChars then --if tower size loaded exceed number of characters stored in t_randomChars then break to avoid infinite loop.
						--table.remove(v.kombats, i)
						break
					end
					randomChar = f_pickRandom(t_randomChars, 0) --randomizes again
				end
				v.kombats[i] = randomChar --store/replace randomselect with random char cel
			end
		end
		v.kombats = f_delRepeated(v.kombats) --get final towers without characters repeated
	end
	if data.debugLog then f_printTable(t_selTower, "save/debug/t_selTower.log") end
	if loadingScreen then
		textImgSetText(txt_loading, "LOADING TOWERS...")
		textImgDraw(txt_loading)
		refresh()
	end
end

function f_loadLicenses()
local file = f_fileRead("LICENSE.txt")
f_fileWrite(licensesPath.."/I.K.E.M.E.N..txt", file)
t_licenseList = {}
	for file in lfs.dir(licensesPath) do
		if file:match('^.*(%.)[Tt][Xx][Tt]$') then
			row = #t_licenseList + 1
			t_licenseList[row] = {}
			t_licenseList[row]['id'] = ''
			t_licenseList[row]['name'] = file:gsub('^(.*)[%.][Tt][Xx][Tt]$', '%1')
			t_licenseList[row]['path'] = licensesPath.."/"..file
			t_licenseList[row]['content'] = f_txtLoad(licensesPath.."/"..file)
		end
	end
	if data.debugLog then f_printTable(t_licenseList, "save/debug/t_licenseList.log") end
end
f_loadLicenses()
--;===========================================================
--; SPRITE CONVERSION SCREEN
--;===========================================================
t_gen = t_gen or {}
generate = generate or false
txt_parserWarning = createTextImg(jgFnt, 0, 0, "WARNING", 159, 13)
t_parserText = {
	{text = #t_gen .. " new character(s) detected."},
	{text = "In order to improve loading times and memory usage"},
	{text = "some sprites needs to be extracted and repacked with"},
	{text = "external Elecbyte tools (sff2png.exe and sprmake2.exe)"},
	{text = ""},
	{text = "This can be done automatically but will take some time."},
	{text = "More information is available in the readme file."},
	{text = ""},
	{text = "Would you like to start the conversion?"},
}
for i=1, #t_parserText do
	t_parserText[i]['id'] = createTextImg(font2, 0, 1, t_parserText[i].text, 25, 15 + i * 15)
end
t_parserOptions = {
	{text = "Yes, do it now."},
	{text = "No, skip it this time."},
	--{text = "No, disable SFF building permanently."},
}
for i=1, #t_parserOptions do
	t_parserOptions[i]['id'] = createTextImg(font2, 0, 1, t_parserOptions[i].text, 25, 165 + i * 15)
end

function f_runSpriteConversion()
if t_gen == nil then t_gen = {} end
if not generate or not data.sffConversion then return end
if t_parserText ~= nil and t_parserText[1] ~= nil then
	t_parserText[1].text = #t_gen .. " new character(s) detected."
	if t_parserText[1].id ~= nil then textImgSetText(t_parserText[1].id, t_parserText[1].text) end
end
	cmdInput()
	local parserCfg = 1
	while true do
		if esc() or commandGetState(p1Cmd, 'e') or commandGetState(p2Cmd, 'e') then
			f_playTime()
			os.exit()
		elseif commandGetState(p1Cmd, 'u') or commandGetState(p2Cmd, 'u') then
			sndPlay(sndSys, 100, 0)
			parserCfg = parserCfg - 1
			if parserCfg < 1 then parserCfg = #t_parserOptions end
		elseif commandGetState(p1Cmd, 'd') or commandGetState(p2Cmd, 'd') then
			sndPlay(sndSys, 100, 0)
			parserCfg = parserCfg + 1
			if parserCfg > #t_parserOptions then parserCfg = 1 end
		elseif btnPalNo(p1Cmd, true) > 0 or btnPalNo(p2Cmd, true) > 0 then
			--sndPlay(sndSys, 100, 0)
			break
		end
		textImgDraw(txt_parserWarning)
		for i=1, #t_parserText do
			textImgDraw(t_parserText[i].id)
		end
		for i=1, #t_parserOptions do
			if parserCfg == i then
				textImgSetBank(t_parserOptions[i].id, 3)
			else
				textImgSetBank(t_parserOptions[i].id, 0)
			end
			textImgDraw(t_parserOptions[i].id)
		end
		cmdInput()
		refresh()
	end
	if parserCfg == 3 then
		data.sffConversion = false
		local file = io.open(saveCfgPath,"r")
		if file == nil then return end
		local str = file:read("*all")
		file:close()
		str = str:gsub('data.sffConversion%s*=%s*[^\n]+', 'data.sffConversion = false')
		file = io.open(saveCfgPath,"w+")
		if file == nil then return end
		file:write(str)
		file:close()
	elseif parserCfg == 1 then
		f_printVar(batch, 'batch.bat')
		batch = ''
		--batOpen("", "batch.bat")
		os.execute('batch.bat')
	--open each line in data/charTrash/charName/s-sff.def to compare
		for i=1, #t_gen do
			local append = ''
			--local charAnimPath = t_selChars[t_gen[i]].ikanim
			--local charAnimPathWin = t_selChars[t_gen[i]].ikanim:gsub('/', '\\')
			displayname = t_selChars[t_gen[i]].name:gsub('%s+', '_')
			for line in io.lines('data/charTrash/' .. displayname .. '/s-sff.def') do
			--append to variable if line matches sprite group and sprite number stored in AIR animation data via f_charAnim function
				append = append .. f_charAnim(t_selChars[t_gen[i]].stand, line) .. f_charAnim(t_selChars[t_gen[i]].win, line) .. f_charAnim(t_selChars[t_gen[i]].lieDown, line) .. f_charAnim(t_selChars[t_gen[i]].dizzy, line) .. f_charAnim(t_selChars[t_gen[i]].cheese, line) .. f_charAnim(t_selChars[t_gen[i]].intermissionSpr, line)
			end
		--remove duplicated sprites from string via f_uniq function
			append = f_uniq(append .. '\n', '[^\n]+\n', '^%s*[0-9-]-%s*,%s*[0-9-]-%s*,')
		--print variable for both debugging and sprite generation purpose
			f_printVar(sff2png .. append, 'data/charAnim/' .. displayname .. '.def')
		--create a batch variable used to generate sff files all at once
			batch = batch .. '\n' .. 'tools\\sprmake2.exe' .. ' -o "data\\charAnim\\' .. displayname .. '.sff" "data\\charAnim\\' .. displayname .. '.def" >> save\\debug\\sprmake2.log'
		end
		batch = batch .. '\n' .. 'del batch.bat'
		f_printVar(batch, 'batch.bat')
		--batOpen("", "batch.bat")
		os.execute('batch.bat')
		for i=1, #t_gen do
			--local charAnimPath = t_selChars[t_gen[i]].ikanim
			displayname = t_selChars[t_gen[i]].name:gsub('%s+', '_')
			t_selChars[t_gen[i]]['sffData'] = sffNew('data/charAnim/' .. displayname .. '.sff')
			if t_selChars[t_gen[i]].stand ~= nil then
				t_selChars[t_gen[i]]['p1AnimStand'] = f_animFromTable(t_selChars[t_gen[i]].stand, t_selChars[t_gen[i]].sffData, 30, 150, t_selChars[t_gen[i]].xscale, t_selChars[t_gen[i]].yscale, 0, 1)
				t_selChars[t_gen[i]]['p2AnimStand'] = f_animFromTable(t_selChars[t_gen[i]].stand, t_selChars[t_gen[i]].sffData, 30, 150, t_selChars[t_gen[i]].xscale, t_selChars[t_gen[i]].yscale, 'H', 1)
			end
			if t_selChars[t_gen[i]].win ~= nil then
				t_selChars[t_gen[i]]['p1AnimWin'] = f_animFromTable(t_selChars[t_gen[i]].win, t_selChars[t_gen[i]].sffData, 30, 150, t_selChars[t_gen[i]].xscale, t_selChars[t_gen[i]].yscale, 0, 1)
				t_selChars[t_gen[i]]['p2AnimWin'] = f_animFromTable(t_selChars[t_gen[i]].win, t_selChars[t_gen[i]].sffData, 30, 150, t_selChars[t_gen[i]].xscale, t_selChars[t_gen[i]].yscale, 'H', 1)
			end
			if t_selChars[t_gen[i]].cheese ~= nil then
				t_selChars[t_gen[i]]['p1AnimCheese'] = f_animFromTable(t_selChars[t_gen[i]].cheese, t_selChars[t_gen[i]].sffData, 30, 150, t_selChars[t_gen[i]].xscale, t_selChars[t_gen[i]].yscale, 0, 1)
				t_selChars[t_gen[i]]['p2AnimCheese'] = f_animFromTable(t_selChars[t_gen[i]].cheese, t_selChars[t_gen[i]].sffData, 30, 150, t_selChars[t_gen[i]].xscale, t_selChars[t_gen[i]].yscale, 'H', 1)
			end
			if t_selChars[t_gen[i]].lieDown ~= nil then
				t_selChars[t_gen[i]]['p1AnimLieDown'] = f_animFromTable(t_selChars[t_gen[i]].lieDown, t_selChars[t_gen[i]].sffData, 30, 150, t_selChars[t_gen[i]].xscale, t_selChars[t_gen[i]].yscale, 0, 1)
				t_selChars[t_gen[i]]['p2AnimLieDown'] = f_animFromTable(t_selChars[t_gen[i]].lieDown, t_selChars[t_gen[i]].sffData, 30, 150, t_selChars[t_gen[i]].xscale, t_selChars[t_gen[i]].yscale, 'H', 1)
			end
			if t_selChars[t_gen[i]].dizzy ~= nil then
				t_selChars[t_gen[i]]['p1AnimDizzy'] = f_animFromTable(t_selChars[t_gen[i]].dizzy, t_selChars[t_gen[i]].sffData, 30, 150, t_selChars[t_gen[i]].xscale, t_selChars[t_gen[i]].yscale, 0, 1)
				t_selChars[t_gen[i]]['p2AnimDizzy'] = f_animFromTable(t_selChars[t_gen[i]].dizzy, t_selChars[t_gen[i]].sffData, 30, 150, t_selChars[t_gen[i]].xscale, t_selChars[t_gen[i]].yscale, 'H', 1)
			end
			if t_selChars[t_gen[i]].intermissionSpr ~= nil then
				t_selChars[t_gen[i]]['p1IntermissionPortrait'] = f_animFromTable(t_selChars[t_gen[i]].intermissionSpr, t_selChars[t_gen[i]].sffData, 30, 150, t_selChars[t_gen[i]].xscale, t_selChars[t_gen[i]].yscale, 0, 1)
				t_selChars[t_gen[i]]['p2IntermissionPortrait'] = f_animFromTable(t_selChars[t_gen[i]].intermissionSpr, t_selChars[t_gen[i]].sffData, 30, 150, t_selChars[t_gen[i]].xscale, t_selChars[t_gen[i]].yscale, 'H', 1)
			end
			refresh()
		end
		deldir('data/charTrash')
	end
end

--Generate Table with Music List
t_selMusic = {
	{bgmfile = "", bgmname = "AUTO", bgmchar = 0},
	{bgmfile = "", bgmname = "AUTO [RIGHT SIDE]", bgmchar = 0},
	{bgmfile = "", bgmname = "RANDOM", bgmchar = 0}
}

--Populate t_selMusic table with SOUND FOLDER data
selMusicPath = musicPath --loaded from screnpack.lua
for file in lfs.dir(selMusicPath) do
	if file:match('^.*(%.)[Mm][Pp][3]$') then
		row = #t_selMusic + 1
		t_selMusic[row] = {}
		t_selMusic[row]['bgmfile'] = selMusicPath.."/"..file
		t_selMusic[row]['bgmname'] = file:gsub('^(.*)[%.][Mm][Pp][3]$', '%1')
		t_selMusic[row]['bgmchar'] = 0
	elseif file:match('^.*(%.)[Oo][Gg][Gg]$') then
		row = #t_selMusic + 1
		t_selMusic[row] = {}
		t_selMusic[row]['bgmfile'] = selMusicPath.."/"..file
		t_selMusic[row]['bgmname'] = file:gsub('^(.*)[%.][Oo][Gg][Gg]$', '%1')
		t_selMusic[row]['bgmchar'] = 0
	end
end

--Add extra items to Song Select table
t_selMusic[#t_selMusic + 1] = {bgmfile = "", bgmname = "MUTE", bgmchar = 0}
t_selMusic[#t_selMusic + 1] = {bgmfile = "", bgmname = "AUTO [LEFT SIDE]", bgmchar = 0}

t_extraStages = {}
function generateStageList(path)
	for item in lfs.dir(path) do --For each item readed in path
		if item ~= "." and item ~= ".." and item ~= ".keep" then --exclude items
			local details = path.."/"..item --Get path and file name
			local attribute = lfs.attributes(details) --Get atributes from items readed
			if attribute ~= nil then
				assert(type(attribute) == "table")
				generateStageList(details)
				if attribute.mode == "file" then
					if item:match('^.*(%.)[Dd][Ee][Ff]$') then --Get only .def files
						t_extraStages[#t_extraStages + 1] = details
					end
					--f_printTable(t_extraStages, 'save/debug/StageListCreator.log')
				end
			end
		end
	end
	local str = "[ExtraStages]"
	for i=1, #t_extraStages do --For all values/paths stored in table
		str = str..'\n'..t_extraStages[i]
	end
	dscr = io.open("save/00_ExtraStagesList.txt", 'w')
	if dscr == nil then return end
	dscr:write(str) --Write all table values in txt file
	io.close(dscr)
end

t_characters = {}
function generateCharsList(path)
	for item in lfs.dir(path) do
		if item ~= "." and item ~= ".." and item ~= ".keep" then
			local details = path.."/"..item
			local attribute = lfs.attributes(details)
			if attribute ~= nil then
				assert(type(attribute) == "table") --To avoid isues here all files inside char folder need to be in not japan or special symbols names
				generateCharsList(details)
				if attribute.mode == "file" then
					if item:match('^.*(%.)[Dd][Ee][Ff]$') then
						local rPath = details
						local startIndex = string.find(rPath, "chars/") --Finds "chars/" string
						if startIndex then
							local details = string.sub(rPath, startIndex + 6) --Extracts the substring starting from the position after "chars/"
							t_characters[#t_characters + 1] = details
						else --"String does not contain 'chars/'
							
						end
					end
					--f_printTable(t_characters, 'save/debug/CharsListCreator.log')
				end
			end
		end
	end
	local str = "[Characters]"
	for i=1, #t_characters do
		str = str..'\n'..t_characters[i]
	end
	dscr = io.open("save/00_CharactersList.txt", 'w')
	if dscr == nil then return end
	dscr:write(str)
	io.close(dscr)
end

--print tables
if data.debugLog then
	f_printTable(t_selChars, "save/debug/t_selChars.log")
	f_printTable(t_selStages, "save/debug/t_selStages.log")
	f_printTable(t_selMusic, "save/debug/t_selMusic.log")
	f_printTable(t_selOptions, "save/debug/t_selOptions.log")
	f_printTable(t_charDef, "save/debug/t_charDef.log")
	f_printTable(t_stageDef, "save/debug/t_stageDef.log")
	f_printTable(t_orderChars, "save/debug/t_orderChars.log")
	f_printTable(t_randomChars, "save/debug/t_randomChars.log")
	f_printTable(t_randomTourneyChars, "save/debug/t_randomTourneyChars.log")
	f_printTable(t_bossChars, "save/debug/t_bossChars.log")
	f_printTable(t_bonusChars, "save/debug/t_bonusChars.log")
	f_printTable(t_trainingChar, "save/debug/t_trainingChar.log")
	f_printTable(t_tutorialChar, "save/debug/t_tutorialChar.log")
	f_printTable(t_intermissionChars, "save/debug/t_intermissionChars.log")
	f_printTable(t_unlockLua, "save/debug/t_unlockLua.log")
end

function f_rushTables()
	t_bossSingle = {} --This is the table of the boss chars menu to fight against them individually, it must be loaded after this parser script or it will give an error
	local endFor = #t_bossChars + 1
	for i=1, endFor do
		if i < endFor then
			t_bossSingle[#t_bossSingle + 1] = {}
			t_bossSingle[i]['id'] = textImgNew()
			t_bossSingle[i]['text'] = t_selChars[t_bossChars[i] + 1].displayname:upper()
		end
	end

	t_bonusExtras = {} --This is the bonus chars menu table, it must be loaded after this parser script or it will give an error
	local endFor = #t_bonusChars + 1
	for i=1, endFor do
		if i < endFor then
			t_bonusExtras[#t_bonusExtras + 1] = {}
			t_bonusExtras[i]['id'] = textImgNew()
			t_bonusExtras[i]['text'] = t_selChars[t_bonusChars[i] + 1].displayname:upper()
		end
	end
end
f_rushTables() --This function prevents that the table getting messed up when playing single boss or single bonus mode, since the table that loads the chars after playing boss rush or bonus rush, randomizes the items.
--; =========================================================
--; VOID MUGEN PURITY: lazy display-name loader
--; Loads the real [Info] name from ONE character's .def per
--; frame, only for the cell under each player's cursor.
--; All other cells stay at their folder-name set at startup.
--; This is the MUGEN architecture: the select screen is dumb;
--; file I/O only happens when the cursor touches a slot.
--; =========================================================
do
    local _voidLazyLastCel = {}

    local function _voidLazyLoadSlot(rosterIdx)
        if rosterIdx == nil or rosterIdx < 1 then return end
        local slot = t_selChars and t_selChars[rosterIdx]
        if slot == nil or slot.nameReady or slot.empty then return end
        if f_peekDisplayName then f_peekDisplayName(slot) end
    end

    local function _voidPageCelToRoster(cell)
        -- Convert page-relative cell (0-based) to 1-based t_selChars index.
        -- Falls back to direct index when selectplus paging is not active.
        local pos = cell + 1
        if start and start.rosterPage then
            local rp = start.rosterPage
            local ps = (rp.pageSize and rp.pageSize > 0) and rp.pageSize
                       or (motif and motif.select_info and
                           motif.select_info.rows * motif.select_info.columns)
                       or 64
            local pg = (rp.current and rp.current > 0) and rp.current or 1
            pos = (pg - 1) * ps + cell + 1
            if start.rosterFilter ~= nil then
                pos = start.rosterFilter[pos] or pos
            end
        end
        return pos
    end

    hook.add('start.f_selectScreen', 'void.name_lazy', function()
        if start == nil or start.c == nil then return end
        for i = 1, #start.c do
            local cur = start.c[i]
            if cur ~= nil and cur.cell ~= nil then
                local cel = cur.cell
                if _voidLazyLastCel[i] ~= cel then
                    _voidLazyLastCel[i] = cel
                    _voidLazyLoadSlot(_voidPageCelToRoster(cel))
                end
            end
        end
    end)
end

-- ============================================================
-- NOTE: Portrait lazy loading + Iron Grip debounce/prefetch
-- are now handled by script/void_irongrip.lua (loaded from common.lua).
-- voidPortraitCells is still declared there; void.portrait_lazy hook
-- is replaced by the Iron Grip version on load.

-- Iron Grip: debounce + prefetch. Must load after hook is live.
require("script.void_irongrip")

-- VOID ShellGate: WinMUGEN shellcode address bridge + DtC scanner.
-- Loads VOID_Anchor.dll (next to IKEMEN_VOID.exe) for the fixed
-- anchor address and optional x86 emulation.  Safe to load even if
-- the DLL is absent - falls back to stub mode with a log warning.
if type(pcall) == "function" then
    pcall(require, "script.void_shellgate")
end
