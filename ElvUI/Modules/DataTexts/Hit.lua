local E, L, V, P, G = unpack(select(2, ...))
local DT = E:GetModule("DataTexts")

local format, join = string.format, string.join

local GetCombatRatingBonus = GetCombatRatingBonus
local GetCombatRating = GetCombatRating
local GetMeleeMissChance = GetMeleeMissChance
local GetSpellMissChance = GetSpellMissChance
local GetRangedMissChance = GetRangedMissChance
local IsDualWielding = IsDualWielding
local CR_HIT_MELEE = CR_HIT_MELEE
local CR_HIT_SPELL = CR_HIT_SPELL
local CR_HIT_RANGED = CR_HIT_RANGED
local MISS_CHANCE = MISS_CHANCE
local STAT_HIT_CHANCE = STAT_HIT_CHANCE
local STAT_TARGET_LEVEL = STAT_TARGET_LEVEL
local STAT_HIT_MELEE_TOOLTIP = STAT_HIT_MELEE_TOOLTIP
local STAT_HIT_SPELL_TOOLTIP = STAT_HIT_SPELL_TOOLTIP
local STAT_HIT_RANGED_TOOLTIP = STAT_HIT_RANGED_TOOLTIP
local STAT_HIT_NORMAL_ATTACKS = STAT_HIT_NORMAL_ATTACKS
local STAT_HIT_SPECIAL_ATTACKS = STAT_HIT_SPECIAL_ATTACKS

local skullTexture = "|TInterface\\TargetingFrame\\UI-TargetingFrame-Skull:0|t"
local displayString = ""
local hitRatingBonus
local missChance, level
local lastPanel

local function OnEvent(self)
	if E.role == "Caster" then
		hitRatingBonus = GetCombatRatingBonus(CR_HIT_SPELL)
	else
		if E.myclass == "HUNTER" then
			hitRatingBonus = GetCombatRatingBonus(CR_HIT_RANGED)
		else
			hitRatingBonus = GetCombatRatingBonus(CR_HIT_MELEE)
		end
	end

	self.text:SetFormattedText(displayString, L["Hit"], hitRatingBonus)

	lastPanel = self
end

local function OnEnter(self)
	DT:SetupTooltip(self)

	if E.role == "Caster" then
		DT.tooltip:AddLine(format(STAT_HIT_SPELL_TOOLTIP, GetCombatRating(CR_HIT_SPELL), GetCombatRatingBonus(CR_HIT_SPELL)))
		DT.tooltip:AddLine(" ")
		DT.tooltip:AddDoubleLine(STAT_TARGET_LEVEL, MISS_CHANCE, 1, 1, 1, 1, 1, 1)

		for i = 0, 3 do
			missChance = format("%.2f%%", GetSpellMissChance(i))
			level = E.mylevel + i
			if i == 3 then
				level = level.." / "..skullTexture
			end

			DT.tooltip:AddDoubleLine("      "..level, missChance.."    ")
		end
	else
		if E.myclass == "HUNTER" then
			DT.tooltip:AddLine(format(STAT_HIT_RANGED_TOOLTIP, GetCombatRating(CR_HIT_RANGED), GetCombatRatingBonus(CR_HIT_RANGED)))
			DT.tooltip:AddLine(" ")
			DT.tooltip:AddDoubleLine(STAT_TARGET_LEVEL, MISS_CHANCE, 1, 1, 1, 1, 1, 1)

			for i = 0, 3 do
				missChance = format("%.2f%%", GetRangedMissChance(i))
				level = E.mylevel + i
				if i == 3 then
					level = level.." / "..skullTexture
				end

				DT.tooltip:AddDoubleLine("      "..level, missChance.."    ")
			end
		else
			DT.tooltip:AddLine(format(STAT_HIT_MELEE_TOOLTIP, GetCombatRating(CR_HIT_MELEE), GetCombatRatingBonus(CR_HIT_MELEE)))
			DT.tooltip:AddLine(" ")
			DT.tooltip:AddDoubleLine(STAT_TARGET_LEVEL, MISS_CHANCE, 1, 1, 1, 1, 1, 1)

			if IsDualWielding() then
				DT.tooltip:AddLine(" ")
				DT.tooltip:AddLine(STAT_HIT_NORMAL_ATTACKS, 0.7, 0.7, 0.7)
			end

			for i = 0, 3 do
				missChance = format("%.2f%%", GetMeleeMissChance(i, false))
				level = E.mylevel + i
				if i == 3 then
					level = level.." / "..skullTexture
				end

				DT.tooltip:AddDoubleLine("      "..level, missChance.."    ")
			end

			if IsDualWielding() then
				DT.tooltip:AddLine(" ")
				DT.tooltip:AddLine(STAT_HIT_SPECIAL_ATTACKS, 0.7, 0.7, 0.7)

				for i = 0, 3 do
					missChance = format("%.2f%%", GetMeleeMissChance(i, true))
					level = E.mylevel + i
					if i == 3 then
						level = level.." / "..skullTexture
					end

					DT.tooltip:AddDoubleLine("      "..level, missChance.."    ")
				end
			end
		end
	end

	DT.tooltip:Show()
end

local function ValueColorUpdate(hex)
	displayString = join("", "%s: ", hex, "%.2f%%|r")

	if lastPanel ~= nil then
		OnEvent(lastPanel)
	end
end
E.valueColorUpdateFuncs[ValueColorUpdate] = true

DT:RegisterDatatext("Hit Rating", {"UNIT_STATS", "UNIT_AURA", "FORGE_MASTER_ITEM_CHANGED", "ACTIVE_TALENT_GROUP_CHANGED", "PLAYER_TALENT_UPDATE"}, OnEvent, nil, nil, OnEnter, nil, STAT_HIT_CHANCE)