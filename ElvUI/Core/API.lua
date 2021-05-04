local E, L, V, P, G = unpack(select(2, ...))

local _G = _G
local wipe, date = wipe, date
local format, select, type, ipairs, pairs = format, select, type, ipairs, pairs
local strmatch, strfind, tonumber, tostring = strmatch, strfind, tonumber, tostring

local C_PetBattles_IsInBattle = C_PetBattles.IsInBattle
local GetCVarBool = GetCVarBool
local GetCombatRatingBonus = GetCombatRatingBonus
local GetFunctionCPUUsage = GetFunctionCPUUsage
local GetSpellInfo = GetSpellInfo
local RequestBattlefieldScoreData = RequestBattlefieldScoreData
local UnitAttackPower = UnitAttackPower
local UnitFactionGroup = UnitFactionGroup
local UnitGroupRolesAssigned = UnitGroupRolesAssigned
local UnitHasVehicleUI = UnitHasVehicleUI
local UnitStat = UnitStat
local IsInInstance = IsInInstance
local IsRatedBattleground = IsRatedBattleground
local GetBattlefieldArenaFaction = GetBattlefieldArenaFaction
local PLAYER_FACTION_GROUP = PLAYER_FACTION_GROUP
local FACTION_HORDE = FACTION_HORDE
local FACTION_ALLIANCE = FACTION_ALLIANCE

function E:ClassColor(class, usePriestColor)
	if not class then return end

	local color = (CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[class]) or RAID_CLASS_COLORS[class]
	if type(color) ~= "table" then return end

	if not color.colorStr then
		color.colorStr = E:RGBToHex(color.r, color.g, color.b, "ff")
	elseif strlen(color.colorStr) == 6 then
		color.colorStr = "ff"..color.colorStr
	end

	if (usePriestColor and class == "PRIEST") and tonumber(color.colorStr, 16) > tonumber(E.PriestColors.colorStr, 16) then
		return E.PriestColors
	else
		return color
	end
end

do -- other non-english locales require this
	E.UnlocalizedClasses = {}
	for k, v in pairs(LOCALIZED_CLASS_NAMES_MALE) do E.UnlocalizedClasses[v] = k end
	for k, v in pairs(LOCALIZED_CLASS_NAMES_FEMALE) do E.UnlocalizedClasses[v] = k end

	function E:UnlocalizedClassName(className)
		return (className and className ~= "") and E.UnlocalizedClasses[className]
	end
end

function E:IsFoolsDay()
	return strfind(date(), "04/01/") and not E.global.aprilFools
end

function E:ScanTooltipTextures(clean, grabTextures)
	local textures
	for i = 1, 10 do
		local tex = _G["ElvUI_ScanTooltipTexture"..i]
		local texture = tex and tex:GetTexture()
		if texture then
			if grabTextures then
				if not textures then textures = {} end
				textures[i] = texture
			end
			if clean then
				tex:SetTexture()
			end
		end
	end

	return textures
end

function E:CheckTalentTree(tree)
	local activeGroup = GetActiveSpecGroup()
	if type(tree) == "number" then
		if activeGroup and GetSpecialization(false, false, activeGroup) then
			return tree == GetSpecialization(false, false, activeGroup)
		end
	elseif type(tree) == "table" then
		local activeGroup = GetActiveSpecGroup()
		for _, index in pairs(tree) do
			if activeGroup and GetSpecialization(false, false, activeGroup) then
				return index == GetSpecialization(false, false, activeGroup)
			end
		end
	end
end

function E:GetPlayerRole()
	local assignedRole = UnitGroupRolesAssigned("player")
	if assignedRole == "NONE" then
		return E.myspec and GetSpecializationRole(E.myspec)
	end

	return assignedRole
end

