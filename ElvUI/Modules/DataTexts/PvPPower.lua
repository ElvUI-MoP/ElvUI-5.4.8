local E, L, V, P, G = unpack(select(2, ...))
local DT = E:GetModule("DataTexts")

local format, join = string.format, string.join

local STAT_PVP_POWER = STAT_PVP_POWER

local lastPanel
local displayString = ""

local function OnEvent(self)
	self.text:SetFormattedText(displayString, STAT_PVP_POWER, GetCombatRatingBonus(CR_PVP_POWER))

	lastPanel = self
end

local function OnEnter(self)
	DT:SetupTooltip(self)

	local pvpPower = BreakUpLargeNumbers(GetCombatRating(CR_PVP_POWER))
	local pvpDamage = GetPvpPowerDamage()
	local pvpHealing = GetPvpPowerHealing()

	if pvpHealing > pvpDamage then
		DT.tooltip:AddDoubleLine(STAT_PVP_POWER, format("%.2F%%", pvpHealing).." ("..SHOW_COMBAT_HEALING..")", 1, 1, 1)
		DT.tooltip:AddLine(PVP_POWER_TOOLTIP, nil, nil, nil, true)
		DT.tooltip:AddLine(format(PVP_POWER_HEALING_TOOLTIP, pvpPower, pvpHealing, pvpDamage))
	else
		DT.tooltip:AddDoubleLine(STAT_PVP_POWER, format("%.2F%%", pvpDamage).." ("..DAMAGE..")", 1, 1, 1)
		DT.tooltip:AddLine(PVP_POWER_TOOLTIP, nil, nil, nil, true)
		DT.tooltip:AddLine(format(PVP_POWER_DAMAGE_TOOLTIP, pvpPower, pvpDamage, pvpHealing))
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

DT:RegisterDatatext("PvP Power", {"PVP_POWER_UPDATE"}, OnEvent, nil, nil, OnEnter, nil, STAT_PVP_POWER)