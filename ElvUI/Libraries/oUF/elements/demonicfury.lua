if(select(2, UnitClass('player')) ~= 'WARLOCK') then return end

local _, ns = ...
local oUF = ns.oUF

local SPEC_WARLOCK_DEMONOLOGY = SPEC_WARLOCK_DEMONOLOGY
local SPELL_POWER_DEMONIC_FURY = SPELL_POWER_DEMONIC_FURY

local function Update(self, event, unit, powerType)
	if(self.unit ~= unit or (event == 'UNIT_POWER' and powerType ~= 'DEMONIC_FURY')) then return end

	local element = self.DemonicFury

	if element.PreUpdate then
		element:PreUpdate()
	end

	local cur = UnitPower("player", SPELL_POWER_DEMONIC_FURY)
	local max = UnitPowerMax("player", SPELL_POWER_DEMONIC_FURY)

	element:SetMinMaxValues(0, max)
	element:SetValue(cur)

	if(element.PostUpdate) then
		return element:PostUpdate(unit, cur, max, event)
	end
end

local function Path(self, ...)
	return (self.DemonicFury.Override or Update) (self, ...)
end

local function ElementEnable(self)
	self:RegisterEvent('UNIT_POWER_FREQUENT', Path)

	self.DemonicFury:Show()

	if self.DemonicFury.PostUpdateVisibility then
		self.DemonicFury:PostUpdateVisibility(true, not self.DemonicFury.isEnabled)
	end

	self.DemonicFury.isEnabled = true

	Path(self, 'ElementEnable', 'player', SPELL_POWER_DEMONIC_FURY)
end

local function ElementDisable(self)
	self:UnregisterEvent('UNIT_POWER_FREQUENT', Path)

	self.DemonicFury:Hide()

	if self.DemonicFury.PostUpdateVisibility then
		self.DemonicFury:PostUpdateVisibility(false, self.DemonicFury.isEnabled)
	end

	self.DemonicFury.isEnabled = nil

	Path(self, 'ElementDisable', 'player', SPELL_POWER_DEMONIC_FURY)
end

local function Visibility(self)
	local shouldEnable

	if(not UnitHasVehicleUI("player")) then
		if GetSpecialization() == SPEC_WARLOCK_DEMONOLOGY then
			shouldEnable = true
		end
	end

	if(shouldEnable) then
		ElementEnable(self)
	else
		ElementDisable(self)
	end
end

local function VisibilityPath(self, ...)
	return (self.DemonicFury.OverrideVisibility or Visibility) (self, ...)
end

local function ForceUpdate(element)
	return VisibilityPath(element.__owner, 'ForceUpdate', element.__owner.unit, 'DEMONIC_FURY')
end

local function Enable(self, unit)
	local element = self.DemonicFury
	if(element and unit == 'player') then
		element.__owner = self
		element.ForceUpdate = ForceUpdate

		self:RegisterEvent("PLAYER_TALENT_UPDATE", VisibilityPath, true)

		if(element:IsObjectType('StatusBar') and not element:GetStatusBarTexture()) then
			element:SetStatusBarTexture([[Interface\TargetingFrame\UI-StatusBar]])
		end

		return true
	end
end

local function Disable(self)
	local element = self.DemonicFury
	if(element) then
		ElementDisable(self)

		self:UnregisterEvent("PLAYER_TALENT_UPDATE", VisibilityPath)
	end
end

oUF:AddElement('DemonicFury', VisibilityPath, Enable, Disable)