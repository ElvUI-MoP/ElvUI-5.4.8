local _, ns = ...
local oUF = ns.oUF
if not oUF then return end

local playerClass = select(2, UnitClass('player'))
local DispelList, BlackList = {}, {}

DispelList.PRIEST = {Magic = true, Disease = true}
DispelList.SHAMAN = {Magic = false, Curse = true}
DispelList.PALADIN = {Magic = false, Poison = true, Disease = true}
DispelList.DRUID = {Magic = false, Curse = true, Poison = true, Disease = false}
DispelList.MAGE = {Curse = true}
DispelList.MONK = {Magic = false, Poison = true, Disease = true}

local CleanseName = GetSpellInfo(4987)
local SymbiosisName = GetSpellInfo(110309)

local CanDispel = DispelList[playerClass] or {}

BlackList[105171] = true -- Deep Corruption
BlackList[108220] = true -- Deep Corruption
BlackList[116095] = true -- Disable, Slow
BlackList[136180] = true -- Keen Eyesight
BlackList[136182] = true -- Improved Synapses
BlackList[136184] = true -- Thick Bones
BlackList[136186] = true -- Clear Mind
BlackList[137637] = true -- Warbringer, Slow
BlackList[140546] = true -- Fully Mutated

local DispellPriority = {Magic = 4, Curse = 3, Disease = 2, Poison = 1}
local FilterList = {}

local function GetAuraType(unit, filter, filterTable)
	if not unit or not UnitCanAssist('player', unit) then return nil end

	local i = 1
	while true do
		local name, _, texture, _, debufftype, _, _, _, _, _, spellID = UnitAura(unit, i, 'HARMFUL')
		if not texture then break end

		local filterSpell = filterTable[spellID] or filterTable[name]

		if filterTable and filterSpell then
			if filterSpell.enable then
				return debufftype, texture, true, filterSpell.style, filterSpell.color
			end
		elseif debufftype and (not filter or (filter and CanDispel[debufftype])) and not (BlackList[name] or BlackList[spellID]) then
			return debufftype, texture
		end

		i = i + 1
	end

	i = 1
	while true do
		local _, _, texture, _, debufftype, _, _, _, _, _, spellID = UnitAura(unit, i)
		if not texture then break end

		local filterSpell = filterTable[spellID]

		if filterTable and filterSpell then
			if filterSpell.enable then
				return debufftype, texture, true, filterSpell.style, filterSpell.color
			end
		end

		i = i + 1
	end
end

local function FilterTable()
	local debufftype, texture, filterSpell

	return debufftype, texture, true, filterSpell.style, filterSpell.color
end

local function CheckTalentTree(tree)
	local activeGroup = GetActiveSpecGroup()

	if activeGroup and GetSpecialization(false, false, activeGroup) then
		return tree == GetSpecialization(false, false, activeGroup)
	end
end

local function CheckSpec()
	-- Check for certain talents to see if we can dispel magic or not
	if playerClass == 'PRIEST' then
		CanDispel.Disease = not CheckTalentTree(3)
	elseif playerClass == 'PALADIN' then
		CanDispel.Magic = CheckTalentTree(1)
	elseif playerClass == 'SHAMAN' then
		CanDispel.Magic = CheckTalentTree(3)
	elseif playerClass == 'DRUID' then
		CanDispel.Magic = CheckTalentTree(4)
	elseif playerClass == 'MONK' then
		CanDispel.Magic = CheckTalentTree(2)
	end
end

local function CheckSymbiosis()
	CanDispel.Disease = GetSpellInfo(SymbiosisName) == CleanseName
end

local function Update(self, _, unit)
	if unit ~= self.unit then return end

	local debuffType, texture, wasFiltered, style, color = GetAuraType(unit, self.AuraHighlightFilter, self.AuraHighlightFilterTable)

	if wasFiltered then
		if style == 'GLOW' and self.AuraHightlightGlow then
			self.AuraHightlightGlow:Show()
			self.AuraHightlightGlow:SetBackdropBorderColor(color.r, color.g, color.b)
		elseif self.AuraHightlightGlow then
			self.AuraHightlightGlow:Hide()
			self.AuraHighlight:SetVertexColor(color.r, color.g, color.b, color.a)
		end
	elseif debuffType then
		color = DebuffTypeColor[debuffType or 'none']
		if self.AuraHighlightBackdrop and self.AuraHightlightGlow then
			self.AuraHightlightGlow:Show()
			self.AuraHightlightGlow:SetBackdropBorderColor(color.r, color.g, color.b)
		elseif self.AuraHighlightUseTexture then
			self.AuraHighlight:SetTexture(texture)
		else
			self.AuraHighlight:SetVertexColor(color.r, color.g, color.b, color.a)
		end
	else
		if self.AuraHightlightGlow then
			self.AuraHightlightGlow:Hide()
		end

		if self.AuraHighlightUseTexture then
			self.AuraHighlight:SetTexture(nil)
		else
			self.AuraHighlight:SetVertexColor(0, 0, 0, 0)
		end
	end

	if self.AuraHighlight.PostUpdate then
		self.AuraHighlight:PostUpdate(self, debuffType, texture, wasFiltered, style, color)
	end
end

local function Enable(self)
	local element = self.AuraHighlight
	if element then

		self:RegisterEvent('UNIT_AURA', Update)

		if playerClass == 'DRUID' then
			self:RegisterEvent('SPELLS_CHANGED', CheckSymbiosis)
		end

		return true
	end
end

local function Disable(self)
	local element = self.AuraHighlight
	if element then
		self:UnregisterEvent('UNIT_AURA', Update)

		if playerClass == 'DRUID' then
			self:UnregisterEvent('SPELLS_CHANGED', CheckSymbiosis)
		end

		if self.AuraHightlightGlow then
			self.AuraHightlightGlow:Hide()
		end

		if self.AuraHighlight then
			self.AuraHighlight:SetVertexColor(0, 0, 0, 0)
		end
	end
end

local f = CreateFrame('Frame')
f:RegisterEvent('CHARACTER_POINTS_CHANGED')
f:RegisterEvent('PLAYER_TALENT_UPDATE')
f:RegisterEvent('PLAYER_SPECIALIZATION_CHANGED')
f:SetScript('OnEvent', CheckSpec)

oUF:AddElement('AuraHighlight', Update, Enable, Disable)