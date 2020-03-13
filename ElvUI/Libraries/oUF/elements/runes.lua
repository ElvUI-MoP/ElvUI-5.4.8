if(select(2, UnitClass('player')) ~= 'DEATHKNIGHT') then return end

local _, ns = ...
local oUF = ns.oUF

local floor = math.floor

local GetRuneCooldown = GetRuneCooldown
local GetRuneType = GetRuneType
local GetTime = GetTime
local IsUsableSpell = IsUsableSpell
local UnitHasVehicleUI = UnitHasVehicleUI

local runemap = {1, 2, 5, 6, 3, 4}
local BLOOD_OF_THE_NORTH = GetSpellInfo(54637)

local VisibilityPath

local function onUpdate(self, elapsed)
	local duration = self.duration + elapsed
	self.duration = duration
	self:SetValue(duration)
end

local function UpdateType(self, event, runeID, alt)
	local element = self.Runes
	local rune = element[runemap[runeID]]
	local runeType = GetRuneType(runeID) or alt

	if IsUsableSpell(BLOOD_OF_THE_NORTH) and runeType == 1 then
		runeType = 4
	end
	if not runeType then return end

	local color = self.colors.runes[runeType]
	local r, g, b = color[1], color[2], color[3]

	rune:SetStatusBarColor(r, g, b)

	if(rune.bg) then
		local mu = rune.bg.multiplier or 1
		rune.bg:SetVertexColor(r * mu, g * mu, b * mu)
	end

	if(element.PostUpdateType) then
		return element:PostUpdateType(rune, runeID, alt)
	end
end

local function Update(self, event, runeID)
	local element = self.Runes
	local rune = element[runemap[runeID]]
	if(not rune) then return end

	local start, duration, runeReady
	if(UnitHasVehicleUI('player')) then
		rune:Hide()
	else
		start, duration, runeReady = GetRuneCooldown(runeID)
		if(not start) then return end

		if(runeReady) then
			rune:SetMinMaxValues(0, 1)
			rune:SetValue(1)
			rune:SetScript('OnUpdate', nil)
		else
			rune.duration = GetTime() - start
			rune.max = duration
			rune:SetMinMaxValues(0, duration)
			rune:SetValue(0)
			rune:SetScript('OnUpdate', onUpdate)
		end

		rune:Show()
	end

	if(element.PostUpdate) then
		return element:PostUpdate(rune, runeID, start, duration, runeReady)
	end
end

local function Path(self, event, ...)
	local element = self.Runes

	local UpdateMethod = element.Override or Update
	if(event == 'RUNE_POWER_UPDATE') then
		return UpdateMethod(self, event, ...)
	else
		local UpdateTypeMethod = element.UpdateType or UpdateType
		for index = 1, #element do
			UpdateTypeMethod(self, element, index)
			UpdateMethod(self, event, index)
		end
	end
end

local function RunesEnable(self)
	self:RegisterEvent('UNIT_ENTERED_VEHICLE', VisibilityPath)
	self:UnregisterEvent('UNIT_EXITED_VEHICLE', VisibilityPath)

	self.Runes:Show()

	if self.Runes.PostUpdateVisibility then
		self.Runes:PostUpdateVisibility(true, not self.Runes.isEnabled)
	end

	self.Runes.isEnabled = true

	Path(self, 'RunesEnable')
end

local function RunesDisable(self)
	self:UnregisterEvent('UNIT_ENTERED_VEHICLE', VisibilityPath)
	self:RegisterEvent('UNIT_EXITED_VEHICLE', VisibilityPath)

	self.Runes:Hide()

	if self.Runes.PostUpdateVisibility then
		self.Runes:PostUpdateVisibility(false, self.Runes.isEnabled)
	end

	self.Runes.isEnabled = false

	Path(self, 'RunesDisable')
end

local function Visibility(self, event, ...)
	local element = self.Runes
	local shouldEnable

	if not (UnitHasVehicleUI('player')) then
		shouldEnable = true
	end

	local isEnabled = element.isEnabled
	if(shouldEnable and not isEnabled) then
		RunesEnable(self)
	elseif(not shouldEnable and (isEnabled or isEnabled == nil)) then
		RunesDisable(self)
	elseif(shouldEnable and isEnabled) then
		Path(self, event, ...)
	end
end

VisibilityPath = function(self, ...)
	return (self.Runes.OverrideVisibility or Visibility) (self, ...)
end

local ForceUpdate = function(element)
	return VisibilityPath(element.__owner, 'ForceUpdate', element.__owner.unit)
end

local function Enable(self, unit)
	local element = self.Runes
	if(element and unit == 'player') then
		element.__owner = self
		element.ForceUpdate = ForceUpdate

		for i = 1, #element do
			local rune = element[runemap[i]]
			if(rune:IsObjectType('StatusBar') and not rune:GetStatusBarTexture()) then
				rune:SetStatusBarTexture([[Interface\TargetingFrame\UI-StatusBar]])
			end

			UpdateType(self, nil, i, floor((i + 1) / 2))
		end

		self:RegisterEvent('RUNE_POWER_UPDATE', Path, true)
		self:RegisterEvent('RUNE_TYPE_UPDATE', UpdateType, true)
		self:RegisterEvent('PLAYER_ENTERING_WORLD', Path)

		RuneFrame.Show = RuneFrame.Hide
		RuneFrame:Hide()

		return true
	end
end

local function Disable(self)
	RuneFrame.Show = nil
	RuneFrame:Show()

	local element = self.Runes
	if(element) then
		for i = 1, #element do
			element[i]:Hide()
		end

		self:SetScript('OnUpdate', nil)

		self:UnregisterEvent('RUNE_POWER_UPDATE', Path)
		self:UnregisterEvent('RUNE_TYPE_UPDATE', UpdateType)
		self:UnregisterEvent('PLAYER_ENTERING_WORLD', Path)

		RunesDisable(self)
	end
end

oUF:AddElement('Runes', VisibilityPath, Enable, Disable)