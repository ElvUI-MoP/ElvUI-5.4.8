local E, L, V, P, G = unpack(select(2, ...))
local S = E:GetModule("Skins")

local _G = _G
local unpack, pairs, select = unpack, pairs, select

local CharacterFrameExpandButton = CharacterFrameExpandButton
local GetNumFactions = GetNumFactions
local hooksecurefunc = hooksecurefunc

local function LoadSkin()
	if not E.private.skins.blizzard.enable or not E.private.skins.blizzard.character then return end

	CharacterFrameInset:StripTextures()
	CharacterFrameInsetRight:StripTextures()

	CharacterFramePortrait:Kill()

	CharacterFrame:StripTextures()
	CharacterFrame:SetTemplate("Transparent")

	CharacterModelFrame:StripTextures()
	CharacterModelFrame:CreateBackdrop("Default")
	CharacterModelFrame.backdrop:Point("TOPLEFT", -1, 1)
	CharacterModelFrame.backdrop:Point("BOTTOMRIGHT", 1, -2)

	--Re-add the overlay texture which was removed right above via StripTextures
	CharacterModelFrameBackgroundOverlay:SetTexture(0, 0, 0)

	-- Give character frame model backdrop it's color back
	for _, corner in pairs({"TopLeft", "TopRight", "BotLeft", "BotRight"}) do
		local bg = _G["CharacterModelFrameBackground"..corner]
		if bg then
			bg:SetDesaturated(false)
			bg.ignoreDesaturated = true -- so plugins can prevent this if they want.
			hooksecurefunc(bg, "SetDesaturated", function(bckgnd, value)
				if value and bckgnd.ignoreDesaturated then
					bckgnd:SetDesaturated(false)
				end
			end)
		end
	end

	S:HandleCloseButton(CharacterFrameCloseButton)

	local slots = {
		"HeadSlot",
		"NeckSlot",
		"ShoulderSlot",
		"BackSlot",
		"ChestSlot",
		"ShirtSlot",
		"TabardSlot",
		"WristSlot",
		"HandsSlot",
		"WaistSlot",
		"LegsSlot",
		"FeetSlot",
		"Finger0Slot",
		"Finger1Slot",
		"Trinket0Slot",
		"Trinket1Slot",
		"MainHandSlot",
		"SecondaryHandSlot"
	}

	for _, slot in pairs(slots) do
		local button = _G["Character"..slot]
		local icon = _G["Character"..slot.."IconTexture"]
		local cooldown = _G["Character"..slot.."Cooldown"]
		local popout = _G["Character"..slot.."PopoutButton"]

		button:StripTextures()
		button:SetTemplate("Default", true, true)
		button:StyleButton()
		button:SetFrameLevel(PaperDollFrame:GetFrameLevel() + 2)
		button.ignoreTexture:SetTexture([[Interface\PaperDollInfoFrame\UI-GearManager-LeaveItem-Transparent]])

		icon:SetTexCoord(unpack(E.TexCoords))
		icon:SetInside()

		if cooldown then
			E:RegisterCooldown(cooldown)
		end

		if popout then
			popout:StripTextures()
			popout:SetTemplate("Default", true)
			popout:HookScript("OnEnter", S.SetModifiedBackdrop)
			popout:HookScript("OnLeave", S.SetOriginalBackdrop)

			popout.icon = popout:CreateTexture(nil, "ARTWORK")
			popout.icon:Size(14)
			popout.icon:Point("CENTER")
			popout.icon:SetTexture(E.Media.Textures.ArrowUp)

			if button.verticalFlyout then
				popout:Size(27, 11)
				popout:Point("TOP", button, "BOTTOM", 0, 5)

				popout.icon:SetRotation(3.14)
			else
				popout:Size(11, 27)
				popout:Point("LEFT", button, "RIGHT", -5, 0)

				popout.icon:SetRotation(-1.57)
			end
		end
	end

	hooksecurefunc("EquipmentFlyoutPopoutButton_SetReversed", function(self, isReversed)
		if self:GetParent():GetParent() ~= PaperDollItemsFrame then return end

		if self:GetParent().verticalFlyout then
			if isReversed then
				self.icon:SetRotation(0)
			else
				self.icon:SetRotation(3.14)
			end
		else
			if isReversed then
				self.icon:SetRotation(1.57)
			else
				self.icon:SetRotation(-1.57)
			end
		end
	end)

	EquipmentFlyoutFrameHighlight:Kill()

	EquipmentFlyoutFrame.NavigationFrame:StripTextures()
	EquipmentFlyoutFrame.NavigationFrame:SetTemplate("Transparent")
	EquipmentFlyoutFrame.NavigationFrame:Point("TOPLEFT", EquipmentFlyoutFrameButtons, "BOTTOMLEFT", 0, -E.Border - E.Spacing)
	EquipmentFlyoutFrame.NavigationFrame:Point("TOPRIGHT", EquipmentFlyoutFrameButtons, "BOTTOMRIGHT", 0, -E.Border - E.Spacing)

	S:HandleNextPrevButton(EquipmentFlyoutFrame.NavigationFrame.PrevButton)
	S:HandleNextPrevButton(EquipmentFlyoutFrame.NavigationFrame.NextButton)

	hooksecurefunc("EquipmentFlyout_DisplayButton", function(button)
		button:GetNormalTexture():SetTexture(nil)
		button:SetTemplate("Default")
		button:StyleButton()

		button.icon = _G[button:GetName().."IconTexture"]
		button.icon:SetTexCoord(unpack(E.TexCoords))
		button.icon:SetInside()

		local cooldown = _G[button:GetName().."Cooldown"]
		if cooldown then
			E:RegisterCooldown(cooldown)
		end

		local location = button.location
		if not location then return end
		if location and location >= EQUIPMENTFLYOUT_FIRST_SPECIAL_LOCATION then return end

		local id = EquipmentManager_GetItemInfoByLocation(location)
		local _, _, quality = GetItemInfo(id)
		local r, g, b = GetItemQualityColor(quality)

		button:SetBackdropBorderColor(r, g, b)
	end)

	hooksecurefunc("EquipmentFlyout_Show", function(self)
		local frame = EquipmentFlyoutFrame.buttonFrame

		frame:StripTextures()
		frame:SetTemplate("Transparent")

		local width, height = frame:GetSize()
		frame:Size(width + 3, height)

		if self.verticalFlyout then
			frame:Point("TOPLEFT", self.popoutButton, "BOTTOMLEFT", -10, 0)
		else
			frame:Point("TOPLEFT", self.popoutButton, "TOPRIGHT", 0, 10)
		end
	end)

	local function ColorItemBorder()
		for _, slot in pairs(slots) do
			local button = _G["Character"..slot]
			local slotID = GetInventorySlotInfo(slot)
			local itemID = GetInventoryItemID("player", slotID)

			if itemID then
				local rarity = GetInventoryItemQuality("player", slotID)
				if rarity then
					button:SetBackdropBorderColor(GetItemQualityColor(rarity))
				else
					button:SetBackdropBorderColor(unpack(E.media.bordercolor))
				end
			else
				button:SetBackdropBorderColor(unpack(E.media.bordercolor))
			end
		end
	end

	local CheckItemBorderColor = CreateFrame("Frame")
	CheckItemBorderColor:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
	CheckItemBorderColor:SetScript("OnEvent", ColorItemBorder)
	CharacterFrame:HookScript("OnShow", ColorItemBorder)
	ColorItemBorder()

	CharacterFrameExpandButton:Size(CharacterFrameExpandButton:GetWidth() - 5, CharacterFrameExpandButton:GetHeight() - 5)
	S:HandleNextPrevButton(CharacterFrameExpandButton)

	hooksecurefunc("CharacterFrame_Collapse", function()
		CharacterFrameExpandButton:SetNormalTexture(E.Media.Textures.ArrowUp)
		CharacterFrameExpandButton:SetPushedTexture(E.Media.Textures.ArrowUp)
		CharacterFrameExpandButton:SetDisabledTexture(E.Media.Textures.ArrowUp)

		CharacterFrameExpandButton:GetNormalTexture():SetRotation(-1.57)
		CharacterFrameExpandButton:GetPushedTexture():SetRotation(-1.57)
	end)

	hooksecurefunc("CharacterFrame_Expand", function()
		CharacterFrameExpandButton:SetNormalTexture(E.Media.Textures.ArrowUp)
		CharacterFrameExpandButton:SetPushedTexture(E.Media.Textures.ArrowUp)
		CharacterFrameExpandButton:SetDisabledTexture(E.Media.Textures.ArrowUp)

		CharacterFrameExpandButton:GetNormalTexture():SetRotation(1.57)
		CharacterFrameExpandButton:GetPushedTexture():SetRotation(1.57)
	end)

	if GetCVar("characterFrameCollapsed") ~= "0" then
		CharacterFrameExpandButton:GetNormalTexture():SetRotation(-1.57)
		CharacterFrameExpandButton:GetPushedTexture():SetRotation(-1.57)
	else
		CharacterFrameExpandButton:GetNormalTexture():SetRotation(1.57)
		CharacterFrameExpandButton:GetPushedTexture():SetRotation(1.57)
	end

	-- Control Frame
	S:HandleModelControlFrame(CharacterModelFrameControlFrame)

	-- Titles
	PaperDollTitlesPane:HookScript("OnShow", function()
		for _, object in pairs(PaperDollTitlesPane.buttons) do
			object.BgTop:SetTexture(nil)
			object.BgBottom:SetTexture(nil)
			object.BgMiddle:SetTexture(nil)
			object.Check:SetTexture(nil)

			S:HandleButtonHighlight(object)
			object.handledHighlight:Point("TOPLEFT", 0, -1)

			object.SelectedBar:SetTexture(E.Media.Textures.Highlight)
			object.SelectedBar:SetVertexColor(unpack(E.media.rgbvaluecolor))
			object.SelectedBar:Point("TOPLEFT", 0, -1)

			object.Stripe:SetTexture(E.Media.Textures.Highlight)
			object.Stripe.SetTexture = E.noop
			object.Stripe:Point("TOPLEFT", 0, -1)

			object.text:FontTemplate()
			object.text.SetFont = E.noop
		end
	end)

	S:HandleScrollBar(PaperDollTitlesPaneScrollBar)

	-- Equipement Manager
	PaperDollEquipmentManagerPane:StripTextures()

	PaperDollEquipmentManagerPane:HookScript("OnShow", function()
		for _, object in pairs(PaperDollEquipmentManagerPane.buttons) do
			object.BgTop:SetTexture(nil)
			object.BgBottom:SetTexture(nil)
			object.BgMiddle:SetTexture(nil)
			object.Check:SetTexture(nil)

			object.SelectedBar:SetTexture(E.Media.Textures.Highlight)
			object.SelectedBar:SetVertexColor(unpack(E.media.rgbvaluecolor))
			object.SelectedBar:Point("TOPLEFT", object, 42, -1)
			object.SelectedBar:Point("BOTTOMRIGHT", object, 0, 1)
			object.SelectedBar:SetTexCoord(0, 1, 0, 1)
			object.SelectedBar.SetTexCoord = E.noop

			object.HighlightBar:SetTexture(E.Media.Textures.Highlight)
			object.HighlightBar:SetVertexColor(1, 1, 1, 0.35)
			object.HighlightBar:Point("TOPLEFT", object, 42, -1)
			object.HighlightBar:Point("BOTTOMRIGHT", object, 0, 1)
			object.HighlightBar:SetTexCoord(0, 1, 0, 1)
			object.HighlightBar.SetTexCoord = E.noop

			object.Stripe:SetTexture(E.Media.Textures.Highlight)
			object.Stripe.SetTexture = E.noop
			object.Stripe:Point("TOPLEFT", object, 42, -1)
			object.Stripe:Point("BOTTOMRIGHT", object, 0, 1)

			object:CreateBackdrop("Default")
			object.backdrop:Point("TOPLEFT", object.icon, -1, 1)
			object.backdrop:Point("BOTTOMRIGHT", object.icon, 1, -1)

			object.icon:SetTexCoord(unpack(E.TexCoords))
			object.icon:SetParent(object.backdrop)
			object.icon:Point("LEFT", object, "LEFT", 1, 0)
			object.icon.SetPoint = E.noop
			object.icon:Size(40)
			object.icon.SetSize = E.noop
		end
	end)

	S:HandleButton(PaperDollEquipmentManagerPaneEquipSet)
	PaperDollEquipmentManagerPaneEquipSet:Point("TOPLEFT", PaperDollEquipmentManagerPane, "TOPLEFT", 8, 0)
	PaperDollEquipmentManagerPaneEquipSet:Width(PaperDollEquipmentManagerPaneEquipSet:GetWidth() - 8)
	PaperDollEquipmentManagerPaneEquipSet.ButtonBackground:SetTexture(nil)

	S:HandleButton(PaperDollEquipmentManagerPaneSaveSet)
	PaperDollEquipmentManagerPaneSaveSet:Point("LEFT", PaperDollEquipmentManagerPaneEquipSet, "RIGHT", 4, 0)
	PaperDollEquipmentManagerPaneSaveSet:Width(PaperDollEquipmentManagerPaneSaveSet:GetWidth() - 8)

	S:HandleScrollBar(PaperDollEquipmentManagerPaneScrollBar)

	-- Equipement Manager Popup
	S:HandleIconSelectionFrame(GearManagerDialogPopup, NUM_GEARSET_ICONS_SHOWN, "GearManagerDialogPopupButton")

	S:HandleScrollBar(GearManagerDialogPopupScrollFrameScrollBar)

	GearManagerDialogPopupScrollFrame:CreateBackdrop("Transparent")
	GearManagerDialogPopupScrollFrame.backdrop:Point("TOPLEFT", 51, 2)
	GearManagerDialogPopupScrollFrame.backdrop:Point("BOTTOMRIGHT", 0, 4)

	GearManagerDialogPopup:Point("TOPLEFT", PaperDollFrame, "TOPRIGHT", 1, 0)

	-- Bottom Tabs
	for i = 1, 4 do
		S:HandleTab(_G["CharacterFrameTab"..i])
	end

	-- Character Tabs
	PaperDollSidebarTabs:StripTextures()

	hooksecurefunc("PaperDollFrame_UpdateSidebarTabs", function()
		for i = 1, #PAPERDOLL_SIDEBARS do
			local tab = _G["PaperDollSidebarTab"..i]
			if tab then
				tab:CreateBackdrop("Default", true)

				tab.Highlight:SetTexture(1, 1, 1, 0.3)
				tab.Highlight:SetInside(tab.backdrop)

				tab.Hider:SetTexture(0, 0, 0, 0.8)
				tab.Hider:SetInside(tab.backdrop)

				tab.TabBg:Kill()

				if i == 1 then
					for x = 1, tab:GetNumRegions() do
						local region = select(x, tab:GetRegions())
						region:SetTexCoord(0.16, 0.86, 0.16, 0.86)
						region.SetTexCoord = E.noop
						region:SetInside(tab.backdrop)
					end
				end
			end
		end
	end)

	-- Stat Panels
	CharacterStatsPane:StripTextures()

	S:HandleScrollBar(CharacterStatsPaneScrollBar)

	for i = 1, 7 do
		_G["CharacterStatsPaneCategory"..i]:StripTextures()
	end

	-- Reputation
	ReputationFrame:StripTextures(true)

	ReputationListScrollFrame:StripTextures()
	S:HandleScrollBar(ReputationListScrollFrameScrollBar)

	for i = 1, NUM_FACTIONS_DISPLAYED do
		local frame = _G["ReputationBar"..i]
		local bar = _G["ReputationBar"..i.."ReputationBar"]
		local button = _G["ReputationBar"..i.."ExpandOrCollapseButton"]

		frame:StripTextures(true)

		frame.War = frame:CreateTexture(nil, "OVERLAY")
		frame.War:SetTexture("Interface\\Buttons\\UI-CheckBox-SwordCheck")
		frame.War:Size(30)
		frame.War:Point("RIGHT", 32, -5)

		bar:StripTextures()
		bar:CreateBackdrop("Default")
		bar:SetStatusBarTexture(E.media.normTex)
		E:RegisterStatusBar(bar)

		button:SetNormalTexture(E.Media.Textures.Minus)
		button.SetNormalTexture = E.noop
		button:GetNormalTexture():Size(16)
		button:GetNormalTexture():Point("LEFT", 4, 1)
		button:SetHighlightTexture(nil)
	end

	hooksecurefunc("ReputationFrame_Update", function()
		local factionOffset = FauxScrollFrame_GetOffset(ReputationListScrollFrame)
		local numFactions = GetNumFactions()

		for i = 1, NUM_FACTIONS_DISPLAYED, 1 do
			local frame = _G["ReputationBar"..i]
			local button = _G["ReputationBar"..i.."ExpandOrCollapseButton"]
			local factionIndex = factionOffset + i

			if factionIndex <= numFactions then
				local _, _, _, _, _, _, atWarWith, canToggleAtWar, isHeader, isCollapsed = GetFactionInfo(factionIndex)

				if isCollapsed then
					button:GetNormalTexture():SetTexture(E.Media.Textures.Plus)
				else
					button:GetNormalTexture():SetTexture(E.Media.Textures.Minus)
				end

				if atWarWith and canToggleAtWar and (not isHeader) then
					frame.War:Show()
				else
					frame.War:Hide()
				end
			end
		end
	end)

	ReputationDetailFrame:StripTextures()
	ReputationDetailFrame:SetTemplate("Transparent")
	ReputationDetailFrame:Point("TOPLEFT", ReputationFrame, "TOPRIGHT", 1, 0)

	S:HandleCheckBox(ReputationDetailMainScreenCheckBox)
	S:HandleCheckBox(ReputationDetailInactiveCheckBox)
	S:HandleCheckBox(ReputationDetailLFGBonusReputationCheckBox)

	S:HandleCheckBox(ReputationDetailAtWarCheckBox)
	ReputationDetailAtWarCheckBox:SetCheckedTexture("Interface\\Buttons\\UI-CheckBox-SwordCheck")

	S:HandleCloseButton(ReputationDetailCloseButton)
	ReputationDetailCloseButton:Point("TOPRIGHT", 3, 4)

	-- Currency
	hooksecurefunc("TokenFrame_Update", function()
		local buttons = TokenFrameContainer.buttons
		if not buttons then return end

		local offset = HybridScrollFrame_GetOffset(TokenFrameContainer)
		local index, name, button, isHeader, isExpanded

		for i = 1, #buttons do
			index = offset + i
			name, isHeader, isExpanded = GetCurrencyListInfo(index)
			button = buttons[i]

			if button and not button.isSkinned then
				button.highlight:Kill()
				button.categoryMiddle:Kill()
				button.categoryLeft:Kill()
				button.categoryRight:Kill()

				button.icon:SetTexCoord(unpack(E.TexCoords))

				button.expandIcon:SetTexture(E.Media.Textures.Plus)
				button.expandIcon:SetTexCoord(0, 1, 0, 1)
				button.expandIcon:Size(16)
				button.expandIcon:Point("LEFT", 4, 1)

				button.isSkinned = true
			end

			if name or name == "" then
				if isHeader then
					if isExpanded then
						button.expandIcon:SetTexture(E.Media.Textures.Minus)
					else
						button.expandIcon:SetTexture(E.Media.Textures.Plus)
					end
					button.expandIcon:SetTexCoord(0, 1, 0, 1)
				end
			end
		end
	end)

	TokenFramePopup:StripTextures()
	TokenFramePopup:SetTemplate("Transparent")
	TokenFramePopup:Point("TOPLEFT", TokenFrame, "TOPRIGHT", 1, 0)

	S:HandleScrollBar(TokenFrameContainerScrollBar)

	S:HandleCheckBox(TokenFramePopupInactiveCheckBox)
	S:HandleCheckBox(TokenFramePopupBackpackCheckBox)

	S:HandleCloseButton(TokenFramePopupCloseButton)
	TokenFramePopupCloseButton:Point("TOPRIGHT", 3, 4)

	-- Pet
	PetModelFrame:CreateBackdrop("Transparent")
	PetModelFrame.backdrop:Point("BOTTOMRIGHT", 2, -4)

	PetModelFrameShadowOverlay:SetInside(PetModelFrame.backdrop)

	S:HandleRotateButton(PetModelFrameRotateLeftButton)
	PetModelFrameRotateLeftButton:Point("TOPLEFT", 2, -2)

	S:HandleRotateButton(PetModelFrameRotateRightButton)
	PetModelFrameRotateRightButton:Point("TOPLEFT", PetModelFrameRotateLeftButton, "TOPRIGHT", 4, 0)

	PetPaperDollPetInfo:CreateBackdrop()
	PetPaperDollPetInfo:SetFrameLevel(PetPaperDollPetInfo:GetFrameLevel() + 2)
	PetPaperDollPetInfo:Point("TOPRIGHT", -3, -3)
	PetPaperDollPetInfo:Size(30)

	local petIcon = PetPaperDollPetInfo:GetRegions()
	petIcon:SetTexture("Interface\\Icons\\Ability_Hunter_BeastTraining")
	petIcon:SetTexCoord(unpack(E.TexCoords))
end

S:AddCallback("Character", LoadSkin)