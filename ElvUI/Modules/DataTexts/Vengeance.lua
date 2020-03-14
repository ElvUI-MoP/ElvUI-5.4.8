local E, L, V, P, G = unpack(select(2, ...))
local DT = E:GetModule("DataTexts")

local tonumber, tostring = tonumber, tostring
local join, match = string.join, string.match

local displayString = ""
local lastPanel

local vengeance = GetSpellInfo(93098) or GetSpellInfo(76691)

local tooltip = CreateFrame("GameTooltip", "VengeanceTooltip", E.UIParent, "GameTooltipTemplate")
tooltip:SetOwner(E.UIParent, "ANCHOR_NONE")
tooltip.text = _G[tooltip:GetName().."TextLeft2"]
tooltip.text:SetText("")

local function OnEvent(self)
	if VengeanceTooltip and not VengeanceTooltip:IsShown() then
		tooltip:SetOwner(E.UIParent, "ANCHOR_NONE")
		tooltip.text = _G[tooltip:GetName().."TextLeft2"]
		tooltip.text:SetText("")
	end

	local value
	local name = UnitAura("player", vengeance, nil, "PLAYER|HELPFUL")

	if name then
		tooltip:ClearLines()
		tooltip:SetUnitBuff("player", name)

		value = (tooltip.text:GetText() and tonumber(match(tostring(tooltip.text:GetText()), "%d+"))) or -1
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