local E, L, V, P, G = unpack(select(2, ...));
local S = E:GetModule('Skins')

local _G = _G
local select, unpack, pairs = select, unpack, pairs

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.encounterjournal ~= true then return end

	local EJ = EncounterJournal

	EJ:StripTextures(true)
	EJ:CreateBackdrop("Transparent")

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
			local navButton = self.navList[i];
			local lastNav = self.navList[i-1];
			if(navButton and lastNav) then
				navButton:SetFrameLevel(lastNav:GetFrameLevel() - 2);
				navButton:ClearAllPoints();
				navButton:Point("LEFT", lastNav, "RIGHT", 1, 0);
			end
		end
	end

	hooksecurefunc("NavBar_AddButton", function(self)
		if(self:GetParent():GetName() == "HelpFrameKnowledgebase") then return; end

		local navButton = self.navList[#self.navList];

		if(not navButton.skinned) then
			S:HandleButton(navButton, true);
			navButton.skinned = true;

			navButton:HookScript("OnClick", function()
				navButtonFrameLevel(self);
			end)
		end

		navButtonFrameLevel(self);
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

	--Instance Selection Frame
	local InstanceSelect = EJ.instanceSelect
	InstanceSelect.bg:Kill()
	S:HandleNextPrevButton(EncounterJournalInstanceSelectScrollDownButton)
	S:HandleScrollBar(InstanceSelect.scroll.ScrollBar, 4)

	--Dungeon/Raid Tabs
	InstanceSelect.dungeonsTab:StripTextures()
	InstanceSelect.dungeonsTab.backdrop = CreateFrame("Frame", nil, InstanceSelect.dungeonsTab)
	InstanceSelect.dungeonsTab.backdrop:SetTemplate("Default", true)
	InstanceSelect.dungeonsTab.backdrop:SetFrameLevel(InstanceSelect.dungeonsTab:GetFrameLevel() - 1)
	InstanceSelect.dungeonsTab.backdrop:Point("TOPLEFT", 3, -7)
	InstanceSelect.dungeonsTab.backdrop:Point("BOTTOMRIGHT", -2, -1)
	InstanceSelect.dungeonsTab:Point("BOTTOMRIGHT", EncounterJournalInstanceSelectRaidTab, "BOTTOMLEFT", 0, 0)
	InstanceSelect.dungeonsTab:HookScript("OnEnter", S.SetModifiedBackdrop);
	InstanceSelect.dungeonsTab:HookScript("OnLeave", S.SetOriginalBackdrop);

	InstanceSelect.raidsTab:StripTextures()
	InstanceSelect.raidsTab.backdrop = CreateFrame("Frame", nil, InstanceSelect.raidsTab)
	InstanceSelect.raidsTab.backdrop:SetTemplate("Default", true)
	InstanceSelect.raidsTab.backdrop:SetFrameLevel(InstanceSelect.raidsTab:GetFrameLevel() - 1)
	InstanceSelect.raidsTab.backdrop:Point("TOPLEFT", 3, -7)
	InstanceSelect.raidsTab.backdrop:Point("BOTTOMRIGHT", -2, -1)
	InstanceSelect.raidsTab:HookScript("OnEnter", S.SetModifiedBackdrop);
	InstanceSelect.raidsTab:HookScript("OnLeave", S.SetOriginalBackdrop);

	--Encounter Info Frame
	local EncounterInfo = EJ.encounter.info
	EncounterJournalEncounterFrameInfoBG:Kill()

	EncounterInfo.difficulty:StripTextures()
	S:HandleButton(EncounterInfo.difficulty)
	EncounterInfo.difficulty:SetFrameLevel(EncounterInfo.difficulty:GetFrameLevel() + 1)
	EncounterInfo.difficulty:Width(100)
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
	S:HandleButton(EncounterInfo.lootScroll.filter)

	EncounterInfo.detailsScroll.child.description:SetTextColor(1, 1, 1)

	--Boss/Loot Tab
	EncounterJournalEncounterFrameInfoBossTab:StripTextures()
	EncounterJournalEncounterFrameInfoBossTab:CreateBackdrop('Transparent')
	EncounterJournalEncounterFrameInfoBossTab.backdrop:Point('TOPLEFT', 11, -8)
	EncounterJournalEncounterFrameInfoBossTab.backdrop:Point('BOTTOMRIGHT', -6, 8)
	EncounterJournalEncounterFrameInfoBossTab:SetPoint("TOPLEFT", EncounterJournalEncounterFrameInfo, "TOPRIGHT", -2, 40)

	EncounterJournalEncounterFrameInfoBossTab.icon = EncounterJournalEncounterFrameInfoBossTab:CreateTexture(nil, "OVERLAY");
	EncounterJournalEncounterFrameInfoBossTab.icon:SetTexture("Interface\\EncounterJournal\\UI-EncounterJournalTextures")
	EncounterJournalEncounterFrameInfoBossTab.icon:SetTexCoord(0.902, 0.996, 0.269, 0.311)
	EncounterJournalEncounterFrameInfoBossTab.icon:SetPoint("TOPLEFT", EncounterJournalEncounterFrameInfoBossTab, "TOPLEFT", 7, -7)
	EncounterJournalEncounterFrameInfoBossTab.icon:SetPoint("BOTTOMRIGHT", EncounterJournalEncounterFrameInfoBossTab, "BOTTOMRIGHT", -7, 7)
	EncounterJournalEncounterFrameInfoBossTab.icon:SetDesaturated(false)

	EncounterJournalEncounterFrameInfoLootTab:StripTextures()
	EncounterJournalEncounterFrameInfoLootTab:CreateBackdrop('Transparent')
	EncounterJournalEncounterFrameInfoLootTab.backdrop:Point('TOPLEFT', 11, -8)
	EncounterJournalEncounterFrameInfoLootTab.backdrop:Point('BOTTOMRIGHT', -6, 8)
	EncounterJournalEncounterFrameInfoLootTab:SetPoint("TOP", EncounterJournalEncounterFrameInfoBossTab, "BOTTOM", 0, 5)

	EncounterJournalEncounterFrameInfoLootTab.icon = EncounterJournalEncounterFrameInfoLootTab:CreateTexture(nil, "OVERLAY");
	EncounterJournalEncounterFrameInfoLootTab.icon:SetTexture("Interface\\EncounterJournal\\UI-EncounterJournalTextures")
	EncounterJournalEncounterFrameInfoLootTab.icon:SetTexCoord(0.632, 0.726, 0.618, 0.660)
	EncounterJournalEncounterFrameInfoLootTab.icon:SetPoint("TOPLEFT", EncounterJournalEncounterFrameInfoLootTab, "TOPLEFT", 7, -7)
	EncounterJournalEncounterFrameInfoLootTab.icon:SetPoint("BOTTOMRIGHT", EncounterJournalEncounterFrameInfoLootTab, "BOTTOMRIGHT", -7, 7)
	EncounterJournalEncounterFrameInfoLootTab.icon:SetDesaturated(true)

	EncounterJournalEncounterFrameInfoModelTab:StripTextures()
	EncounterJournalEncounterFrameInfoModelTab:CreateBackdrop('Transparent')
	EncounterJournalEncounterFrameInfoModelTab.backdrop:Point('TOPLEFT', 11, -8)
	EncounterJournalEncounterFrameInfoModelTab.backdrop:Point('BOTTOMRIGHT', -6, 8)
	EncounterJournalEncounterFrameInfoModelTab:SetPoint("TOP", EncounterJournalEncounterFrameInfoLootTab, "BOTTOM", 0, 5)

	EncounterJournalEncounterFrameInfoModelTab.icon = EncounterJournalEncounterFrameInfoModelTab:CreateTexture(nil, "OVERLAY");
	EncounterJournalEncounterFrameInfoModelTab.icon:SetTexture("Interface\\EncounterJournal\\UI-EncounterJournalTextures")
	EncounterJournalEncounterFrameInfoModelTab.icon:SetTexCoord(0.804, 0.900, 0.662, 0.705)
	EncounterJournalEncounterFrameInfoModelTab.icon:SetPoint("TOPLEFT", EncounterJournalEncounterFrameInfoModelTab, "TOPLEFT", 7, -7)
	EncounterJournalEncounterFrameInfoModelTab.icon:SetPoint("BOTTOMRIGHT", EncounterJournalEncounterFrameInfoModelTab, "BOTTOMRIGHT", -7, 7)
	EncounterJournalEncounterFrameInfoModelTab.icon:SetDesaturated(true)

	EncounterJournalEncounterFrameInfoBossTab:HookScript("OnClick", function()
		EncounterJournalEncounterFrameInfoBossTab.icon:SetDesaturated(false)
		EncounterJournalEncounterFrameInfoLootTab.icon:SetDesaturated(true)
		EncounterJournalEncounterFrameInfoModelTab.icon:SetDesaturated(true)
	end)

	EncounterJournalEncounterFrameInfoLootTab:HookScript("OnClick", function()
		EncounterJournalEncounterFrameInfoLootTab.icon:SetDesaturated(false)
		EncounterJournalEncounterFrameInfoBossTab.icon:SetDesaturated(true)
		EncounterJournalEncounterFrameInfoModelTab.icon:SetDesaturated(true)
	end)

	EncounterJournalEncounterFrameInfoModelTab:HookScript("OnClick", function()
		EncounterJournalEncounterFrameInfoModelTab.icon:SetDesaturated(false)
		EncounterJournalEncounterFrameInfoBossTab.icon:SetDesaturated(true)
		EncounterJournalEncounterFrameInfoLootTab.icon:SetDesaturated(true)
	end)

	--Encounter Instance Frame
	local EncounterInstance = EJ.encounter.instance

	EncounterInstance:CreateBackdrop("Transparent", true)
	EncounterInstance.loreScroll.child.lore:SetTextColor(1, 1, 1)

	EncounterJournalEncounterFrameInfoLootScrollFrameClassFilterClearFrame:StripTextures()

	EncounterJournalEncounterFrameInstanceFrameMapButton:StripTextures();
	S:HandleButton(EncounterJournalEncounterFrameInstanceFrameMapButton)
	EncounterJournalEncounterFrameInstanceFrameMapButton:ClearAllPoints()
	EncounterJournalEncounterFrameInstanceFrameMapButton:Point("TOPLEFT", EncounterJournalEncounterFrameInstanceFrame, "TOPLEFT", 107, 40)
	EncounterJournalEncounterFrameInstanceFrameMapButton:Size(50, 30)

	EncounterJournalEncounterFrameInstanceFrameMapButtonText:ClearAllPoints()
	EncounterJournalEncounterFrameInstanceFrameMapButtonText:SetPoint("CENTER", EncounterJournalEncounterFrameInstanceFrameMapButton, "CENTER", 0, 0)

	--Dungeon/raid selection buttons
	local function SkinDungeons()
		local b1 = EncounterJournalInstanceSelectScrollFrameScrollChildInstanceButton1
		if b1 and not b1.isSkinned then
			S:HandleButton(b1)
			b1.bgImage:SetInside()
			b1.bgImage:SetTexCoord(.08, .6, .08, .6)
			b1.bgImage:SetDrawLayer("ARTWORK")
			b1.isSkinned = true
		end

		for i = 1, 100 do
			local b = _G["EncounterJournalInstanceSelectScrollFrameinstance"..i]
			if b and not b.isSkinned then
				S:HandleButton(b)
				b.bgImage:SetInside()
				b.bgImage:SetTexCoord(0.08,.6,0.08,.6)
				b.bgImage:SetDrawLayer("ARTWORK")
				b.isSkinned = true
			end
		end
	end
	hooksecurefunc("EncounterJournal_ListInstances", SkinDungeons)
	EncounterJournal_ListInstances()

	--Boss selection buttons
	local function SkinBosses()
		local bossIndex = 1;
		local name, description, bossID, _, link = EJ_GetEncounterInfoByIndex(bossIndex);
		local bossButton;

		while bossID do
			bossButton = _G["EncounterJournalBossButton"..bossIndex];
			if bossButton and not bossButton.isSkinned then
				S:HandleButton(bossButton)
				bossButton.isSkinned = true
			end

			bossIndex = bossIndex + 1;
			name, description, bossID, _, link = EJ_GetEncounterInfoByIndex(bossIndex);
		end
	end
	hooksecurefunc("EncounterJournal_DisplayInstance", SkinBosses)

	--Loot buttons
	local items = EncounterJournal.encounter.info.lootScroll.buttons
	for i = 1, #items do
		local item = items[i]

		item.boss:SetTextColor(1, 1, 1)
		item.boss:ClearAllPoints()
		item.boss:Point("BOTTOMLEFT", 4, 7)
		item.slot:SetTextColor(1, 1, 1)
		item.armorType:SetTextColor(1, 1, 1)
		item.armorType:ClearAllPoints()
		item.armorType:Point("BOTTOMRIGHT", item.name, "TOPLEFT", 264, -25)

		item.bossTexture:SetAlpha(0)
		item.bosslessTexture:SetAlpha(0)

		item.icon:SetSize(41, 41)
		item.icon:Point("TOPLEFT", 2, -2)

		S:HandleIcon(item.icon)
		item.icon:SetDrawLayer("OVERLAY")

		item:SetTemplate("Default");
		item:StyleButton()

		if i == 1 then
			item:ClearAllPoints()
			item:Point("TOPLEFT", EncounterInfo.lootScroll.scrollChild, "TOPLEFT", 5, 0)
		end
	end

	--Abilities Info (From Aurora)
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
				header.button.bg:SetOutside(header.button.abilityIcon)
				header.button.bg:SetFrameLevel(header.button.bg:GetFrameLevel() - 1)
				header.button.abilityIcon:SetTexCoord(.08, .92, .08, .92)

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

	--Search Frame
	EncounterJournalSearchResultsScrollFrame:StripTextures();
	EncounterJournalSearchResultsScrollFrameScrollChild:StripTextures();

	for i = 1, 9 do
		local button = _G["EncounterJournalSearchResultsScrollFrameButton"..i]
		local icon = _G["EncounterJournalSearchResultsScrollFrameButton"..i.."Icon"]

		button:StripTextures();
		button:SetTemplate("Default")
		button:StyleButton()
		button:CreateBackdrop()
		button.backdrop:SetOutside(icon)

		icon:Point("TOPLEFT", 2, -7)
		icon:SetParent(button.backdrop)
	end

	hooksecurefunc("EncounterJournal_SearchUpdate", function()
		local scrollFrame = EncounterJournal.searchResults.scrollFrame;
		local offset = HybridScrollFrame_GetOffset(scrollFrame);
		local results = scrollFrame.buttons;
		local result, index;
		local numResults = EJ_GetNumSearchResults();

		for i = 1, #results do
			result = results[i];
			index = offset + i;
			if(index <= numResults) then
				local _, icon = EncounterJournal_GetSearchDisplay(index);

				result.icon:SetTexCoord(unpack(E.TexCoords))
				result.icon.SetTexCoord = E.noop;
			end
		end
	end)

	for i = 1, 5 do
		local button = _G["EncounterJournalSearchBoxSearchButton"..i]
		local icon = _G["EncounterJournalSearchBoxSearchButton"..i.."Icon"]

		button:CreateBackdrop()
		button:StripTextures();
		button:StyleButton()

		icon:SetTexCoord(unpack(E.TexCoords))
		icon:Point("TOPLEFT", 1, -4)
	end

	S:HandleButton(EncounterJournalSearchBoxShowALL)

	EncounterJournalSearchResults:StripTextures();
	EncounterJournalSearchResults:SetTemplate("Transparent")

	S:HandleScrollBar(EncounterJournalSearchResultsScrollFrameScrollBar)
	S:HandleCloseButton(EncounterJournalSearchResultsCloseButton)

	S:HandleScrollBar(EncounterJournalInstanceSelectScrollFrameScrollBar, 4)
	S:HandleScrollBar(EncounterJournalEncounterFrameInfoDetailsScrollFrameScrollBar, 4)
	S:HandleScrollBar(EncounterJournalEncounterFrameInfoLootScrollFrameScrollBar, 4)
	S:HandleScrollBar(EncounterJournalEncounterFrameInstanceFrameLoreScrollFrameScrollBar, 4)
end

S:AddCallbackForAddon("Blizzard_EncounterJournal", "EncounterJournal", LoadSkin);