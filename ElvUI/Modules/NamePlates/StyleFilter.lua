local E, L, V, P, G = unpack(select(2, ...))
local NP = E:GetModule("NamePlates")
local LSM = E.Libs.LSM

local ipairs, next, pairs, select, tonumber, unpack, tostring = ipairs, next, pairs, select, tonumber, unpack, tostring
local tinsert, sort, twipe = table.insert, table.sort, table.wipe

local GetCurrentMapAreaID = GetCurrentMapAreaID
local GetInstanceInfo = GetInstanceInfo
local GetMapNameByID = GetMapNameByID
local GetRealZoneText = GetRealZoneText
local GetSpellCooldown = GetSpellCooldown
local GetSpellInfo = GetSpellInfo
local GetSubZoneText = GetSubZoneText
local GetTime = GetTime
local IsResting = IsResting
local UnitAffectingCombat = UnitAffectingCombat
local UnitHealth = UnitHealth
local UnitHealthMax = UnitHealthMax
local UnitPower = UnitPower
local UnitPowerMax = UnitPowerMax

NP.TriggerConditions = {
	frameTypes = {
		FRIENDLY_PLAYER = "friendlyPlayer",
		FRIENDLY_NPC = "friendlyNPC",
		ENEMY_PLAYER = "enemyPlayer",
		ENEMY_NPC = "enemyNPC",
	},
	roles = {
		TANK = "tank",
		HEALER = "healer",
		DAMAGER = "damager"
	},
	difficulties = {
		-- dungeons
		[1] = "normal",
		[2] = "heroic",
		-- raids
		[7] = "lfr",
		[17] = "lfr",
		[14] = "normal",
		[15] = "heroic"
	},
	raidTargets = {
		STAR = "star",
		CIRCLE = "circle",
		DIAMOND = "diamond",
		TRIANGLE = "triangle",
		MOON = "moon",
		SQUARE = "square",
		CROSS = "cross",
		SKULL = "skull",
	},
	totems = {},
	uniqueUnits = {}
}

local totemTypes = {
	earth = {
		[2062] = "e1",		-- Earth Elemental Totem
		[2484] = "e2",		-- Earthbind Totem
		[8143] = "e3",		-- Tremor Totem
		[51485] = "e4",		-- Earthgrab Totem
		[108270] = "e5"		-- Stone Bulwark Totem
	},
	fire = {
		[2894] = "f1",		-- Fire Elemental Totem
		[8190] = "f2",		-- Magma Totem
		[3599] = "f3",		-- Searing Totem
	},
	water = {
		[5394] = "w1",		-- Healing Stream Totem
		[16190] = "w2",		-- Mana Tide Totem
		[108280] = "w3" 	-- Healing Tide Totem
	},
	air = {
		[8177] = "a1",		-- Grounding Totem
		[98008] = "a2",		-- Spirit Link Totem
		[120668] = "a3",	-- Stormlash Totem
		[108269] = "a4",	-- Capacitor Totem
		[108273] = "a5"		-- Windwalk Totem
	},
	other = {
		[724] = "o1"		-- Lightwell
	}
}

for totemSchool, totems in pairs(totemTypes) do
	for spellID, totemID in pairs(totems) do
		local totemName, _, texture = GetSpellInfo(spellID)

		if not NP.TriggerConditions.totems[totemID] then
			NP.TriggerConditions.totems[totemID] = {totemName, totemSchool, texture}
		end

		totemName = totemName

		NP.Totems[totemName] = totemID
	end
end

G.nameplates.totemTypes = totemTypes

local uniqueUnitTypes = {
	pvp = {},
	pve = {}
}

G.nameplates.uniqueUnitTypes = uniqueUnitTypes

for unitType, units in pairs(uniqueUnitTypes) do
	for spellID, unit in pairs(units) do
		local name, _, texture = GetSpellInfo(spellID)
		NP.TriggerConditions.uniqueUnits[unit] = {name, unitType, texture}
		NP.UniqueUnits[name] = unit
	end
end