function E:CheckRole()
	E.myspec = GetSpecialization()
	E.myrole = E:GetPlayerRole()

	local role
	if type(E.ClassRole[E.myclass]) == "string" then
		role = E.ClassRole[E.myclass]
	elseif E.myspec then
		role = E.ClassRole[E.myclass][E.myspec]
	end

	local resilience = GetCombatRatingBonus(COMBAT_RATING_RESILIENCE_PLAYER_DAMAGE_TAKEN)
	local isInPvPGear = resilience > GetDodgeChance() and resilience > GetParryChance() and E.mylevel == MAX_PLAYER_LEVEL
	if role == "Tank" and isInPvPGear then
		role = "Melee"
	end

	if not role then
		local playerInt = select(2, UnitStat("player", 4))
		local playerAgi	= select(2, UnitStat("player", 2))
		local base, posBuff, negBuff = UnitAttackPower("player")
		local playerAp = base + posBuff + negBuff

		role = ((playerAp > playerInt) or (playerAgi > playerInt)) and "Melee" or "Caster"
	end

	if E.role ~= role then
		E.role = role
		E.callbacks:Fire("RoleChanged")
	end

	if E.HealingClasses[E.myclass] ~= nil and E.myclass ~= "PRIEST" then
		E.DispelClasses[E.myclass].Magic = E:CheckTalentTree(E.HealingClasses[E.myclass])
	end
end

function E:IsDispellableByMe(debuffType)
	local dispel = E.DispelClasses[E.myclass]

	return dispel and dispel[debuffType]
end

do
	local Masque = E.Libs.Masque
	local MasqueGroupState = {}
	local MasqueGroupToTableElement = {
		["ActionBars"]	= {"actionbar", "actionbars"},
		["Pet Bar"]		= {"actionbar", "petBar"},
		["Stance Bar"]	= {"actionbar", "stanceBar"},
		["Buffs"]		= {"auras", "buffs"},
		["Debuffs"]		= {"auras", "debuffs"},
		["Consolidated Buffs"] = {"auras", "consolidatedBuffs"}
	}

	function E:MasqueCallback(Group, _, _, _, _, Disabled)
		if not E.private then return end

		local element = MasqueGroupToTableElement[Group]
		if element then
			if Disabled then
				if E.private[element[1]].masque[element[2]] and MasqueGroupState[Group] == "enabled" then
					E.private[element[1]].masque[element[2]] = false
					E:StaticPopup_Show("CONFIG_RL")
				end
				MasqueGroupState[Group] = "disabled"
			else
				MasqueGroupState[Group] = "enabled"
			end
		end
	end

	if Masque then
		Masque:Register("ElvUI", E.MasqueCallback)
	end
end

do
	local CPU_USAGE = {}
	local function CompareCPUDiff(showall, minCalls)
		local greatestUsage, greatestCalls, greatestName, newName, newFunc
		local greatestDiff, lastModule, mod, usage, calls, diff = 0

		for name, oldUsage in pairs(CPU_USAGE) do
			newName, newFunc = strmatch(name, "^([^:]+):(.+)$")
			if not newFunc then
				E:Print("CPU_USAGE:", name, newFunc)
			else
				if newName ~= lastModule then
					mod = E:GetModule(newName, true) or E
					lastModule = newName
				end
				usage, calls = GetFunctionCPUUsage(mod[newFunc], true)
				diff = usage - oldUsage
				if showall and (calls > minCalls) then
					E:Print("Name("..name..") Calls("..calls..") Diff("..(diff > 0 and format("%.3f", diff) or 0)..")")
				end
				if (diff > greatestDiff) and calls > minCalls then
					greatestName, greatestUsage, greatestCalls, greatestDiff = name, usage, calls, diff
				end
			end
		end

		if greatestName then
			E:Print(greatestName.." had the CPU usage of: "..(greatestUsage > 0 and format("%.3f", greatestUsage) or 0).."ms. And has been called "..greatestCalls.." times.")
		else
			E:Print("CPU Usage: No CPU Usage differences found.")
		end

		wipe(CPU_USAGE)
	end

	function E:GetTopCPUFunc(msg)
		if not GetCVarBool("scriptProfile") then
			E:Print("For `/cpuusage` to work, you need to enable script profiling via: `/console scriptProfile 1` then reload. Disable after testing by setting it back to 0.")
			return
		end

		local module, showall, delay, minCalls = strmatch(msg, "^(%S+)%s*(%S*)%s*(%S*)%s*(.*)$")
		local checkCore, mod = (not module or module == "") and "E"

		showall = (showall == "true" and true) or false
		delay = (delay == "nil" and nil) or tonumber(delay) or 5
		minCalls = (minCalls == "nil" and nil) or tonumber(minCalls) or 15

		wipe(CPU_USAGE)
		if module == "all" then
			for moduName, modu in pairs(self.modules) do
				for funcName, func in pairs(modu) do
					if (funcName ~= "GetModule") and (type(func) == "function") then
						CPU_USAGE[moduName..":"..funcName] = GetFunctionCPUUsage(func, true)
					end
				end
			end
		else
			if not checkCore then
				mod = self:GetModule(module, true)
				if not mod then
					self:Print(module.." not found, falling back to checking core.")
					mod, checkCore = self, "E"
				end
			else
				mod = self
			end
			for name, func in pairs(mod) do
				if (name ~= "GetModule") and type(func) == "function" then
					CPU_USAGE[(checkCore or module)..":"..name] = GetFunctionCPUUsage(func, true)
				end
			end
		end

		self:Delay(delay, CompareCPUDiff, showall, minCalls)
		self:Print("Calculating CPU Usage differences (module: "..(checkCore or module)..", showall: "..tostring(showall)..", minCalls: "..tostring(minCalls)..", delay: "..tostring(delay)..")")
	end
