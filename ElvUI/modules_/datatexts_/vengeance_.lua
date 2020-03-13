local E, L, V, P, G = unpack(select(2, ...))
local DT = E:GetModule("DataTexts")

local join, match = string.join, string.match

local displayString = ""
local lastPanel
local self = lastPanel

local vengeance = GetSpellInfo(93098) or GetSpellInfo(76691)
local value, tooltip, tooltiptext

tooltip = CreateFrame("GameTooltip", "VengeanceTooltip", E.UIParent, "GameTooltipTemplate")
tooltiptext = _G[tooltip:GetName().."TextLeft2"]
tooltip:SetOwner(E.UIParent, "ANCHOR_NONE")
tooltiptext:SetText("")

local function OnEvent(self)
	if VengeanceTooltip and not VengeanceTooltip:IsShown() then
		tooltiptext = _G[tooltip:GetName().."TextLeft2"]
		tooltip:SetOwner(E.UIParent, "ANCHOR_NONE")
		tooltiptext:SetText("")
	end

	local name = UnitAura("player", vengeance, nil, "PLAYER|HELPFUL")

	if name then
		tooltip:ClearLines()
		tooltip:SetUnitBuff("player", name)
		value = (tooltiptext:GetText() and tonumber(match(tostring(tooltiptext:GetText()), "%d+"))) or -1
	else
		value = 0
	end

	self.text:SetFormattedText(displayString, vengeance, value)

	lastPanel = self
end

local function ValueColorUpdate(hex)
	displayString = join("", "%s: ", hex, "%s|r")

	if lastPanel ~= nil then
		OnEvent(lastPanel)
	end
end
E.valueColorUpdateFuncs[ValueColorUpdate] = true

DT:RegisterDatatext("Vengeance", {"UNIT_AURA", "PLAYER_ENTERING_WORLD", "CLOSE_WORLD_MAP"}, OnEvent, nil, nil, nil, nil, L["Vengeance"])