function NP:StyleFilterAuraCheck(names, icons, mustHaveAll, missing, minTimeLeft, maxTimeLeft)
	local total, count = 0, 0
	for name, value in pairs(names) do
		if value == true then --only if they are turned on
			total = total + 1 --keep track of the names
		end
		for _, icon in ipairs(icons) do
			if icon:IsShown() and (value == true) and ((icon.name and icon.name == name) or (icon.spellID and icon.spellID == tonumber(name)))
				and (not minTimeLeft or (minTimeLeft == 0 or (icon.expirationTime and (icon.expirationTime - GetTime()) > minTimeLeft))) and (not maxTimeLeft or (maxTimeLeft == 0 or (icon.expirationTime and (icon.expirationTime - GetTime()) < maxTimeLeft))) then
				count = count + 1 --keep track of how many matches we have
			end
		end
	end

	if total == 0 then
		return nil --If no auras are checked just pass nil, we dont need to run the filter here.
	else
		return ((mustHaveAll and not missing) and total == count)	-- [x] Check for all [ ] Missing: total needs to match count
		or ((not mustHaveAll and not missing) and count > 0)		-- [ ] Check for all [ ] Missing: count needs to be greater than zero
		or ((not mustHaveAll and missing) and count == 0)			-- [ ] Check for all [x] Missing: count needs to be zero
		or ((mustHaveAll and missing) and total ~= count)			-- [x] Check for all [x] Missing: count must not match total
	end
end

function NP:StyleFilterCooldownCheck(names, mustHaveAll)
	local total, count = 0, 0
	local _, gcd = GetSpellCooldown(61304)

	for name, value in pairs(names) do
		if value == "ONCD" or value == "OFFCD" then --only if they are turned on
			total = total + 1 --keep track of the names

			local _, duration = GetSpellCooldown(name)
			if (duration > gcd and value == "ONCD") or (duration <= gcd and value == "OFFCD") then
				count = count + 1
				--print(((duration > gcd and value == "ONCD") and name.."passes because it is on cd.") or ((duration <= gcd and value == "OFFCD") and name.." passes because it is off cd."))
			end
		end
	end

	if total == 0 then
		return nil
	else
		return (mustHaveAll and total == count) or (not mustHaveAll and count > 0)
	end
end

