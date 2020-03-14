if(select(2, UnitClass('player')) ~= 'WARLOCK') then return end

local _, ns = ...
local oUF = ns.oUF

local MAX_POWER_PER_EMBER = MAX_POWER_PER_EMBER
local SPEC_WARLOCK_DESTRUCTION = SPEC_WARLOCK_DESTRUCTION
local SPELL_POWER_BURNING_EMBERS = SPELL_POWER_BURNING_EMBERS
local WARLOCK_BURNING_EMBERS = WARLOCK_BURNING_EMBERS

local function Update(self, event, unit, powerType)
	if(self.unit ~= unit or (event == 'UNIT_POWER' and powerType ~= 'BURNING_EMBERS')) then return end

	local element = self.BurningEmbers

	if element.PreUpdate then
		element:PreUpdate()
	end

	local cur, max, numBars
	cur = UnitPower("player", SPELL_POWER_BURNING_EMBERS, true)
	max = UnitPowerMax("player", SPELL_POWER_BURNING_EMBERS, true)
	numBars = floor(max / MAX_POWER_PER_EMBER)

	for i = 1, numBars do
		element[i]:SetMinMaxValues((MAX_POWER_PER_EMBER * i) - MAX_POWER_PER_EMBER, MAX_POWER_PER_EMBER * i)
		element[i]:SetValue(cur)
	end

	if(element.PostUpdate) then
		return element:PostUpdate(unit, cur, max, event)
	end
end

local function Path(self, ...)
	return (self.BurningEmbers.Override or Update) (self, ...)
end

local function ElementEnable(self)
	self:RegisterEvent('UNIT_POWER_FREQUENT', Path)

	self.BurningEmbers:Show()

	if self.BurningEmbers.PostUpdateVisibility then
		self.BurningEmbers:PostUpdateVisibility(true, not self.BurningEmbers.isEnabled)
	end

	self.BurningEmbers.isEnabled = true

	Path(self, 'ElementEnable', 'player', SPELL_POWER_BURNING_EMBERS)
end

local function ElementDisable(self)
	self:UnregisterEvent('UNIT_POWER_FREQUENT', Path)

	self.BurningEmbers:Hide()

	if self.BurningEmbers.PostUpdateVisibility then
		self.BurningEmbers:PostUpdateVisibility(false, self.BurningEmbers.isEnabled)
	end

	self.BurningEmbers.isEnabled = nil

	Path(self, 'ElementDisable', 'player', SPELL_POWER_BURNING_EMBERS)
end

local function Visibility(self)
	local shouldEnable

	if(not UnitHasVehicleUI("player")) then
		if GetSpecialization() == SPEC_WARLOCK_DESTRUCTION and IsPlayerSpell(WARLOCK_BURNING_EMBERS) then
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
	return (self.BurningEmbers.OverrideVisibility or Visibility) (self, ...)
end

local function ForceUpdate(element)
	return VisibilityPath(element.__owner, 'ForceUpdate', element.__owner.unit, 'BURNING_EMBERS')
end

local function Enable(self, unit)
	local element = self.BurningEmbers
	if(element and unit == 'player') then
		element.__owner = self
		element.ForceUpdate = ForceUpdate

		self:RegisterEvent('PLAYER_TALENT_UPDATE', VisibilityPath, true)

		for i = 1, #element do
			local bar = element[i]
			if(bar:IsObjectType('StatusBar')) then
				if(not bar:GetStatusBarTexture()) then
					bar:SetStatusBarTexture([[Interface\TargetingFrame\UI-StatusBar]])
				end
			end
		end

		return true
	end
end

local function Disable(self)
	local element = self.BurningEmbers
	if(element) then
		ElementDisable(self)

		self:UnregisterEvent('PLAYER_TALENT_UPDATE', VisibilityPath)
	end
end

oUF:AddElement('BurningEmbers', VisibilityPath, Enable, Disable)