local parent, ns = ...
local oUF = ns.oUF

local MAX_ARENA_ENEMIES = MAX_ARENA_ENEMIES or 5
local MAX_BOSS_FRAMES = MAX_BOSS_FRAMES or 5
local MAX_PARTY_MEMBERS = MAX_PARTY_MEMBERS or 4

local hiddenParent = CreateFrame("Frame", nil, UIParent)
hiddenParent:SetAllPoints()
hiddenParent:Hide()

local function handleFrame(baseName)
	local frame
	if(type(baseName) == "string") then
		frame = _G[baseName]
	else
		frame = baseName
	end

	if(frame) then
		frame:UnregisterAllEvents()
		frame:Hide()

		frame:SetParent(hiddenParent)

		local health = frame.healthBar or frame.healthbar
		if(health) then
			health:UnregisterAllEvents()
		end

		local power = frame.manabar
		if(power) then
			power:UnregisterAllEvents()
		end

		local spell = frame.castBar or frame.spellbar
		if(spell) then
			spell:UnregisterAllEvents()
		end

		local altpowerbar = frame.powerBarAlt
		if(altpowerbar) then
			altpowerbar:UnregisterAllEvents()
		end

		local buffFrame = frame.BuffFrame
		if(buffFrame) then
			buffFrame:UnregisterAllEvents()
		end
	end
end

function oUF:DisableBlizzard(unit)
	if(not unit) then return end

	if(unit == "player") then
		HandleFrame(PlayerFrame)

		PlayerFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
		PlayerFrame:RegisterEvent("UNIT_ENTERING_VEHICLE")
		PlayerFrame:RegisterEvent("UNIT_ENTERED_VEHICLE")
		PlayerFrame:RegisterEvent("UNIT_EXITING_VEHICLE")
		PlayerFrame:RegisterEvent("UNIT_EXITED_VEHICLE")

		PlayerFrame:SetUserPlaced(true)
		PlayerFrame:SetDontSavePosition(true)
	elseif(unit == "pet") then
		HandleFrame(PetFrame)
	elseif(unit == "target") then
		HandleFrame(TargetFrame)
		HandleFrame(ComboFrame)
	elseif(unit == "focus") then
		HandleFrame(FocusFrame)
		HandleFrame(TargetofFocusFrame)
	elseif(unit == "targettarget") then
		HandleFrame(TargetFrameToT)
	elseif(unit:match("(boss)%d?$") == "boss") then
		local id = unit:match("boss(%d)")
		if(id) then
			HandleFrame("Boss" .. id .. "TargetFrame")
		else
			for i = 1, MAX_BOSS_FRAMES do
				handleFrame(string.format("Boss%dTargetFrame", i))
			end
		end
	elseif(unit:match("(party)%d?$") == "party") then
		local id = unit:match("party(%d)")
		if(id) then
			HandleFrame("PartyMemberFrame" .. id)
		else
			for i = 1, MAX_PARTY_MEMBERS do
				handleFrame(string.format("PartyMemberFrame%d", i))
			end
		end
	elseif(unit:match("(arena)%d?$") == "arena") then
		local id = unit:match("arena(%d)")
		if(id) then
			HandleFrame("ArenaEnemyFrame" .. id)
		else
			for i = 1, MAX_ARENA_ENEMIES do
				handleFrame(string.format("ArenaEnemyFrame%d", i))
			end
		end

		Arena_LoadUI = function() end
		SetCVar("showArenaEnemyFrames", "0", "SHOW_ARENA_ENEMY_FRAMES_TEXT")
	end
end