function NP:StyleFilterSetChanges(frame, actions, HealthColorChanged, BorderChanged, FlashingHealth, TextureChanged, ScaleChanged, FrameLevelChanged, AlphaChanged, NameColorChanged, NameOnlyChanged, VisibilityChanged, IconChanged, IconOnlyChanged)
	if VisibilityChanged then
		frame.StyleChanged = true
		frame.VisibilityChanged = true
		frame:Hide()
		return --We hide it. Lets not do other things (no point)
	end
	if FrameLevelChanged then
		frame.StyleChanged = true
		frame.FrameLevelChanged = actions.frameLevel -- we pass this to `ResetNameplateFrameLevel`
	end
	if HealthColorChanged then
		frame.StyleChanged = true
		frame.HealthColorChanged = true
		frame.Health:SetStatusBarColor(actions.color.healthColor.r, actions.color.healthColor.g, actions.color.healthColor.b, actions.color.healthColor.a)
		frame.CutawayHealth:SetStatusBarColor(actions.color.healthColor.r * 1.5, actions.color.healthColor.g * 1.5, actions.color.healthColor.b * 1.5, actions.color.healthColor.a)
	end
	if BorderChanged then --Lets lock this to the values we want (needed for when the media border color changes)
		frame.StyleChanged = true
		frame.BorderChanged = true
		frame.Health.bordertop:SetTexture(actions.color.borderColor.r, actions.color.borderColor.g, actions.color.borderColor.b, actions.color.borderColor.a)
		frame.Health.borderbottom:SetTexture(actions.color.borderColor.r, actions.color.borderColor.g, actions.color.borderColor.b, actions.color.borderColor.a)
		frame.Health.borderleft:SetTexture(actions.color.borderColor.r, actions.color.borderColor.g, actions.color.borderColor.b, actions.color.borderColor.a)
		frame.Health.borderright:SetTexture(actions.color.borderColor.r, actions.color.borderColor.g, actions.color.borderColor.b, actions.color.borderColor.a)
	end
	if FlashingHealth then
		frame.StyleChanged = true
		frame.FlashingHealth = true
		if not TextureChanged then
			frame.FlashTexture:SetTexture(LSM:Fetch("statusbar", NP.db.statusbar))
		end
		frame.FlashTexture:SetVertexColor(actions.flash.color.r, actions.flash.color.g, actions.flash.color.b)
		frame.FlashTexture:SetAlpha(actions.flash.color.a)
		frame.FlashTexture:Show()
		E:Flash(frame.FlashTexture, actions.flash.speed * 0.1, true)
	end
	if TextureChanged then
		frame.StyleChanged = true
		frame.TextureChanged = true
		local tex = LSM:Fetch("statusbar", actions.texture.texture)
		frame.Health.Highlight:SetTexture(tex)
		frame.Health:SetStatusBarTexture(tex)
		if FlashingHealth then
			frame.FlashTexture:SetTexture(tex)
		end
	end
	if ScaleChanged then
		frame.StyleChanged = true
		frame.ScaleChanged = true
		local scale = (frame.ThreatScale or 1)
		frame.ActionScale = actions.scale
		if frame.isTarget and NP.db.useTargetScale then
			scale = scale * NP.db.targetScale
		end
		NP:SetFrameScale(frame, scale * actions.scale)
	end
	if AlphaChanged then
		frame.StyleChanged = true
		frame.AlphaChanged = true
		NP:PlateFade(frame, NP.db.fadeIn and 1 or 0, frame:GetAlpha(), actions.alpha / 100)
	end
	if NameColorChanged then
		frame.StyleChanged = true
		frame.NameColorChanged = true
		local nameText = frame.oldName:GetText()
		if nameText and nameText ~= "" then
			frame.Name:SetTextColor(actions.color.nameColor.r, actions.color.nameColor.g, actions.color.nameColor.b, actions.color.nameColor.a)
			if NP.db.nameColoredGlow then
				frame.Name.NameOnlyGlow:SetVertexColor(actions.color.nameColor.r - 0.1, actions.color.nameColor.g - 0.1, actions.color.nameColor.b - 0.1, 1)
			end
		end
	end
	if NameOnlyChanged and not frame.IconOnlyChanged then
		frame.StyleChanged = true
		frame.NameOnlyChanged = true
		--hide the bars
		if frame.CastBar:IsShown() then frame.CastBar:Hide() end
		if frame.Health:IsShown() then frame.Health:Hide() end
		--hide the target indicator
		NP:Configure_Glow(frame)
		NP:Update_Glow(frame)
		--position the name and update its color
		frame.Name:ClearAllPoints()
		frame.Name:SetJustifyH("CENTER")
		frame.Name:SetPoint("TOP", frame)
		if NP.db.units[frame.UnitType].level.enable then
			frame.Level:ClearAllPoints()
			frame.Level:SetPoint("LEFT", frame.Name, "RIGHT")
			frame.Level:SetJustifyH("LEFT")
			frame.Level:SetFormattedText(" [%s]", NP:UnitLevel(frame))
		end
		if not NameColorChanged then
			NP:Update_Name(frame, true)
		end
	end
	if IconChanged then
		frame.StyleChanged = true
		frame.IconChanged = true
		NP:Configure_IconFrame(frame)
		NP:Update_IconFrame(frame)
	end
	if IconOnlyChanged then
		frame.StyleChanged = true
		frame.IconOnlyChanged = true
		NP:Update_IconFrame(frame, true)
		if frame.CastBar:IsShown() then frame.CastBar:Hide() end
		if frame.Health:IsShown() then frame.Health:Hide() end
		if frame.Title then frame.Title:Hide() end -- Temporary solution (enhanced plugin)
		frame.Level:SetText()
		frame.Name:SetText()
		NP:Configure_Glow(frame)
		NP:Update_Glow(frame)
		NP:Update_RaidIcon(frame)
		NP:Configure_NameOnlyGlow(frame)
	end
end