end

function E:AddNonPetBattleFrames()
	if InCombatLockdown() then return end

	for object, data in pairs(E.FrameLocks) do
		local parent, strata
		if type(data) == "table" then
			parent, strata = data.parent, data.strata
		elseif data == true then
			parent = UIParent
		end

		local obj = _G[object] or object
		obj:SetParent(parent)
		if strata then
			obj:SetFrameStrata(strata)
		end
	end

	self:UnregisterEvent("PLAYER_REGEN_DISABLED")
end

function E:RemoveNonPetBattleFrames()
	if InCombatLockdown() then return end

	for object in pairs(E.FrameLocks) do
		local obj = _G[object] or object
		obj:SetParent(E.HiddenFrame)
	end

	self:RegisterEvent("PLAYER_REGEN_DISABLED", "AddNonPetBattleFrames")
end

function E:RegisterPetBattleHideFrames(object, originalParent, originalStrata)
	if not object or not originalParent then
		E:Print("Error. Usage: RegisterPetBattleHideFrames(object, originalParent, originalStrata)")
		return
	end

	object = _G[object] or object
	--If already doing pokemon
	if C_PetBattles_IsInBattle() then
		object:SetParent(E.HiddenFrame)
	end

	E.FrameLocks[object] = {
		parent = originalParent,
		strata = originalStrata or nil,
	}
end

function E:UnregisterPetBattleHideFrames(object)
	if not object then
		E:Print("Error. Usage: UnregisterPetBattleHideFrames(object)")
		return
	end

	object = _G[object] or object
	--Check if object was registered to begin with
	if not E.FrameLocks[object] then return end

	--Change parent of object back to original parent
	local originalParent = E.FrameLocks[object].parent
	if originalParent then
		object:SetParent(originalParent)
	end

	--Change strata of object back to original
	local originalStrata = E.FrameLocks[object].strata
	if originalStrata then
		object:SetFrameStrata(originalStrata)
	end

	--Remove object from table
	E.FrameLocks[object] = nil
end

function E:RegisterObjectForVehicleLock(object, originalParent)
	if not object or not originalParent then
		E:Print("Error. Usage: RegisterObjectForVehicleLock(object, originalParent)")
		return
	end

	object = _G[object] or object
	--Entering/Exiting vehicles will often happen in combat.
	--For this reason we cannot allow protected objects.
	if object.IsProtected and object:IsProtected() then
		E:Print("Error. Object is protected and cannot be changed in combat.")
		return
	end

	--Check if we are already in a vehicles
	if UnitHasVehicleUI("player") then
		object:SetParent(E.HiddenFrame)
	end

	--Add object to table
	E.VehicleLocks[object] = originalParent
end

function E:UnregisterObjectForVehicleLock(object)
	if not object then
		E:Print("Error. Usage: UnregisterObjectForVehicleLock(object)")
		return
	end

	object = _G[object] or object
	--Check if object was registered to begin with
	if not E.VehicleLocks[object] then return end

	--Change parent of object back to original parent
	local originalParent = E.VehicleLocks[object]
	if originalParent then
		object:SetParent(originalParent)
	end

	--Remove object from table
	E.VehicleLocks[object] = nil
