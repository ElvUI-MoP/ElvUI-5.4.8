local _, ns = ...
local oUF = ns.oUF

local FFA_ICON = [[Interface\TargetingFrame\UI-PVP-FFA]]
local FACTION_ICON = [[Interface\TargetingFrame\UI-PVP-]]

local function Update(self, event, unit)
	if(unit ~= self.unit) then return end

	local element = self.PvPIndicator

	if(element.PreUpdate) then
		element:PreUpdate(unit)
	end

	local status
	local factionGroup = UnitFactionGroup(unit) or 'Neutral'

	if(UnitIsPVPFreeForAll(unit)) then
		element:SetTexture(FFA_ICON)
		element:SetTexCoord(0, 0.65625, 0, 0.65625)

		status = 'ffa'
	elseif(factionGroup ~= 'Neutral' and UnitIsPVP(unit)) then
		element:SetTexture(FACTION_ICON .. factionGroup)
		element:SetTexCoord(0, 0.65625, 0, 0.65625)

		status = factionGroup
	end

	if(status) then
		element:Show()
	else
		element:Hide()
	end

	if(element.PostUpdate) then
		return element:PostUpdate(unit, status)
	end
end

local function Path(self, ...)
	return (self.PvPIndicator.Override or Update) (self, ...)
end

local function ForceUpdate(element)
	return Path(element.__owner, 'ForceUpdate', element.__owner.unit)
end

local function Enable(self)
	local element = self.PvPIndicator
	if(element) then
		element.__owner = self
		element.ForceUpdate = ForceUpdate

		self:RegisterEvent("UNIT_FACTION", Path)

		return true
	end
end

local function Disable(self)
	local element = self.PvPIndicator
	if(element) then
		element:Hide()

		self:UnregisterEvent("UNIT_FACTION", Path)
	end
end

oUF:AddElement("PvPIndicator", Path, Enable, Disable)