function NP:StyleFilterClearChanges(frame, HealthColorChanged, BorderChanged, FlashingHealth, TextureChanged, ScaleChanged, FrameLevelChanged, AlphaChanged, NameColorChanged, NameOnlyChanged, VisibilityChanged, IconChanged, IconOnlyChanged)
	frame.StyleChanged = nil
	if VisibilityChanged then
		frame.VisibilityChanged = nil
		NP:PlateFade(frame, NP.db.fadeIn and 1 or 0, 0, 1) -- fade those back in so it looks clean
		frame:Show()
	end
	if FrameLevelChanged then
		frame.FrameLevelChanged = nil
	end
	if HealthColorChanged then
		frame.HealthColorChanged = nil
		frame.Health:SetStatusBarColor(frame.Health.r, frame.Health.g, frame.Health.b)
		frame.CutawayHealth:SetStatusBarColor(frame.Health.r * 1.5, frame.Health.g * 1.5, frame.Health.b * 1.5, 1)
	end
	if BorderChanged then
		frame.BorderChanged = nil
		local r, g, b = unpack(E.media.bordercolor)
		frame.Health.bordertop:SetTexture(r, g, b)
		frame.Health.borderbottom:SetTexture(r, g, b)
		frame.Health.borderleft:SetTexture(r, g, b)
		frame.Health.borderright:SetTexture(r, g, b)
	end
	if FlashingHealth then
		frame.FlashingHealth = nil
		E:StopFlash(frame.FlashTexture)
		frame.FlashTexture:Hide()
	end
	if TextureChanged then
		frame.TextureChanged = nil
		local tex = LSM:Fetch("statusbar", NP.db.statusbar)
		frame.Health.Highlight:SetTexture(tex)
		frame.Health:SetStatusBarTexture(tex)
	end
	if ScaleChanged then
		frame.ScaleChanged = nil
		frame.ActionScale = nil
		local scale = frame.ThreatScale or 1
		if frame.isTarget and NP.db.useTargetScale then
			scale = scale * NP.db.targetScale
		end
		NP:SetFrameScale(frame, scale)
	end
	if AlphaChanged then
		frame.AlphaChanged = nil
		NP:PlateFade(frame, NP.db.fadeIn and 1 or 0, (frame.FadeObject and frame.FadeObject.endAlpha) or 0.5, 1)
	end
	if NameColorChanged then
		frame.NameColorChanged = nil
		frame.Name:SetTextColor(frame.Name.r, frame.Name.g, frame.Name.b)
	end
	if NameOnlyChanged then
		frame.NameOnlyChanged = nil
		frame.TopLevelFrame = nil --We can safely clear this here because it is set upon `UpdateElement_Auras` if needed
		if NP.db.units[frame.UnitType].health.enable or (frame.isTarget and NP.db.alwaysShowTargetHealth) then
			frame.Health:Show()
			NP:Configure_Glow(frame)
			NP:Update_Glow(frame)
		end
		frame.Name:ClearAllPoints()
		frame.Level:ClearAllPoints()
		if NP.db.units[frame.UnitType].name.enable then
			NP:Update_Name(frame)
			frame.Name:SetTextColor(frame.Name.r, frame.Name.g, frame.Name.b)
		else
			frame.Name:SetText()
		end
		if NP.db.units[frame.UnitType].level.enable then
			NP:Update_Level(frame)
		end
	end
	if IconChanged then
		frame.IconChanged = nil
		frame.IconFrame:Hide()
	end
	if IconOnlyChanged then
		frame.IconOnlyChanged = nil
		NP:Update_IconFrame(frame)
		if NP.db.units[frame.UnitType].iconFrame and NP.db.units[frame.UnitType].iconFrame.enable then
			NP:Configure_IconFrame(frame)
		end
		if NP.db.units[frame.UnitType].health.enable or (frame.isTarget and NP.db.alwaysShowTargetHealth) then
			frame.Health:Show()
			NP:Configure_Glow(frame)
			NP:Update_Glow(frame)
		end
		frame.Name:ClearAllPoints()
		frame.Level:ClearAllPoints()
		if NP.db.units[frame.UnitType].name.enable then
			NP:Update_Name(frame)
			frame.Name:SetTextColor(frame.Name.r, frame.Name.g, frame.Name.b)
		else
			frame.Name:SetText()
		end
		if NP.db.units[frame.UnitType].level.enable then
			NP:Update_Level(frame)
		end
		NP:Update_RaidIcon(frame)
		NP:Configure_NameOnlyGlow(frame)
	end
end

