local _, ns = ...
local oUF = ns.oUF

local unpack = unpack

local UnitClass = UnitClass
local UnitHealth = UnitHealth
local UnitHealthMax = UnitHealthMax
local UnitIsConnected = UnitIsConnected
local UnitIsPlayer = UnitIsPlayer
local UnitIsTapped = UnitIsTapped
local UnitIsTappedByAllThreatList = UnitIsTappedByAllThreatList
local UnitIsTappedByPlayer = UnitIsTappedByPlayer
local UnitPlayerControlled = UnitPlayerControlled
local UnitReaction = UnitReaction

local updateFrequentUpdates

local function UpdateColor(element, unit, cur, max)
	local parent = element.__owner

	if element.frequentUpdates ~= element.__frequentUpdates then
		element.__frequentUpdates = element.frequentUpdates
		updateFrequentUpdates(parent)
	end

	local r, g, b, t
	if(element.colorTapping and not UnitPlayerControlled(unit) and (UnitIsTapped(unit) and not UnitIsTappedByPlayer(unit) and not UnitIsTappedByAllThreatList(unit))) then
		t = parent.colors.tapped
	elseif(element.colorDisconnected and element.disconnected) then
		t = parent.colors.disconnected
	elseif(element.colorClass and UnitIsPlayer(unit)) or
		(element.colorClassNPC and not UnitIsPlayer(unit)) or
		(element.colorClassPet and UnitPlayerControlled(unit) and not UnitIsPlayer(unit)) then
		local _, class = UnitClass(unit)
		t = parent.colors.class[class]
	elseif(element.colorReaction and UnitReaction(unit, 'player')) then
		t = parent.colors.reaction[UnitReaction(unit, 'player')]
	elseif(element.colorSmooth) then
		r, g, b = parent.ColorGradient(cur, max, unpack(element.smoothGradient or parent.colors.smooth))
	elseif(element.colorHealth) then
		t = parent.colors.health
	end

	if(t) then
		r, g, b = t[1], t[2], t[3]
	end

	if(r or g or b) then
		element:SetStatusBarColor(r, g, b)

		local bg = element.bg
		if(bg) then
			local mu = bg.multiplier or 1
			bg:SetVertexColor(r * mu, g * mu, b * mu)
		end
	end
end

local function Update(self, event, unit)
	if(not unit or self.unit ~= unit) then return end
	local element = self.Health

	if(element.PreUpdate) then
		element:PreUpdate(unit)
	end

	local cur, max = UnitHealth(unit), UnitHealthMax(unit)
	local disconnected = not UnitIsConnected(unit)
	element:SetMinMaxValues(0, max)

	if(disconnected) then
		element:SetValue(max)
	else
		element:SetValue(cur)
	end

	element.disconnected = disconnected

	element:UpdateColor(unit, cur, max)

	if(element.PostUpdate) then
		return element:PostUpdate(unit, cur, max)
	end
end

local function Path(self, ...)
	return (self.Health.Override or Update) (self, ...)
end

local function ForceUpdate(element)
	return Path(element.__owner, 'ForceUpdate', element.__owner.unit)
end

function updateFrequentUpdates(self)
	local health = self.Health
	if health.frequentUpdates and not self:IsEventRegistered("UNIT_HEALTH_FREQUENT") then
		if GetCVarBool("predictedHealth") ~= true then
			SetCVar("predictedHealth", "1")
		end

		self:RegisterEvent('UNIT_HEALTH_FREQUENT', Path)
		
		if self:IsEventRegistered("UNIT_HEALTH") then
			self:UnregisterEvent("UNIT_HEALTH", Path)
		end
	elseif not self:IsEventRegistered("UNIT_HEALTH") then
		self:RegisterEvent('UNIT_HEALTH', Path)

		if self:IsEventRegistered("UNIT_HEALTH_FREQUENT") then
			self:UnregisterEvent("UNIT_HEALTH_FREQUENT", Path)
		end	
	end
end

local function Enable(self, unit)
	local element = self.Health
	if(element) then
		element.__owner = self
		element.ForceUpdate = ForceUpdate
		element.__frequentUpdates = element.frequentUpdates
		updateFrequentUpdates(self)

		if(element.frequentUpdates) then
			self:RegisterEvent('UNIT_HEALTH_FREQUENT', Path)
		else
			self:RegisterEvent('UNIT_HEALTH', Path)
		end

		self:RegisterEvent('UNIT_MAXHEALTH', Path)
		self:RegisterEvent('UNIT_CONNECTION', Path)
		self:RegisterEvent('UNIT_FACTION', Path)

		if(element:IsObjectType('StatusBar') and not element:GetStatusBarTexture()) then
			element:SetStatusBarTexture([[Interface\TargetingFrame\UI-StatusBar]])
		end

		if(not element.UpdateColor) then
			element.UpdateColor = UpdateColor
		end

		element:Show()

		return true
	end
end

local function Disable(self)
	local element = self.Health
	if(element) then
		element:Hide()

		self:UnregisterEvent('UNIT_HEALTH_FREQUENT', Path)
		self:UnregisterEvent('UNIT_HEALTH', Path)
		self:UnregisterEvent('UNIT_MAXHEALTH', Path)
		self:UnregisterEvent('UNIT_CONNECTION', Path)
		self:UnregisterEvent('UNIT_FACTION', Path)
	end
end

oUF:AddElement('Health', Path, Enable, Disable)