local E, L, V, P, G = unpack(select(2, ...))
local DT = E:GetModule("DataTexts")

local format, join = string.format, string.join
local STAT_RESILIENCE = STAT_RESILIENCE

local lastPanel
local displayString = ""

local function OnEvent(self)
	lastPanel = self

	local ratingBonus = GetCombatRatingBonus(COMBAT_RATING_RESILIENCE_PLAYER_DAMAGE_TAKEN)
	local damageReduction = ratingBonus + GetModResilienceDamageReduction()

	self.text:SetFormattedText(displayString, STAT_RESILIENCE, damageReduction)
end

local function OnEnter(self)
	DT:SetupTooltip(self)

	local resilienceRating = BreakUpLargeNumbers(GetCombatRating(COMBAT_RATING_RESILIENCE_PLAYER_DAMAGE_TAKEN))
	local ratingBonus = GetCombatRatingBonus(COMBAT_RATING_RESILIENCE_PLAYER_DAMAGE_TAKEN)
	local damageReduction = ratingBonus + GetModResilienceDamageReduction()

	DT.tooltip:AddDoubleLine(STAT_RESILIENCE, format("%.2F%%", damageReduction), 1, 1, 1)
	DT.tooltip:AddLine(RESILIENCE_TOOLTIP, nil, nil, nil, true)
	DT.tooltip:AddLine(format(STAT_RESILIENCE_BASE_TOOLTIP, resilienceRating, ratingBonus))

	DT.tooltip:Show()
end

local function ValueColorUpdate(hex)
	displayString = join("", "%s: ", hex, "%.2f%%|r")

	if lastPanel ~= nil then
		OnEvent(lastPanel)
	end
end
E.valueColorUpdateFuncs[ValueColorUpdate] = true

DT:RegisterDatatext("PvP Resilience", {"COMBAT_RATING_UPDATE"}, OnEvent, nil, nil, OnEnter, nil, STAT_RESILIENCE)