function NP:StyleFilterConditionCheck(frame, filter, trigger)
	local passed -- skip StyleFilterPass when triggers are empty

	-- Name
	if trigger.names and next(trigger.names) then
		for _, value in pairs(trigger.names) do
			if value then -- only run if at least one is selected
				local name = trigger.names[frame.UnitName]
				if (not trigger.negativeMatch and name) or (trigger.negativeMatch and not name) then passed = true else return end
				break -- we can execute this once on the first enabled option then kill the loop
			end
		end
	end

	-- Health
	if trigger.healthThreshold then
		local health = (trigger.healthUsePlayer and UnitHealth("player")) or frame.oldHealthBar:GetValue() or 0
		local maxHealth = (trigger.healthUsePlayer and UnitHealthMax("player")) or select(2, frame.oldHealthBar:GetMinMaxValues()) or 0
		local percHealth = (maxHealth and (maxHealth > 0) and health/maxHealth) or 0
		local underHealthThreshold = trigger.underHealthThreshold and (trigger.underHealthThreshold ~= 0) and (trigger.underHealthThreshold > percHealth)
		local overHealthThreshold = trigger.overHealthThreshold and (trigger.overHealthThreshold ~= 0) and (trigger.overHealthThreshold < percHealth)
		if underHealthThreshold or overHealthThreshold then passed = true else return end
	end

	-- Power
	if trigger.powerThreshold then
		local power, maxPower = UnitPower("player"), UnitPowerMax("player")
		local percPower = (maxPower and (maxPower > 0) and power/maxPower) or 0
		local underPowerThreshold = trigger.underPowerThreshold and (trigger.underPowerThreshold ~= 0) and (trigger.underPowerThreshold > percPower)
		local overPowerThreshold = trigger.overPowerThreshold and (trigger.overPowerThreshold ~= 0) and (trigger.overPowerThreshold < percPower)
		if underPowerThreshold or overPowerThreshold then passed = true else return end
	end

	-- Require Target
	if trigger.requireTarget then
		if UnitExists("target") then passed = true else return end
	end

	-- Player Combat
	if trigger.inCombat or trigger.outOfCombat then
		local inCombat = UnitAffectingCombat("player")
		if (trigger.inCombat and inCombat) or (trigger.outOfCombat and not inCombat) then passed = true else return end
	end

	-- Player Target
	if trigger.isTarget or trigger.notTarget then
		if (trigger.isTarget and frame.isTarget) or (trigger.notTarget and not frame.isTarget) then passed = true else return end
	end

	-- Group Role
	if trigger.role.tank or trigger.role.healer or trigger.role.damager then
		if trigger.role[NP.TriggerConditions.roles[E:GetPlayerRole()]] then passed = true else return end
	end

	do
		-- Instance Type
		local activeID = trigger.location.instanceIDEnabled
		local activeType = trigger.instanceType.none or trigger.instanceType.scenario or trigger.instanceType.party or trigger.instanceType.raid or trigger.instanceType.arena or trigger.instanceType.pvp
		local instanceName, instanceType, difficultyID, instanceID, _

		if activeType or activeID then
			instanceName, instanceType, difficultyID, _, _, _, _, instanceID = GetInstanceInfo()
		end

		if activeType then
			if trigger.instanceType[instanceType] then
				passed = true

				-- Instance Difficulty
				if instanceType == "raid" or instanceType == "party" then
					local D = trigger.instanceDifficulty[(instanceType == "party" and "dungeon") or instanceType]
					for _, value in pairs(D) do
						if value and not D[NP.TriggerConditions.difficulties[difficultyID]] then return end
					end
				end
			else return end
		end

		-- Location
		if activeID or trigger.location.mapIDEnabled or trigger.location.zoneNamesEnabled or trigger.location.subZoneNamesEnabled then
			if activeID and next(trigger.location.instanceIDs) then
				if (instanceID and trigger.location.instanceIDs[tostring(instanceID)]) or trigger.location.instanceIDs[instanceName] then passed = true else return end
			end
			if trigger.location.mapIDEnabled and next(trigger.location.mapIDs) then
				local mapID = GetCurrentMapAreaID()
				local mapName = GetMapNameByID(mapID)
				if (mapID and trigger.location.mapIDs[tostring(mapID)]) or trigger.location.mapIDs[mapName] then passed = true else return end
			end
			if trigger.location.zoneNamesEnabled and next(trigger.location.zoneNames) then
				local realZoneText = GetRealZoneText()
				if trigger.location.zoneNames[realZoneText] then passed = true else return end
			end
			if trigger.location.subZoneNamesEnabled and next(trigger.location.subZoneNames) then
				local subZoneText = GetSubZoneText()
				if trigger.location.subZoneNames[subZoneText] then passed = true else return end
			end
		end
	end

	-- Level
	if trigger.level then
		local myLevel = E.mylevel
		local level = NP:UnitLevel(frame)
		level = level == "??" and -1 or tonumber(level)
		local curLevel = (trigger.curlevel and trigger.curlevel ~= 0 and (trigger.curlevel == level))
		local minLevel = (trigger.minlevel and trigger.minlevel ~= 0 and (trigger.minlevel <= level))
		local maxLevel = (trigger.maxlevel and trigger.maxlevel ~= 0 and (trigger.maxlevel >= level))
		local matchMyLevel = trigger.mylevel and (level == myLevel)
		if curLevel or minLevel or maxLevel or matchMyLevel then passed = true else return end
	end

	-- Resting
	if trigger.isResting then
		if IsResting() then passed = true else return end
	end

	-- Unit Type
	if trigger.nameplateType and trigger.nameplateType.enable then
		if trigger.nameplateType[NP.TriggerConditions.frameTypes[frame.UnitType]] then passed = true else return end
	end

	-- Reaction Type
	if trigger.reactionType and trigger.reactionType.enable then
		local reaction = frame.UnitReaction
		if (reaction == 1 and trigger.reactionType.tapped)
		or ((reaction == 2 or reaction == 3) and trigger.reactionType.hostile)
		or (reaction == 4 and trigger.reactionType.neutral)
		or (reaction == 5 and trigger.reactionType.friendly)
		then passed = true else return end
	end

	-- Raid Target
	if trigger.raidTarget.star or trigger.raidTarget.circle or trigger.raidTarget.diamond or trigger.raidTarget.triangle or trigger.raidTarget.moon or trigger.raidTarget.square or trigger.raidTarget.cross or trigger.raidTarget.skull then
		if trigger.raidTarget[NP.TriggerConditions.raidTargets[frame.RaidIconType]] then passed = true else return end
	end

	-- Casting
	if trigger.casting then
		local b, c = frame.CastBar, trigger.casting

		-- Spell
		if b.spellName then
			if c.spells and next(c.spells) then
				for _, value in pairs(c.spells) do
					if value then -- only run if at least one is selected
						local castingSpell = c.spells[b.spellName]
						if (c.notSpell and not castingSpell) or (castingSpell and not c.notSpell) then passed = true else return end
						break -- we can execute this once on the first enabled option then kill the loop
					end
				end
			end
		end

		-- Status
		if c.isCasting or c.isChanneling or c.notCasting or c.notChanneling then
			if (c.isCasting and b.casting) or (c.isChanneling and b.channeling)
			or (c.notCasting and not b.casting) or (c.notChanneling and not b.channeling) then passed = true else return end
		end

		-- Interruptible
		if c.interruptible or c.notInterruptible then
			if (b.casting or b.channeling) and ((c.interruptible and not b.notInterruptible) or (c.notInterruptible and b.notInterruptible)) then
				passed = true
			else
				return
			end
		end
	end

	-- Cooldown
	if trigger.cooldowns and trigger.cooldowns.names and next(trigger.cooldowns.names) then
		local cooldown = NP:StyleFilterCooldownCheck(trigger.cooldowns.names, trigger.cooldowns.mustHaveAll)
		if cooldown ~= nil then -- ignore if none are set to ONCD or OFFCD
			if cooldown then passed = true else return end
		end
	end

	-- Buffs
	if frame.Buffs and trigger.buffs and trigger.buffs.names and next(trigger.buffs.names) then
		local buff = NP:StyleFilterAuraCheck(trigger.buffs.names, frame.Buffs, trigger.buffs.mustHaveAll, trigger.buffs.missing, trigger.buffs.minTimeLeft, trigger.buffs.maxTimeLeft)
		if buff ~= nil then -- ignore if none are selected
			if buff then passed = true else return end
		end
	end

	-- Debuffs
	if frame.Debuffs and trigger.debuffs and trigger.debuffs.names and next(trigger.debuffs.names) then
		local debuff = NP:StyleFilterAuraCheck(trigger.debuffs.names, frame.Debuffs, trigger.debuffs.mustHaveAll, trigger.debuffs.missing, trigger.debuffs.minTimeLeft, trigger.debuffs.maxTimeLeft)
		if debuff ~= nil then -- ignore if none are selected
			if debuff then passed = true else return end
		end
	end

	-- Totems
	if frame.UnitName and trigger.totems.enable then
		local totem = NP.Totems[frame.UnitName]
		if totem then if trigger.totems[totem] then passed = true else return end end
	end

	-- Unique Units
	if frame.UnitName and trigger.uniqueUnits.enable then
		local unit = NP.UniqueUnits[frame.UnitName]
		if unit then if trigger.uniqueUnits[unit] then passed = true else return end end
	end

	-- Plugin Callback
	if NP.StyleFilterCustomChecks then
		for _, customCheck in pairs(NP.StyleFilterCustomChecks) do
			local custom = customCheck(frame, filter, trigger)
			if custom ~= nil then -- ignore if nil return
				if custom then passed = true else return end
			end
		end
	end

	-- Pass it along
	if passed then
		NP:StyleFilterPass(frame, filter.actions)
	end
