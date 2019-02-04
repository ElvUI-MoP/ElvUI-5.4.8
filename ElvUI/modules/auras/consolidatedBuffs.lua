local E, L, V, P, G = unpack(select(2, ...))
local A = E:GetModule("Auras")
local LSM = E.Libs.LSM

local _G = _G
local unpack = unpack
local twipe = table.wipe
local format = string.format

local GetTime = GetTime

local CreateFrame = CreateFrame
local GetRaidBuffTrayAuraInfo = GetRaidBuffTrayAuraInfo
local CooldownFrame_SetTimer = CooldownFrame_SetTimer
local NUM_LE_RAID_BUFF_TYPES = NUM_LE_RAID_BUFF_TYPES

local Masque = E.Masque
local MasqueGroup = Masque and Masque:Group("ElvUI", "Consolidated Buffs")

A.DefaultIcons = {
	[1] = "Interface\\Icons\\Spell_Magic_GreaterBlessingofKings",	-- Stats
	[2] = "Interface\\Icons\\Spell_Holy_WordFortitude",				-- Stamina
	[3] = "Interface\\Icons\\INV_Misc_Horn_02",						-- Attack Power
	[4] = "Interface\\Icons\\INV_Helmet_08",						-- Attack Speed
	[5] = "Interface\\Icons\\Spell_Holy_MagicalSentry",				-- Spell Power
	[6] = "Interface\\Icons\\Spell_Shadow_SpectralSight",			-- Spell Haste
	[7] = "Interface\\Icons\\ability_monk_prideofthetiger",			-- Critical Strike
	[8] = "Interface\\Icons\\Spell_Holy_GreaterBlessingofKings"		-- Mastery
}

function A:UpdateConsolidatedTime(elapsed)
	self.expiration = self.expiration - elapsed
	if self.nextupdate > 0 then
		self.nextupdate = self.nextupdate - elapsed
		return
	end

	if self.expiration <= 0 then
		self.timer:SetText("")
		self:SetScript("OnUpdate", nil)
		return
	end

	local timeColors, timeThreshold = E.TimeColors, E.db.cooldown.threshold
	if not timeThreshold then
		timeThreshold = E.TimeThreshold
	end

	local hhmmThreshold, mmssThreshold
	if E.db.cooldown.checkSeconds then
		hhmmThreshold, mmssThreshold = E.db.cooldown.hhmmThreshold, E.db.cooldown.mmssThreshold
	else
		hhmmThreshold, mmssThreshold = E.db.cooldown.checkSeconds and E.db.cooldown.hhmmThreshold or nil, E.db.cooldown.checkSeconds and E.db.cooldown.mmssThreshold or nil
	end

	local value1, formatID, nextUpdate, value2 = E:GetTimeInfo(self.expiration, timeThreshold, hhmmThreshold, mmssThreshold)
	self.nextUpdate = nextUpdate

	self.timer:SetFormattedText(format("%s%s|r", timeColors[formatID], E.TimeFormats[formatID][1]), value1, value2)
end

function A:UpdateReminder(event, unit)
	if event == "UNIT_AURA" and unit ~= "player" then return end

	local frame = self.frame
	local reverseStyle = E.db.auras.consolidatedBuffs.reverseStyle

	for i = 1, NUM_LE_RAID_BUFF_TYPES do
		local spellName, _, texture, duration, expirationTime = GetRaidBuffTrayAuraInfo(i)
		local button = self.frame[i]

		if spellName then
			button.expiration = expirationTime - GetTime()
			button.duration = duration
			button.nextupdate = 0
			button.t:SetTexture(texture)

			if (duration == 0 and expirationTime == 0) or E.db.auras.consolidatedBuffs.durations ~= true then
				button.t:SetAlpha(reverseStyle == true and 1 or 0.3)
				button:SetScript("OnUpdate", nil)
				button.timer:SetText(nil)
				CooldownFrame_SetTimer(button.cd, 0, 0, 0)
			else
				CooldownFrame_SetTimer(button.cd, expirationTime - duration, duration, 1)
				button.t:SetAlpha(1)
				button.cd:SetReverse(reverseStyle == true and true or false)
				button:SetScript("OnUpdate", A.UpdateConsolidatedTime)
			end
			button.spellName = spellName
		else
			CooldownFrame_SetTimer(button.cd, 0, 0, 0)
			button.spellName = nil
			button.t:SetAlpha(reverseStyle == true and 0.3 or 1)
			button:SetScript("OnUpdate", nil)
			button.timer:SetText(nil)
			button.t:SetTexture(self.DefaultIcons[i])
		end
	end
