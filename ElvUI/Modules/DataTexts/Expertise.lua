local E, L, V, P, G = unpack(select(2, ...))
local DT = E:GetModule("DataTexts")

local format, join = string.format, string.join

local GetCombatRatingBonus = GetCombatRatingBonus
local GetCombatRating = GetCombatRating
local GetEnemyDodgeChance = GetEnemyDodgeChance
local GetEnemyParryChance = GetEnemyParryChance
local GetExpertisePercent = GetExpertisePercent
local GetExpertise = GetExpertise
local IsDualWielding = IsDualWielding
local UnitAttackSpeed = UnitAttackSpeed
local CR_EXPERTISE_TOOLTIP = CR_EXPERTISE_TOOLTIP
local CR_EXPERTISE = CR_EXPERTISE
local DODGE_CHANCE = DODGE_CHANCE
local PARRY_CHANCE = PARRY_CHANCE
local STAT_EXPERTISE = STAT_EXPERTISE
local STAT_TARGET_LEVEL = STAT_TARGET_LEVEL

local displayString = ""
local skullTexture = "|TInterface\\TargetingFrame\\UI-TargetingFrame-Skull:0|t"
local text, level
local dodgeDisplay, parryDisplay
local lastPanel

local function OnEvent(self, event, unit)
	local expertise, offhandExpertise = GetExpertise()
	local _, offhandSpeed = UnitAttackSpeed("player")

	expertise = format("%.2f%%", expertise)
	offhandExpertise = format("%.2f%%", offhandExpertise)

	if offhandSpeed then
		text = expertise.." / "..offhandExpertise
	else
		text = expertise
	end
	self.text:SetFormattedText(displayString, STAT_EXPERTISE, text)

	lastPanel = self
end

local function OnEnter(self)
	DT:SetupTooltip(self)

	local expertisePercentDisplay
	local expertisePercent, offhandExpertisePercent = GetExpertise()

	expertisePercent = format("%.2f", expertisePercent)
	offhandExpertisePercent = format("%.2f", offhandExpertisePercent)

	if IsDualWielding() then
		expertisePercentDisplay = expertisePercent.."% / "..offhandExpertisePercent.."%"
	else
		expertisePercentDisplay = expertisePercent.."%"
	end

	DT.tooltip:AddLine(format(CR_EXPERTISE_TOOLTIP, expertisePercentDisplay, GetCombatRating(CR_EXPERTISE), GetCombatRatingBonus(CR_EXPERTISE)), nil, nil, nil, true)
	DT.tooltip:AddLine(" ")

	-- Dodge chance
	DT.tooltip:AddDoubleLine(STAT_TARGET_LEVEL, DODGE_CHANCE, 1, 1, 1, 1, 1, 1)

	for i = 0, 3 do
		local mainhandDodge, offhandDodge = GetEnemyDodgeChance(i)
		level = E.mylevel + i

		mainhandDodge = format("%.2f%%", mainhandDodge)
		offhandDodge = format("%.2f%%", offhandDodge)

		if i == 3 then
			level = level.." / "..skullTexture
		end

		if IsDualWielding() and mainhandDodge ~= offhandDodge then
			dodgeDisplay = mainhandDodge.." / "..offhandDodge
		else
			dodgeDisplay = mainhandDodge.."  "
		end

		DT.tooltip:AddDoubleLine("      "..level, dodgeDisplay.."  ")
	end

	-- Parry chance
	DT.tooltip:AddLine(" ")
	DT.tooltip:AddDoubleLine(STAT_TARGET_LEVEL, PARRY_CHANCE, 1, 1, 1, 1, 1, 1)

	for i = 0, 3 do
		local mainhandParry, offhandParry = GetEnemyParryChance(i)
		level = E.mylevel + i

		mainhandParry = format("%.2f%%", mainhandParry)
		offhandParry = format("%.2f%%", offhandParry)

		if i == 3 then
			level = level.." / "..skullTexture
		end

		if IsDualWielding() and mainhandParry ~= offhandParry then
			parryDisplay = mainhandParry.." / "..offhandParry
		else
			parryDisplay = mainhandParry.."  "
		end

		DT.tooltip:AddDoubleLine("      "..level, parryDisplay.."  ")
	end

	DT.tooltip:Show()
end

local function ValueColorUpdate(hex)
	displayString = join("", "%s: ", hex, "%s|r")

	if lastPanel ~= nil then
		OnEvent(lastPanel, 2000)
	end
end
E.valueColorUpdateFuncs[ValueColorUpdate] = true

DT:RegisterDatatext("Expertise", {"UNIT_STATS", "UNIT_AURA", "FORGE_MASTER_ITEM_CHANGED", "ACTIVE_TALENT_GROUP_CHANGED", "PLAYER_TALENT_UPDATE"}, OnEvent, nil, nil, OnEnter, nil, STAT_EXPERTISE)