end

function NP:StyleFilterPass(frame, actions)
	local healthBarEnabled = (frame.UnitType and NP.db.units[frame.UnitType].health.enable) or (frame.isTarget and NP.db.alwaysShowTargetHealth)
	local healthBarShown = healthBarEnabled and frame.Health:IsShown()

	NP:StyleFilterSetChanges(frame, actions,
		(healthBarShown and actions.color and actions.color.health), --HealthColorChanged
		(healthBarShown and actions.color and actions.color.border and frame.Health.backdrop), --BorderChanged
		(healthBarShown and actions.flash and actions.flash.enable and frame.FlashTexture), --FlashingHealth
		(healthBarShown and actions.texture and actions.texture.enable), --TextureChanged
		(healthBarShown and actions.scale and actions.scale ~= 1), --ScaleChanged
		(actions.frameLevel and actions.frameLevel ~= 0), --FrameLevelChanged
		(actions.alpha and actions.alpha ~= -1), --AlphaChanged
		(actions.color and actions.color.name), --NameColorChanged
		(actions.nameOnly), --NameOnlyChanged
		(actions.hide), --VisibilityChanged
		(actions.icon), --IconChanged
		(actions.iconOnly) --IconOnlyChanged
	)
end

function NP:StyleFilterClear(frame)
	if frame and frame.StyleChanged then
		NP:StyleFilterClearChanges(frame, frame.HealthColorChanged, frame.BorderChanged, frame.FlashingHealth, frame.TextureChanged, frame.ScaleChanged, frame.FrameLevelChanged, frame.AlphaChanged, frame.NameColorChanged, frame.NameOnlyChanged, frame.VisibilityChanged, frame.IconChanged, frame.IconOnlyChanged)
	end
