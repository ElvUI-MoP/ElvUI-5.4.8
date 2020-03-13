local E, L, V, P, G = unpack(select(2, ...))
local S = E:GetModule("Skins")

local _G = _G
local select, unpack, pairs = select, unpack, pairs

local CreateFrame = CreateFrame
local GetItemInfo = GetItemInfo
local GetItemQualityColor = GetItemQualityColor
local hooksecurefunc = hooksecurefunc

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.encounterjournal ~= true then return end

	local EJ = EncounterJournal

	EJ:StripTextures(true)
	EJ:SetTemplate("Transparent")

	EJ.inset:StripTextures(true)

	--NavBar
	EJ.navBar:StripTextures(true)
	EJ.navBar:CreateBackdrop("Default")
	EJ.navBar.backdrop:Point("TOPLEFT", -2, 0)
	EJ.navBar.backdrop:Point("BOTTOMRIGHT")

	EJ.navBar.overlay:StripTextures(true)

	S:HandleButton(EJ.navBar.home, true)

	local function navButtonFrameLevel(self)
		for i = 1, #self.navList do
			local navButton = self.navList[i]
			local lastNav = self.navList[i - 1]

			if navButton and lastNav then
				navButton:SetFrameLevel(lastNav:GetFrameLevel() + 2)
				navButton:ClearAllPoints()
				navButton:Point("LEFT", lastNav, "RIGHT", 1, 0)
			end
		end
	end

	hooksecurefunc("NavBar_AddButton", function(self)
		if self:GetParent():GetName() == "EncounterJournal" then
			local navButton = self.navList[#self.navList]

			if navButton and not navButton.isSkinned then
				S:HandleButton(navButton, true)

				navButton:HookScript("OnClick", function()
					navButtonFrameLevel(self)
				end)

				navButton.isSkinned = true
			end

			navButtonFrameLevel(self)
		end
	end)

	EncounterJournalBg:SetAlpha(0)
	EncounterJournalTitleBg:SetAlpha(0)

	EncounterJournalEncounterFrame:StripTextures(true)
	EncounterJournalEncounterFrameInfo:StripTextures(true)
	EncounterJournalInset:StripTextures(true)

	S:HandleScrollBar(EncounterJournalEncounterFrameInfoBossesScrollFrameScrollBar)
	EncounterJournalEncounterFrameInfoBossesScrollFrame:CreateBackdrop("Transparent", true)

	EncounterJournalEncounterFrameInfoModelFrame:StripTextures()
	EncounterJournalEncounterFrameInfoModelFrame:CreateBackdrop("Transparent", true)

	S:HandleEditBox(EJ.searchBox)
	S:HandleCloseButton(EncounterJournalCloseButton)

	-- Instance Selection Frame
	local InstanceSelect = EJ.instanceSelect
	InstanceSelect.bg:Kill()
	S:HandleNextPrevButton(EncounterJournalInstanceSelectScrollDownButton)
	S:HandleScrollBar(InstanceSelect.scroll.ScrollBar, 4)

	-- Dungeon/Raid Tabs
	local function onEnable(self)
		self:Height(self.storedHeight)
	end

	local instanceTabs = {
		InstanceSelect.dungeonsTab,
		InstanceSelect.raidsTab
	}

	for _, instanceTab in pairs(instanceTabs) do
		instanceTab:StripTextures()
		instanceTab:CreateBackdrop("Default", true)
		instanceTab.backdrop:Point("TOPLEFT", -10, -1)
		instanceTab.backdrop:Point("BOTTOMRIGHT", 10, -1)
		instanceTab:Height(instanceTab.storedHeight)

		instanceTab:HookScript("OnEnable", onEnable)
		instanceTab:HookScript("OnEnter", S.SetModifiedBackdrop)
		instanceTab:HookScript("OnLeave", S.SetOriginalBackdrop)
	end

	InstanceSelect.raidsTab:Point("BOTTOMRIGHT", EncounterJournalInstanceSelect, "TOPRIGHT", -41, -45)

	-- Encounter Info Frame
	local EncounterInfo = EJ.encounter.info
	EncounterJournalEncounterFrameInfoBG:Kill()

	EncounterInfo.difficulty:StripTextures()
	S:HandleButton(EncounterInfo.difficulty)
	EncounterInfo.difficulty:SetFrameLevel(EncounterInfo.difficulty:GetFrameLevel() + 1)
	EncounterInfo.difficulty:Width(100)
	EncounterInfo.difficulty:Point("TOPRIGHT", -5, -7)

	EncounterJournalEncounterFrameInfoResetButton:StripTextures()
	S:HandleButton(EncounterJournalEncounterFrameInfoResetButton)

	EncounterJournalEncounterFrameInfoResetButtonTexture:SetTexture("Interface\\EncounterJournal\\UI-EncounterJournalTextures")
	EncounterJournalEncounterFrameInfoResetButtonTexture:SetTexCoord(0.90625000, 0.94726563, 0.00097656, 0.02050781)

	local scrollFrames = {
		EncounterInfo.overviewScroll,
		EncounterInfo.lootScroll,
		EncounterInfo.detailsScroll,
	}

	for _, scrollFrame in pairs(scrollFrames) do
		scrollFrame:CreateBackdrop("Transparent", true)
	end

	EncounterInfo.lootScroll.filter:StripTextures()
	EncounterInfo.lootScroll.filter:Point("TOPLEFT", EncounterJournalEncounterFrameInfo, "TOPRIGHT", -351, -7)
	S:HandleButton(EncounterInfo.lootScroll.filter)

	EncounterInfo.detailsScroll.child.description:SetTextColor(1, 1, 1)

	-- Boss Tab
	EncounterJournalEncounterFrameInfoBossTab:StripTextures()
	EncounterJournalEncounterFrameInfoBossTab:SetTemplate("Transparent")
	EncounterJournalEncounterFrameInfoBossTab:Size(45, 40)
	EncounterJournalEncounterFrameInfoBossTab:Point("TOPLEFT", EncounterJournalEncounterFrameInfo, "TOPRIGHT", E.PixelMode and 7 or 9, 40)

	EncounterJournalEncounterFrameInfoBossTab:GetNormalTexture():SetTexture("Interface\\EncounterJournal\\UI-EncounterJournalTextures")
	EncounterJournalEncounterFrameInfoBossTab:GetNormalTexture():SetTexCoord(0.902, 0.996, 0.269, 0.311)
	EncounterJournalEncounterFrameInfoBossTab:GetPushedTexture():SetTexture("Interface\\EncounterJournal\\UI-EncounterJournalTextures")
	EncounterJournalEncounterFrameInfoBossTab:GetPushedTexture():SetTexCoord(0.902, 0.996, 0.269, 0.311)
	EncounterJournalEncounterFrameInfoBossTab:GetDisabledTexture():SetTexture("Interface\\EncounterJournal\\UI-EncounterJournalTextures")
	EncounterJournalEncounterFrameInfoBossTab:GetDisabledTexture():SetTexCoord(0.902, 0.996, 0.269, 0.311)
	EncounterJournalEncounterFrameInfoBossTab:GetHighlightTexture():SetTexture(1, 1, 1, 0.3)
	EncounterJournalEncounterFrameInfoBossTab:GetHighlightTexture():SetInside()

	-- Loot Tab
	EncounterJournalEncounterFrameInfoLootTab:StripTextures()
	EncounterJournalEncounterFrameInfoLootTab:SetTemplate("Transparent")
	EncounterJournalEncounterFrameInfoLootTab:Size(45, 40)
	EncounterJournalEncounterFrameInfoLootTab:Point("TOP", EncounterJournalEncounterFrameInfoBossTab, "BOTTOM", 0, -10)

	EncounterJournalEncounterFrameInfoLootTab:GetNormalTexture():SetTexture("Interface\\EncounterJournal\\UI-EncounterJournalTextures")
	EncounterJournalEncounterFrameInfoLootTab:GetNormalTexture():SetTexCoord(0.632, 0.726, 0.618, 0.660)
	EncounterJournalEncounterFrameInfoLootTab:GetPushedTexture():SetTexture("Interface\\EncounterJournal\\UI-EncounterJournalTextures")
	EncounterJournalEncounterFrameInfoLootTab:GetPushedTexture():SetTexCoord(0.632, 0.726, 0.618, 0.660)
	EncounterJournalEncounterFrameInfoLootTab:GetDisabledTexture():SetTexture("Interface\\EncounterJournal\\UI-EncounterJournalTextures")
	EncounterJournalEncounterFrameInfoLootTab:GetDisabledTexture():SetTexCoord(0.632, 0.726, 0.618, 0.660)
	EncounterJournalEncounterFrameInfoLootTab:GetHighlightTexture():SetTexture(1, 1, 1, 0.3)
	EncounterJournalEncounterFrameInfoLootTab:GetHighlightTexture():SetInside()

	-- Model Tab
	EncounterJournalEncounterFrameInfoModelTab:StripTextures()
	EncounterJournalEncounterFrameInfoModelTab:SetTemplate("Transparent")
	EncounterJournalEncounterFrameInfoModelTab:Size(45, 40)
	EncounterJournalEncounterFrameInfoModelTab:Point("TOP", EncounterJournalEncounterFrameInfoLootTab, "BOTTOM", 0, -10)

	EncounterJournalEncounterFrameInfoModelTab:GetNormalTexture():SetTexture("Interface\\EncounterJournal\\UI-EncounterJournalTextures")
	EncounterJournalEncounterFrameInfoModelTab:GetNormalTexture():SetTexCoord(0.804, 0.900, 0.662, 0.705)
	EncounterJournalEncounterFrameInfoModelTab:GetPushedTexture():SetTexture("Interface\\EncounterJournal\\UI-EncounterJournalTextures")
	EncounterJournalEncounterFrameInfoModelTab:GetPushedTexture():SetTexCoord(0.804, 0.900, 0.662, 0.705)
	EncounterJournalEncounterFrameInfoModelTab:GetDisabledTexture():SetTexture("Interface\\EncounterJournal\\UI-EncounterJournalTextures")
	EncounterJournalEncounterFrameInfoModelTab:GetDisabledTexture():SetTexCoord(0.804, 0.900, 0.662, 0.705)
	EncounterJournalEncounterFrameInfoModelTab:GetHighlightTexture():SetTexture(1, 1, 1, 0.3)
	EncounterJournalEncounterFrameInfoModelTab:GetHighlightTexture():SetInside()

	-- Encounter Instance Frame
	local EncounterInstance = EJ.encounter.instance

	EncounterInstance:CreateBackdrop("Transparent", true)
	EncounterInstance.loreScroll.child.lore:SetTextColor(1, 1, 1)

	EncounterJournalEncounterFrameInfoLootScrollFrameClassFilterClearFrame:StripTextures()

	EncounterJournalEncounterFrameInstanceFrameMapButton:StripTextures()
	S:HandleButton(EncounterJournalEncounterFrameInstanceFrameMapButton)
	EncounterJournalEncounterFrameInstanceFrameMapButton:ClearAllPoints()
	EncounterJournalEncounterFrameInstanceFrameMapButton:Point("TOPLEFT", EncounterJournalEncounterFrameInstanceFrame, "TOPLEFT", 107, 40)
	EncounterJournalEncounterFrameInstanceFrameMapButton:Size(50, 30)

	EncounterJournalEncounterFrameInstanceFrameMapButtonText:ClearAllPoints()
	EncounterJournalEncounterFrameInstanceFrameMapButtonText:SetPoint("CENTER", EncounterJournalEncounterFrameInstanceFrameMapButton, "CENTER", 0, 0)

	-- Dungeon/Raid selection buttons
	local function SkinDungeons()
		local button1 = EncounterJournalInstanceSelectScrollFrameScrollChildInstanceButton1
		if button1 and not button1.isSkinned then
			S:HandleButton(button1)
			button1.bgImage:SetInside()
			button1.bgImage:SetTexCoord(0.08, 0.6, 0.08, 0.6)
			button1.bgImage:SetDrawLayer("ARTWORK")

			button1.isSkinned = true
		end

		for i = 1, 100 do
			local button = _G["EncounterJournalInstanceSelectScrollFrameinstance"..i]
			if button and not button.isSkinned then
				S:HandleButton(button)
				button.bgImage:SetInside()
				button.bgImage:SetTexCoord(0.08, 0.6, 0.08, 0.6)
				button.bgImage:SetDrawLayer("ARTWORK")

				button.isSkinned = true
			end
		end
	end
	hooksecurefunc("EncounterJournal_ListInstances", SkinDungeons)
	EncounterJournal_ListInstances()

	-- Boss selection buttons
	local function SkinBosses()
		local bossIndex = 1
		local _, _, bossID = EJ_GetEncounterInfoByIndex(bossIndex)
		local bossButton

		while bossID do
			bossButton = _G["EncounterJournalBossButton"..bossIndex]
			if bossButton and not bossButton.isSkinned then
				S:HandleButton(bossButton)
				bossButton.creature:ClearAllPoints()
				bossButton.creature:Point("TOPLEFT", 1, -4)

				bossButton.isSkinned = true
			end

			bossIndex = bossIndex + 1
			_, _, bossID = EJ_GetEncounterInfoByIndex(bossIndex)
		end
	end
	hooksecurefunc("EncounterJournal_DisplayInstance", SkinBosses)

	-- Loot buttons
	local items = EncounterJournal.encounter.info.lootScroll.buttons
	for i = 1, #items do
		local item = items[i]

		item:CreateBackdrop("Default")
		item.backdrop:Point("TOPLEFT", 0, -4)
		item.backdrop:Point("BOTTOMRIGHT", -2, E.PixelMode and 1 or -1)
		item:SetHitRectInsets(0, 2, 4, 1)
		item:HookScript("OnEnter", S.SetModifiedBackdrop)
		item:HookScript("OnLeave", S.SetOriginalBackdrop)

		item.name:ClearAllPoints()
		item.name:Point("TOPLEFT", item.icon, "TOPRIGHT", 6, -2)
		item.name:SetParent(item.backdrop)

		item.boss:SetTextColor(1, 1, 1)
		item.boss:ClearAllPoints()
		item.boss:Point("BOTTOMLEFT", 4, 6)
		item.boss:SetParent(item.backdrop)

		item.armorType:SetTextColor(1, 1, 1)
		item.armorType:ClearAllPoints()
		item.armorType:Point("BOTTOMRIGHT", item.name, "TOPLEFT", 264, -25)
		item.armorType:SetParent(item.backdrop)

		item.slot:SetTextColor(1, 1, 1)
		item.slot:ClearAllPoints()
		item.slot:Point("TOPLEFT", item.name, "BOTTOMLEFT", 0, -3)
		item.slot:SetParent(item.backdrop)

		item.IconBackdrop = CreateFrame("Frame", nil, item)
		item.IconBackdrop:SetTemplate("Default")
		item.IconBackdrop:SetFrameLevel(item:GetFrameLevel())
		item.IconBackdrop:SetOutside(item.icon)

		if i == 1 then
			item:Point("TOPLEFT", EncounterInfo.lootScroll.scrollChild, "TOPLEFT", 4, 0)

			item.icon:Point("TOPLEFT", E.PixelMode and 4 or 7, -(E.PixelMode and 7 or 10))
		else
			item.icon:Point("TOPLEFT", E.PixelMode and 3 or 5, -(E.PixelMode and 7 or 10))
		end

		item.icon:Size(E.PixelMode and 34 or 30)
		item.icon:SetDrawLayer("ARTWORK")
		item.icon:SetTexCoord(unpack(E.TexCoords))
		item.icon:SetParent(item.IconBackdrop)

		item.bossTexture:SetAlpha(0)
		item.bosslessTexture:SetAlpha(0)
	end

	local function SkinLootItems()
		local scrollFrame = EncounterJournal.encounter.info.lootScroll
		local offset = HybridScrollFrame_GetOffset(scrollFrame)
		local items = scrollFrame.buttons
		local item, index
		local numLoot = EJ_GetNumLoot()

		for i = 1, #items do
			item = items[i]
			index = offset + i
			if index <= numLoot then
				local _, _, _, _, itemID = EJ_GetLootInfoByIndex(index)
				local quality = select(3, GetItemInfo(itemID))

				item.IconBackdrop:SetBackdropBorderColor(GetItemQualityColor(quality))
			end
		end
	end
	hooksecurefunc("EncounterJournal_LootUpdate", SkinLootItems)
	hooksecurefunc("HybridScrollFrame_Update", SkinLootItems)

	-- Abilities Info (From Aurora)
	local function SkinAbilitiesInfo()
		local index = 1
		local header = _G["EncounterJournalInfoHeader"..index]
		while header do
			if not header.isSkinned then
				header.flashAnim.Play = E.noop

				header.descriptionBG:SetAlpha(0)
				header.descriptionBGBottom:SetAlpha(0)

				for i = 4, 18 do
					select(i, header.button:GetRegions()):SetTexture("")
				end

				header.description:SetTextColor(1, 1, 1)

				header.button.title:SetTextColor(unpack(E.media.rgbvaluecolor))
				header.button.title.SetTextColor = E.noop

				header.button.expandedIcon:SetTextColor(1, 1, 1)
				header.button.expandedIcon.SetTextColor = E.noop

				S:HandleButton(header.button)

				header.button.bg = CreateFrame("Frame", nil, header.button)
				header.button.bg:SetTemplate("Default")
				header.button.bg:SetOutside(header.button.abilityIcon)
				header.button.bg:SetFrameLevel(header.button.bg:GetFrameLevel() - 1)

				header.button.abilityIcon:SetTexCoord(unpack(E.TexCoords))
				header.button.abilityIcon:SetParent(header.button.bg)

				header.isSkinned = true
			end

			if header.button.abilityIcon:IsShown() then
				header.button.bg:Show()
			else
				header.button.bg:Hide()
			end

			index = index + 1
			header = _G["EncounterJournalInfoHeader"..index]
		end
	end
	hooksecurefunc("EncounterJournal_ToggleHeaders", SkinAbilitiesInfo)

	-- Search Frame
	EncounterJournalSearchResultsScrollFrame:StripTextures()
	EncounterJournalSearchResultsScrollFrameScrollChild:StripTextures()

	for i = 1, 9 do
		local button = _G["EncounterJournalSearchResultsScrollFrameButton"..i]

		button:StripTextures()
		button:SetTemplate("Default")
		button:StyleButton()
		button:CreateBackdrop()
		button.backdrop:SetOutside(button.icon)

		button.icon:Point("TOPLEFT", 6, -7)
		button.icon:SetParent(button.backdrop)
	end

	local function SkinSearchUpdate()
		local scrollFrame = EncounterJournal.searchResults.scrollFrame
		local offset = HybridScrollFrame_GetOffset(scrollFrame)
		local results = scrollFrame.buttons
		local result, index
		local numResults = EJ_GetNumSearchResults()

		for i = 1, #results do
			result = results[i]
			index = offset + i
			if index <= numResults then
				local _, _, _, _, _, itemID, stype = EncounterJournal_GetSearchDisplay(index)

				local quality, r, g, b
				if itemID then
					quality = select(3, GetItemInfo(itemID))
					if quality then
						r, g, b = GetItemQualityColor(quality)
					else
						r, g, b = unpack(E.media.bordercolor)
					end
				end

				if stype == 4 then
					result.backdrop:SetBackdropBorderColor(unpack(E.media.bordercolor))
					result.icon:SetTexCoord(0.16796875, 0.51171875, 0.03125, 0.71875)
				else
					result.backdrop:SetBackdropBorderColor(r, g, b)
					result.icon:SetTexCoord(unpack(E.TexCoords))
					result.icon.SetTexCoord = E.noop
				end
			end
		end
	end
	hooksecurefunc("EncounterJournal_SearchUpdate", SkinSearchUpdate)
	hooksecurefunc("HybridScrollFrame_Update", SkinSearchUpdate)

	for i = 1, 5 do
		local button = _G["EncounterJournalSearchBoxSearchButton"..i]

		button:StripTextures()
		button:SetTemplate("Default")
		button:StyleButton()

		button:CreateBackdrop()
		button.backdrop:SetOutside(button.icon)
		button.backdrop:SetFrameLevel(button.backdrop:GetFrameLevel() + 2)

		button.icon:SetTexCoord(unpack(E.TexCoords))
		button.icon:Point("TOPLEFT", 4, -5)
		button.icon:SetParent(button.backdrop)
	end

	S:HandleButton(EncounterJournalSearchBoxShowALL)

	EncounterJournalSearchResults:StripTextures()
	EncounterJournalSearchResults:SetTemplate("Transparent")

	S:HandleScrollBar(EncounterJournalSearchResultsScrollFrameScrollBar)
	S:HandleCloseButton(EncounterJournalSearchResultsCloseButton)

	S:HandleScrollBar(EncounterJournalInstanceSelectScrollFrameScrollBar, 4)
	S:HandleScrollBar(EncounterJournalEncounterFrameInfoDetailsScrollFrameScrollBar, 4)
	S:HandleScrollBar(EncounterJournalEncounterFrameInfoLootScrollFrameScrollBar, 4)
	S:HandleScrollBar(EncounterJournalEncounterFrameInstanceFrameLoreScrollFrameScrollBar, 4)
	EncounterJournalEncounterFrameInstanceFrameLoreScrollFrameScrollBar:Point("TOPLEFT", EncounterJournalEncounterFrameInstanceFrameLoreScrollFrame, "TOPRIGHT", 10, -17)
end

S:AddCallbackForAddon("Blizzard_EncounterJournal", "EncounterJournal", LoadSkin)