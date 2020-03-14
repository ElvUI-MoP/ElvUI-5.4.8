local _, ns = ...
local oUF = ns.oUF

local _, PlayerClass = UnitClass('player')

local SPELL_POWER_HOLY_POWER = SPELL_POWER_HOLY_POWER or 5
local SPELL_POWER_CHI = SPELL_POWER_CHI or 5
local SPELL_POWER_SHADOW_ORBS = SPELL_POWER_SHADOW_ORBS or 3
local SPEC_PRIEST_SHADOW = SPEC_PRIEST_SHADOW

local ClassPowerID, ClassPowerType
local ClassPowerEnable, ClassPowerDisable
local RequireSpec, RequirePower, RequireSpell, RequireFormID

local function UpdateColor(element, powerType)
	local color = element.__owner.colors.power[powerType]
	local r, g, b = color[1], color[2], color[3]
	for i = 1, #element do
		local bar = element[i]
		bar:SetStatusBarColor(r, g, b)

		local bg = bar.bg
		if(bg) then
			local mu = bg.multiplier or 1
			bg:SetVertexColor(r * mu, g * mu, b * mu)
		end
	end
end

local function Update(self, event, unit, powerType)
	if(not (self.unit == unit and (unit == 'player' and powerType == ClassPowerType))) then return end

	local element = self.ClassPower

	if(element.PreUpdate) then
		element:PreUpdate()
	end

	local cur, max, oldMax
	if(event ~= 'ClassPowerDisable') then
		cur = UnitPower('player', ClassPowerID, true)
		max = UnitPowerMax('player', ClassPowerID)

		local numActive = cur + 0.9
		for i = 1, max do
			if(i > numActive) then
				element[i]:Hide()
				element[i]:SetValue(0)
			else
				element[i]:Show()
				element[i]:SetValue(cur - i + 1)
			end
		end

		oldMax = element.__max
		if(max ~= oldMax) then
			if(max < oldMax) then
				for i = max + 1, oldMax do
					element[i]:Hide()
					element[i]:SetValue(0)
				end
			end

			element.__max = max
		end
	end

	if(element.PostUpdate) then
		return element:PostUpdate(cur, max, oldMax ~= max, powerType)
	end
end

local function Path(self, ...)
	return (self.ClassPower.Override or Update) (self, ...)
end

local function Visibility(self, event, unit)
	local element = self.ClassPower
	local shouldEnable

	if(ClassPowerID) then
		if(not RequireSpec or RequireSpec == GetSpecialization()) then
			if(not RequireSpell or IsPlayerSpell(RequireSpell)) then
				self:UnregisterEvent('SPELLS_CHANGED', Visibility)
				shouldEnable = true
			else
				self:RegisterEvent('SPELLS_CHANGED', Visibility, true)
			end
		end
	end

	local isEnabled = element.isEnabled
	local powerType = ClassPowerType

	if(shouldEnable) then
		if(not UnitHasVehicleUI("player")) then
			element:Show()
		else
			element:Hide()
		end

		(element.UpdateColor or UpdateColor) (element, powerType)
	end

	if(shouldEnable and not isEnabled) then
		ClassPowerEnable(self)
	elseif(not shouldEnable and (isEnabled or isEnabled == nil)) then
		ClassPowerDisable(self)
	elseif(shouldEnable and isEnabled) then
		Path(self, event, unit, powerType)
	end
end

local function VisibilityPath(self, ...)
	return (self.ClassPower.OverrideVisibility or Visibility) (self, ...)
end

local function ForceUpdate(element)
	return VisibilityPath(element.__owner, 'ForceUpdate', element.__owner.unit)
end

do
	function ClassPowerEnable(self)
		self:RegisterEvent('UNIT_POWER_FREQUENT', Path)
		self:RegisterEvent('UNIT_MAXPOWER', Path)

		self.ClassPower.isEnabled = true

		Path(self, 'ClassPowerEnable', 'player', ClassPowerType)
	end

	function ClassPowerDisable(self)
		self:UnregisterEvent('UNIT_POWER_FREQUENT', Path)
		self:UnregisterEvent('UNIT_MAXPOWER', Path)

		local element = self.ClassPower
		for i = 1, #element do
			element[i]:Hide()
		end

		self.ClassPower.isEnabled = false
		Path(self, 'ClassPowerDisable', 'player', ClassPowerType)
	end

	if(PlayerClass == 'MONK') then
		ClassPowerID = SPELL_POWER_CHI
		ClassPowerType = 'CHI'
	elseif(PlayerClass == 'PALADIN') then
		ClassPowerID = SPELL_POWER_HOLY_POWER
		ClassPowerType = 'HOLY_POWER'
	elseif(PlayerClass == 'PRIEST') then
		ClassPowerID = SPELL_POWER_SHADOW_ORBS
		ClassPowerType = 'SHADOW_ORBS'
		RequireSpec = SPEC_PRIEST_SHADOW
		RequireSpell = 95740 -- Shadow Orbs
	end
end

local function Enable(self, unit)
	if(unit ~= 'player') then return end

	local element = self.ClassPower
	if(element) then
		element.__owner = self
		element.__max = #element
		element.ForceUpdate = ForceUpdate

		if(RequireSpec or RequireSpell) then
			self:RegisterEvent('PLAYER_TALENT_UPDATE', VisibilityPath, true)
		end

		element.ClassPowerEnable = ClassPowerEnable
		element.ClassPowerDisable = ClassPowerDisable

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
	if(self.ClassPower) then
		ClassPowerDisable(self)

		self:UnregisterEvent('PLAYER_TALENT_UPDATE', VisibilityPath)
		self:UnregisterEvent('SPELLS_CHANGED', Visibility)
	end
end

oUF:AddElement('ClassPower', VisibilityPath, Enable, Disable)