end

function NP:StyleFilterSort(place)
	if self[2] and place[2] then
		return self[2] > place[2] --Sort by priority: 1=first, 2=second, 3=third, etc
	end
end

function NP:StyleFilterClearVariables(nameplate)
	nameplate.ActionScale = nil
	nameplate.ThreatScale = nil
end

NP.StyleFilterTriggerList = {}
NP.StyleFilterTriggerEvents = {}
function NP:StyleFilterConfigure()
	twipe(NP.StyleFilterTriggerList)
	twipe(NP.StyleFilterTriggerEvents)

	for filterName, filter in pairs(E.global.nameplates.filters) do
		local t = filter.triggers
		if t and E.db.nameplates and E.db.nameplates.filters then
			if E.db.nameplates.filters[filterName] and E.db.nameplates.filters[filterName].triggers and E.db.nameplates.filters[filterName].triggers.enable then
				tinsert(NP.StyleFilterTriggerList, {filterName, t.priority or 1})

				NP.StyleFilterTriggerEvents.UpdateElement_All = 1
				NP.StyleFilterTriggerEvents.NAME_PLATE_UNIT_ADDED = 1

				if t.casting then
					if next(t.casting.spells) then
						for _, value in pairs(t.casting.spells) do
							if value then
								NP.StyleFilterTriggerEvents.FAKE_Casting = 0
								break
							end
						end
					end

					if (t.casting.interruptible or t.casting.notInterruptible)
					or (t.casting.isCasting or t.casting.isChanneling or t.casting.notCasting or t.casting.notChanneling) then
						NP.StyleFilterTriggerEvents.FAKE_Casting = 0
					end
				end

				-- real events
				NP.StyleFilterTriggerEvents.PLAYER_TARGET_CHANGED = true

				if t.raidTarget and (t.raidTarget.star or t.raidTarget.circle or t.raidTarget.diamond or t.raidTarget.triangle or t.raidTarget.moon or t.raidTarget.square or t.raidTarget.cross or t.raidTarget.skull) then
					NP.StyleFilterTriggerEvents.RAID_TARGET_UPDATE = 1
				end

				if t.healthThreshold then
					NP.StyleFilterTriggerEvents.UNIT_HEALTH = 1
					NP.StyleFilterTriggerEvents.UNIT_MAXHEALTH = 1
					NP.StyleFilterTriggerEvents.UNIT_HEALTH_FREQUENT = 1
				end

				if t.powerThreshold then
					NP.StyleFilterTriggerEvents.UNIT_POWER = 1
					NP.StyleFilterTriggerEvents.UNIT_POWER_FREQUENT = 1
					NP.StyleFilterTriggerEvents.UNIT_DISPLAYPOWER = 1
				end

				if t.names and next(t.names) then
					for _, value in pairs(t.names) do
						if value then
							NP.StyleFilterTriggerEvents.UNIT_NAME_UPDATE = 1
							break
						end
					end
				end

				if t.inCombat or t.outOfCombat then
					NP.StyleFilterTriggerEvents.PLAYER_REGEN_DISABLED = true
					NP.StyleFilterTriggerEvents.PLAYER_REGEN_ENABLED = true
				end

				if t.location then
					if (t.location.mapIDEnabled and next(t.location.mapIDs))
					or (t.location.instanceIDEnabled and next(t.location.instanceIDs))
					or (t.location.zoneNamesEnabled and next(t.location.zoneNames))
					or (t.location.subZoneNamesEnabled and next(t.location.subZoneNames)) then
						NP.StyleFilterTriggerEvents.LOADING_SCREEN_DISABLED = 1
						NP.StyleFilterTriggerEvents.ZONE_CHANGED_NEW_AREA = 1
						NP.StyleFilterTriggerEvents.ZONE_CHANGED_INDOORS = 1
						NP.StyleFilterTriggerEvents.ZONE_CHANGED = 1
					end
				end

				if t.isResting then
					NP.StyleFilterTriggerEvents.PLAYER_UPDATE_RESTING = 1
				end

				if t.cooldowns and t.cooldowns.names and next(t.cooldowns.names) then
					for _, value in pairs(t.cooldowns.names) do
						if value == "ONCD" or value == "OFFCD" then
							NP.StyleFilterTriggerEvents.SPELL_UPDATE_COOLDOWN = 1
							break
						end
					end
				end

				if t.buffs and t.buffs.names and next(t.buffs.names) then
					for _, value in pairs(t.buffs.names) do
						if value then
							NP.StyleFilterTriggerEvents.UNIT_AURA = true
							break
						end
					end
				end

				if t.debuffs and t.debuffs.names and next(t.debuffs.names) then
					for _, value in pairs(t.debuffs.names) do
						if value then
							NP.StyleFilterTriggerEvents.UNIT_AURA = true
							break
						end
					end
				end
			end
		end
	end

	if next(NP.StyleFilterTriggerList) then
		sort(NP.StyleFilterTriggerList, NP.StyleFilterSort) -- sort by priority
	else
		NP:ForEachPlate("StyleFilterClear")
	end
