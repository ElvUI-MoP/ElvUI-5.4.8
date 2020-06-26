local _, ns = ...
local oUF = ns.oUF
if not oUF then return end

local playerClass = select(2, UnitClass('player'))
if not (playerClass == 'MAGE' or playerClass == 'ROGUE') then return end

local ArcaneCharge = GetSpellInfo(36032)
local Anticipation = GetSpellInfo(115189)

local function UpdateBar(self, elapsed)
	if not self.expirationTime then return end

	self.elapsed = (self.elapsed or 0) + elapsed
	if(self.elapsed >= 0.5) then
		local timeLeft = self.expirationTime - GetTime()
		if(timeLeft > 0) then
			self:SetValue(timeLeft)
		else
			self:SetScript('OnUpdate', nil)
		end
	end
end

local function Update(self, event)
	local element = self.SpecPower
	local unit = self.unit or 'player'

	if(element.PreUpdate) then
		element:PreUpdate(event)
	end

	local _, name, count, start, timeLeft
	local charges, maxCharges = 0
	if(playerClass == 'MAGE') then
		name, _, _, count, _, start, timeLeft = UnitDebuff(unit, ArcaneCharge)
		maxCharges = 4
	elseif(playerClass == 'ROGUE') then
		name, _, _, count, _, start, timeLeft = UnitBuff(unit, Anticipation)
		maxCharges = 5
	end

	if(name) then
		charges = count or 0
		duration = start
		expirationTime = timeLeft
	end

	if(charges < 1) then
		element:Hide()
	else
		element:Show()
	end

	if(element:IsShown()) then
		for i = 1, maxCharges do
			if(start and timeLeft) then
				element[i]:SetMinMaxValues(0, start)
				element[i].duration = start
				element[i].expirationTime = timeLeft
			end

			if(i <= charges) then
				element[i]:SetValue(start)
				element[i]:SetScript('OnUpdate', UpdateBar)
			else
				element[i]:SetValue(0)
				element[i]:SetScript('OnUpdate', nil)
			end
		end
	end

	if(element.PostUpdate) then
		return element:PostUpdate(event, charges, maxCharges)
	end
end

local function Path(self, ...)
	return (self.SpecPower.Override or Update) (self, ...)
end

local function ForceUpdate(element)
	return Path(element.__owner, 'ForceUpdate', element.__owner.unit)
end

local function Enable(self, unit)
	local element = self.SpecPower

	if(element and UnitIsUnit(unit, 'player')) then
		element.__owner = self
		element.ForceUpdate = ForceUpdate

		self:RegisterEvent('UNIT_AURA', Path)
		self:RegisterEvent('SPELLS_CHANGED', Path)
		self:RegisterEvent('ACTIVE_TALENT_GROUP_CHANGED', Path)
		self:RegisterEvent('PLAYER_SPECIALIZATION_CHANGED', Path)
		self:RegisterEvent('PLAYER_ENTERING_WORLD', Path)

		local maxCharges = playerClass == 'MAGE' and 4 or 5
		for i = 1, maxCharges do
			if(element[i]:IsObjectType('StatusBar') and not element[i]:GetStatusBarTexture()) then
				element[i]:SetStatusBarTexture([[Interface\TargetingFrame\UI-StatusBar]])
			end

			element[i]:SetFrameLevel(element:GetFrameLevel() + 1)
			element[i]:GetStatusBarTexture():SetHorizTile(false)

			if(element[i].bg) then
				element[i]:SetMinMaxValues(0, 1)
				element[i]:SetValue(0)
			end
		end

		return true
	end
end

local function Disable(self, unit)
	local element = self.SpecPower

	if(element) then
		self:UnregisterEvent('UNIT_AURA', Path)
		self:UnregisterEvent('SPELLS_CHANGED', Path)
		self:UnregisterEvent('ACTIVE_TALENT_GROUP_CHANGED', Path)
		self:UnregisterEvent('PLAYER_SPECIALIZATION_CHANGED', Path)
		self:UnregisterEvent('PLAYER_ENTERING_WORLD', Path)

		element:Hide()
	end
end

oUF:AddElement('SpecPower', Path, Enable, Disable)