end

function A:Button_OnEnter()
	GameTooltip:Hide()
	GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT", -3, self:GetHeight() + 2)
	GameTooltip:ClearLines()

	local parent = self:GetParent()
	local id = parent:GetID()

	if parent.spellName then
		GameTooltip:SetUnitConsolidatedBuff("player", id)
	else
		GameTooltip:AddLine(_G[("RAID_BUFF_%d"):format(id)])
	end

	GameTooltip:Show()
end

function A:Button_OnLeave()
	GameTooltip:Hide()
end

function A:CreateButton(i)
	local button = CreateFrame("Button", "ElvUIConsolidatedBuff"..i, ElvUI_ConsolidatedBuffs)

	button.t = button:CreateTexture(nil, "OVERLAY")
	button.t:SetTexCoord(unpack(E.TexCoords))
	button.t:SetInside()
	button.t:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")

	button.cd = CreateFrame("Cooldown", nil, button, "CooldownFrameTemplate")
	button.cd:SetInside()
	button.cd.noOCC = true
	button.cd.noCooldownCount = true

	button.timer = button.cd:CreateFontString(nil, "OVERLAY")
	button.timer:Point("CENTER")

	local ButtonData = {
		FloatingBG = nil,
		Icon = button.t,
		Cooldown = button.cd,
		Flash = nil,
		Pushed = nil,
		Normal = nil,
		Disabled = nil,
		Checked = nil,
		Border = nil,
		AutoCastable = nil,
		Highlight = nil,
		HotKey = nil,
		Count = nil,
		Name = nil,
		Duration = false,
		AutoCast = nil,
	}

	if MasqueGroup and E.private.auras.masque.consolidatedBuffs then
		MasqueGroup:AddButton(button, ButtonData)
	elseif not E.private.auras.masque.consolidatedBuffs then
		button:SetTemplate("Default")
	end

	return button
end

function A:EnableCB()
	ElvUI_ConsolidatedBuffs:Show()

	BuffFrame:RegisterUnitEvent("UNIT_AURA", "player")
	self:RegisterEvent("UNIT_AURA", "UpdateReminder")
	self:RegisterEvent("GROUP_ROSTER_UPDATE", "UpdateReminder")
	self:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED", "UpdateReminder")
	E.RegisterCallback(self, "RoleChanged", "Update_ConsolidatedBuffsSettings")

	self:UpdateReminder()
end

function A:DisableCB()
	ElvUI_ConsolidatedBuffs:Hide()

	if not E.private.auras.disableBlizzard then
		BuffFrame:RegisterUnitEvent("UNIT_AURA", "player")
	else
		BuffFrame:UnregisterEvent("UNIT_AURA")
	end

	self:UnregisterEvent("UNIT_AURA")
	self:UnregisterEvent("GROUP_ROSTER_UPDATE")
	self:UnregisterEvent("PLAYER_SPECIALIZATION_CHANGED")
	E.UnregisterCallback(self, "RoleChanged", "Update_ConsolidatedBuffsSettings")
end

local ignoreIcons = {}
function A:Update_ConsolidatedBuffsSettings(isCallback)
	local frame = self.frame
	frame:Width(E.ConsolidatedBuffsWidth)

	twipe(ignoreIcons)

	if E.db.auras.consolidatedBuffs.filter then
		if E.role == "Caster" then
			ignoreIcons[3] = true
			ignoreIcons[4] = 2
		else
			ignoreIcons[5] = 3
			ignoreIcons[6] = 4
		end
	end

	for i = 1, NUM_LE_RAID_BUFF_TYPES do
		local button = frame[i]
		button.t:SetAlpha(1)
		button:ClearAllPoints()

		button:SetWidth(E.ConsolidatedBuffsWidth)
		button:SetHeight(E.ConsolidatedBuffsWidth)

		if i == 1 then
			button:Point("TOP", ElvUI_ConsolidatedBuffs, "TOP", 0, 0)
		else
			button:Point("TOP", frame[ignoreIcons[i - 1] or (i - 1)], "BOTTOM", 0, E.Border - E.Spacing)
		end

		if ignoreIcons[i] then
			button:Hide()
		else
			button:Show()
		end

		if E.db.auras.consolidatedBuffs.durations then
			button.cd:SetAlpha(1)
		else
			button.cd:SetAlpha(0)
		end

		local font = LSM:Fetch("font", E.db.auras.consolidatedBuffs.font)
		button.timer:FontTemplate(font, E.db.auras.consolidatedBuffs.fontSize, E.db.auras.consolidatedBuffs.fontOutline)

		if E.private.auras.disableBlizzard then
			local buffIcon = _G[("ConsolidatedBuffsTooltipBuff%d"):format(i)]
			buffIcon:ClearAllPoints()
			buffIcon:SetAllPoints(frame[i])
			buffIcon:SetParent(frame[i])
			buffIcon:SetAlpha(0)
			buffIcon:SetScript("OnEnter", A.Button_OnEnter)
			buffIcon:SetScript("OnLeave", A.Button_OnLeave)
		end
	end

	if not isCallback then
		if E.db.auras.consolidatedBuffs.enable and E.private.general.minimap.enable and E.private.auras.disableBlizzard then
			A:EnableCB()
		else
			A:DisableCB()
		end
	end

	if MasqueGroup and E.private.auras.masque.consolidatedBuffs and E.db.auras.consolidatedBuffs.enable then MasqueGroup:ReSkin() end