end

function E:EnterVehicleHideFrames(_, unit)
	if unit ~= "player" then return end

	for object in pairs(E.VehicleLocks) do
		object:SetParent(E.HiddenFrame)
	end
end

function E:ExitVehicleShowFrames(_, unit)
	if unit ~= "player" then return end

	for object, originalParent in pairs(E.VehicleLocks) do
		object:SetParent(originalParent)
	end
end

function E:RequestBGInfo()
	RequestBattlefieldScoreData()
end

function E:PLAYER_ENTERING_WORLD()
	if not self.MediaUpdated then
		self:UpdateMedia()
		self.MediaUpdated = true
	else
		self:ScheduleTimer("CheckRole", 0.01)
	end

	local _, instanceType = GetInstanceInfo()
	if instanceType == "pvp" then
		self.BGTimer = self:ScheduleRepeatingTimer("RequestBGInfo", 5)
		self:RequestBGInfo()
	elseif self.BGTimer then
		self:CancelTimer(self.BGTimer)
		self.BGTimer = nil
	end
end

function E:PLAYER_REGEN_ENABLED()
	if self.ShowOptionsUI then
		self:ToggleOptionsUI()

		self.ShowOptionsUI = nil
	end
end

function E:PLAYER_REGEN_DISABLED()
	local err

	if IsAddOnLoaded("ElvUI_OptionsUI") then
		local ACD = self.Libs.AceConfigDialog
		if ACD and ACD.OpenFrames and ACD.OpenFrames.ElvUI then
			ACD:Close("ElvUI")
			err = true
		end
	end

	if self.CreatedMovers then
		for name in pairs(self.CreatedMovers) do
			local mover = _G[name]
			if mover and mover:IsShown() then
				mover:Hide()
				err = true
			end
		end
	end

	if err then
		self:Print(ERR_NOT_IN_COMBAT)
	end
end

function E:GetUnitBattlefieldFaction(unit)
	local englishFaction, localizedFaction = UnitFactionGroup(unit)

	-- this might be a rated BG or wargame and if so the player's faction might be altered
	if unit == "player" then
		if IsRatedBattleground() or IsWargame() then
			englishFaction = PLAYER_FACTION_GROUP[GetBattlefieldArenaFaction()]
			localizedFaction = (englishFaction == "Alliance" and FACTION_ALLIANCE) or FACTION_HORDE
		end
	end

	return englishFaction, localizedFaction
end

function E:NEUTRAL_FACTION_SELECT_RESULT()
	E.myfaction, E.myLocalizedFaction = UnitFactionGroup("player")
end

function E:PLAYER_LEVEL_UP(_, level)
	E.mylevel = level
end

function E:LoadAPI()
	self:ScheduleTimer("CheckRole", 0.01)

	E:RegisterEvent("PLAYER_LEVEL_UP")
	E:RegisterEvent("PLAYER_ENTERING_WORLD")
	E:RegisterEvent("PLAYER_REGEN_ENABLED")
	E:RegisterEvent("PLAYER_REGEN_DISABLED")
	E:RegisterEvent("NEUTRAL_FACTION_SELECT_RESULT")
	E:RegisterEvent("PET_BATTLE_CLOSE", "AddNonPetBattleFrames")
	E:RegisterEvent("PET_BATTLE_OPENING_START", "RemoveNonPetBattleFrames")
	E:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED", "CheckRole")
	E:RegisterEvent("UNIT_ENTERED_VEHICLE", "EnterVehicleHideFrames")
	E:RegisterEvent("UNIT_EXITED_VEHICLE", "ExitVehicleShowFrames")
	E:RegisterEvent("UI_SCALE_CHANGED", "PixelScaleChanged")

	do -- setup cropIcon texCoords
		local opt = E.db.general.cropIcon
		local modifier = 0.04 * opt
		for i, v in ipairs(E.TexCoords) do
			if i % 2 == 0 then
				E.TexCoords[i] = v - modifier
			else
				E.TexCoords[i] = v + modifier
			end
		end
	end

	if date("%d%m") ~= "0104" then
		E.global.aprilFools = nil
	end
end