end

function NP:StyleFilterUpdate(frame, event)
	local hasEvent = NP.StyleFilterTriggerEvents[event]
	if not hasEvent then
		return
	elseif hasEvent == true then -- skip on 1 or 0
		if not frame.StyleFilterWaitTime then
			frame.StyleFilterWaitTime = GetTime()
		elseif GetTime() > (frame.StyleFilterWaitTime + 0.1) then
			frame.StyleFilterWaitTime = nil
		else
			return -- block calls faster than 0.1 second
		end
	end

	NP:StyleFilterClear(frame)

	for filterNum in ipairs(NP.StyleFilterTriggerList) do
		local filter = E.global.nameplates.filters[NP.StyleFilterTriggerList[filterNum][1]]
		if filter then
			NP:StyleFilterConditionCheck(frame, filter, filter.triggers)
		end
	end
end

function NP:StyleFilterAddCustomCheck(name, func)
	if not NP.StyleFilterCustomChecks then
		NP.StyleFilterCustomChecks = {}
	end

	NP.StyleFilterCustomChecks[name] = func
end

function NP:StyleFilterRemoveCustomCheck(name)
	if not NP.StyleFilterCustomChecks then return end

	NP.StyleFilterCustomChecks[name] = nil
end

function NP:PLAYER_LOGOUT()
	NP:StyleFilterClearDefaults(E.global.nameplates.filters)
end

function NP:StyleFilterClearDefaults(tbl)
	for filterName, filterTable in pairs(tbl) do
		if G.nameplates.filters[filterName] then
			local defaultTable = E:CopyTable({}, E.StyleFilterDefaults)
			E:CopyTable(defaultTable, G.nameplates.filters[filterName])
			E:RemoveDefaults(filterTable, defaultTable)
		else
			E:RemoveDefaults(filterTable, E.StyleFilterDefaults)
		end
	end
end

function NP:StyleFilterCopyDefaults(tbl)
	E:CopyDefaults(tbl, E.StyleFilterDefaults)
end

function NP:StyleFilterInitialize()
	for _, filterTable in pairs(E.global.nameplates.filters) do
		NP:StyleFilterCopyDefaults(filterTable)
	end
end