end

function A:Construct_ConsolidatedBuffs()
	local frame = CreateFrame("Frame", "ElvUI_ConsolidatedBuffs", Minimap)

	if not Masque or not E.private.auras.masque.consolidatedBuffs then
		frame:SetTemplate("Default")
	end

	frame:Width(E.ConsolidatedBuffsWidth)
	if E.db.auras.consolidatedBuffs.position == "LEFT" then
		frame:Point("TOPRIGHT", Minimap.backdrop, "TOPLEFT", E.Border - E.Spacing*3, 0)
		frame:Point("BOTTOMRIGHT", Minimap.backdrop, "BOTTOMLEFT", E.Border - E.Spacing*3, 0)
	else
		frame:Point("TOPLEFT", Minimap.backdrop, "TOPRIGHT", -E.Border + E.Spacing*3, 0)
		frame:Point("BOTTOMLEFT", Minimap.backdrop, "BOTTOMRIGHT", -E.Border + E.Spacing*3, 0)
	end
	self.frame = frame

	for i = 1, NUM_LE_RAID_BUFF_TYPES do
		frame[i] = self:CreateButton(i)
		frame[i]:SetID(i)
	end

	if Masque and MasqueGroup then
		A.CBMasqueGroup = MasqueGroup
	end

	self:Update_ConsolidatedBuffsSettings()
end

function A:UpdatePosition()
	Minimap:ClearAllPoints()
	ElvConfigToggle:ClearAllPoints()
	ElvUI_ConsolidatedBuffs:ClearAllPoints()

	if E.db.auras.consolidatedBuffs.position == "LEFT" then
		Minimap:Point("TOPRIGHT", MMHolder, "TOPRIGHT", -E.Border, -E.Border)

		ElvConfigToggle:SetPoint("TOPRIGHT", LeftMiniPanel, "TOPLEFT", E.Border - E.Spacing*3, 0)
		ElvConfigToggle:SetPoint("BOTTOMRIGHT", LeftMiniPanel, "BOTTOMLEFT", E.Border - E.Spacing*3, 0)

		ElvUI_ConsolidatedBuffs:SetPoint("TOPRIGHT", Minimap.backdrop, "TOPLEFT", E.Border - E.Spacing*3, 0)
		ElvUI_ConsolidatedBuffs:SetPoint("BOTTOMRIGHT", Minimap.backdrop, "BOTTOMLEFT", E.Border - E.Spacing*3, 0)
	else
		Minimap:Point("TOPLEFT", MMHolder, "TOPLEFT", E.Border, -E.Border)

		ElvConfigToggle:SetPoint("TOPLEFT", RightMiniPanel, "TOPRIGHT", -E.Border + E.Spacing*3, 0)
		ElvConfigToggle:SetPoint("BOTTOMLEFT", RightMiniPanel, "BOTTOMRIGHT", -E.Border + E.Spacing*3, 0)

		ElvUI_ConsolidatedBuffs:SetPoint("TOPLEFT", Minimap.backdrop, "TOPRIGHT", -E.Border + E.Spacing*3, 0)
		ElvUI_ConsolidatedBuffs:SetPoint("BOTTOMLEFT", Minimap.backdrop, "BOTTOMRIGHT", -E.Border + E.Spacing*3, 0)
	end
end