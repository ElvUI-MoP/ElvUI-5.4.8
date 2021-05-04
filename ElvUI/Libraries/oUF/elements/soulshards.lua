if(select(2, UnitClass('player')) ~= 'WARLOCK') then return end

local _, ns = ...
local oUF = ns.oUF

local SPEC_WARLOCK_AFFLICTION = SPEC_WARLOCK_AFFLICTION
local SPELL_POWER_SOUL_SHARDS = SPELL_POWER_SOUL_SHARDS
local WARLOCK_SOULBURN = WARLOCK_SOULBURN

local function Update(self, event, unit, powerType)
	if(self.unit ~= unit or (event == 'UNIT_POWER' and powerType ~= 'SOUL_SHARDS')) then return end

	local element = self.SoulShards

	if element.PreUpdate then
		element:PreUpdate()
	end

	local cur = UnitPower("player", SPELL_POWER_SOUL_SHARDS)
	local max = UnitPowerMax("player", SPELL_POWER_SOUL_SHARDS)

	for i = 1, max do
		if i <= cur then
			element[i]:SetValue(1)
		else
			element[i]:SetValue(0)
		end
	end

	if(element.PostUpdate) then
		return element:PostUpdate(unit, cur, max, event)
	end
end

local function Path(self, ...)
	return (self.SoulShards.Override or Update) (self, ...)
end

local function ElementEnable(self)
	self:RegisterEvent('UNIT_POWER_FREQUENT', Path)

	self.SoulShards:Show()

	if self.SoulShards.PostUpdateVisibility then
		self.SoulShards:PostUpdateVisibility(true, not self.SoulShards.isEnabled)
	end

	self.SoulShards.isEnabled = true

	Path(self, 'ElementEnable', 'player', SPELL_POWER_SOUL_SHARDS)
end

local function ElementDisable(self)
	self:UnregisterEvent('UNIT_POWER_FREQUENT', Path)

	self.SoulShards:Hide()

	if self.SoulShards.PostUpdateVisibility then
		self.SoulShards:PostUpdateVisibility(false, self.SoulShards.isEnabled)
	end

	self.SoulShards.isEnabled = nil

	Path(self, 'ElementDisable', 'player', SPELL_POWER_SOUL_SHARDS)
end

local function Visibility(self)
	local shouldEnable

	if(not UnitHasVehicleUI("player")) then
		if GetSpecialization() == SPEC_WARLOCK_AFFLICTION and IsPlayerSpell(WARLOCK_SOULBURN) then
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
	return (self.SoulShards.OverrideVisibility or Visibility) (self, ...)
end

local function ForceUpdate(element)
	return VisibilityPath(element.__owner, 'ForceUpdate', element.__owner.unit, 'SOUL_SHARDS')
end

local function Enable(self, unit)
	local element = self.SoulShards
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

				bar:SetMinMaxValues(0, 1)
			end
		end

		return true
	end
end

local function Disable(self)
	local element = self.SoulShards
	if(element) then
		ElementDisable(self)

		self:UnregisterEvent('PLAYER_TALENT_UPDATE', VisibilityPath)
	end
end

oUF:AddElement('SoulShards', VisibilityPath, Enable, Disable)