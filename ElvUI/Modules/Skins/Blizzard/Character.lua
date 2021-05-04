local E, L, V, P, G = unpack(select(2, ...))
local S = E:GetModule("Skins")

local _G = _G
local unpack, pairs, select = unpack, pairs, select

local CharacterFrameExpandButton = CharacterFrameExpandButton
local GetFactionInfo = GetFactionInfo
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
	CharacterModelFrame:CreateBackdrop("Transparent")
	CharacterModelFrame.backdrop:Point("TOPLEFT", -1, 1)
	CharacterModelFrame.backdrop:Point("BOTTOMRIGHT", 1, -2)

	-- Re-add the overlay texture which was removed right above via StripTextures
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
		button:SetTemplate()
		button:StyleButton()
		button:SetFrameLevel(PaperDollFrame:GetFrameLevel() + 2)
		button.ignoreTexture:SetTexture([[Interface\PaperDollInfoFrame\UI-GearManager-LeaveItem-Transparent]])

		icon:SetTexCoord(unpack(E.TexCoords))
		icon:SetInside()

		if cooldown then
			E:RegisterCooldown(cooldown)
		end

		-- Equipment Flyout
		if popout then
			popout:StripTextures()
			popout:SetTemplate("Default", true)
			popout:Point(button.verticalFlyout and "TOP" or "LEFT", button, button.verticalFlyout and "BOTTOM" or "RIGHT", button.verticalFlyout and 0 or -5, button.verticalFlyout and 5 or 0)
			popout:Size(button.verticalFlyout and 27 or 11, button.verticalFlyout and 11 or 27)

			popout:HookScript("OnEnter", S.SetModifiedBackdrop)
			popout:HookScript("OnLeave", S.SetOriginalBackdrop)

			popout.icon = popout:CreateTexture(nil, "ARTWORK")
			popout.icon:Size(14)
			popout.icon:Point("CENTER")
			popout.icon:SetTexture(E.Media.Textures.ArrowUp)
			popout.icon:SetRotation(button.verticalFlyout and 3.14 or -1.57)
		end
	end

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

	-- Equipment Flyout
	EquipmentFlyoutFrameHighlight:Kill()

	EquipmentFlyoutFrame.NavigationFrame:StripTextures()
	EquipmentFlyoutFrame.NavigationFrame:SetTemplate("Transparent")
	EquipmentFlyoutFrame.NavigationFrame:Point("TOPLEFT", EquipmentFlyoutFrameButtons, "BOTTOMLEFT", 0, -E.Border - E.Spacing)
	EquipmentFlyoutFrame.NavigationFrame:Point("TOPRIGHT", EquipmentFlyoutFrameButtons, "BOTTOMRIGHT", 0, -E.Border - E.Spacing)

	S:HandleNextPrevButton(EquipmentFlyoutFrame.NavigationFrame.PrevButton)
	S:HandleNextPrevButton(EquipmentFlyoutFrame.NavigationFrame.NextButton)

	hooksecurefunc("EquipmentFlyoutPopoutButton_SetReversed", function(button, isReversed)
		local flyout = button:GetParent()
		if flyout:GetParent() ~= PaperDollItemsFrame then return end

		button.icon:SetRotation(flyout.verticalFlyout and (isReversed and 0 or 3.14) or (isReversed and 1.57 or -1.57))
	end)

	hooksecurefunc("EquipmentFlyout_DisplayButton", function(button)
		if not button.isSkinned then
			button:SetTemplate()
			button:StyleButton()
			button:GetNormalTexture():SetTexture(nil)

			button.icon = _G[button:GetName().."IconTexture"]
			button.icon:SetTexCoord(unpack(E.TexCoords))
			button.icon:SetInside()

			E:RegisterCooldown(button.cooldown)

			button.isSkinned = true
		end

		local location = button.location
		if not location then return end

		if location and location >= EQUIPMENTFLYOUT_FIRST_SPECIAL_LOCATION then
			button:SetBackdropBorderColor(unpack(E.media.bordercolor))
		else
			button:SetBackdropBorderColor(GetItemQualityColor(select(3, GetItemInfo(EquipmentManager_GetItemInfoByLocation(location)))))
		end
	end)

	hooksecurefunc("EquipmentFlyout_Show", function(self)
		local frame = EquipmentFlyoutFrame.buttonFrame

		frame:StripTextures()
		frame:SetTemplate("Transparent")
		frame:Point("TOPLEFT", self.popoutButton, self.verticalFlyout and "BOTTOMLEFT" or "TOPRIGHT", self.verticalFlyout and -10 or 0, self.verticalFlyout and 0 or 10)

		local width, height = frame:GetSize()
		frame:Size(width + 3, height)
	end)

	-- Expand Button
	S:HandleNextPrevButton(CharacterFrameExpandButton)
	CharacterFrameExpandButton:Size(18)

	CharacterFrameExpandButton:SetNormalTexture(E.Media.Textures.ArrowUp)
	CharacterFrameExpandButton.SetNormalTexture = E.noop

	CharacterFrameExpandButton:SetPushedTexture(E.Media.Textures.ArrowUp)
	CharacterFrameExpandButton.SetPushedTexture = E.noop

	CharacterFrameExpandButton:SetDisabledTexture(E.Media.Textures.ArrowUp)
	CharacterFrameExpandButton.SetDisabledTexture = E.noop

	local expandButtonNormal, expandButtonPushed = CharacterFrameExpandButton:GetNormalTexture(), CharacterFrameExpandButton:GetPushedTexture()
	local expandButtonCvar = GetCVar("characterFrameCollapsed") ~= "0"

	expandButtonNormal:SetRotation(expandButtonCvar and -1.57 or 1.57)
	expandButtonPushed:SetRotation(expandButtonCvar and -1.57 or 1.57)

	hooksecurefunc("CharacterFrame_Collapse", function()
		expandButtonNormal:SetRotation(-1.57)
		expandButtonPushed:SetRotation(-1.57)
	end)

	hooksecurefunc("CharacterFrame_Expand", function()
		expandButtonNormal:SetRotation(1.57)
		expandButtonPushed:SetRotation(1.57)
	end)

	-- Control Frame
	S:HandleModelControlFrame(CharacterModelFrameControlFrame)

	-- Titles
	PaperDollTitlesPane:HookScript("OnShow", function()
		for _, object in pairs(PaperDollTitlesPane.buttons) do
			if object.isSkinned then return end

			object:StripTextures()
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

			object.isSkinned = true
		end
	end)

	S:HandleScrollBar(PaperDollTitlesPaneScrollBar)

	-- Equipement Manager
	PaperDollEquipmentManagerPane:StripTextures()

	PaperDollEquipmentManagerPane:HookScript("OnShow", function()
		for _, object in pairs(PaperDollEquipmentManagerPane.buttons) do
			if object.isSkinned then return end

			object.BgTop:SetTexture()
			object.BgBottom:SetTexture()
			object.BgMiddle:SetTexture()

			object:CreateBackdrop()
			object.backdrop:Point("TOPLEFT", object.icon, -1, 1)
			object.backdrop:Point("BOTTOMRIGHT", object.icon, 1, -1)

			object.icon:SetTexCoord(unpack(E.TexCoords))
			object.icon:SetParent(object.backdrop)
			object.icon:Point("LEFT", object, "LEFT", 1, 0)
			object.icon.SetPoint = E.noop
			object.icon:Size(40)
			object.icon.SetSize = E.noop

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

			object.isSkinned = true
		end
	end)

	S:HandleButton(PaperDollEquipmentManagerPaneEquipSet, true)
	PaperDollEquipmentManagerPaneEquipSet:Point("TOPLEFT", PaperDollEquipmentManagerPane, "TOPLEFT", 8, 0)
	PaperDollEquipmentManagerPaneEquipSet:Width(80)

	S:HandleButton(PaperDollEquipmentManagerPaneSaveSet)
	PaperDollEquipmentManagerPaneSaveSet:Point("LEFT", PaperDollEquipmentManagerPaneEquipSet, "RIGHT", 4, 0)
	PaperDollEquipmentManagerPaneSaveSet:Width(80)

	S:HandleScrollBar(PaperDollEquipmentManagerPaneScrollBar)

	-- Equipement Manager Popup
	S:HandleIconSelectionFrame(GearManagerDialogPopup, NUM_GEARSET_ICONS_SHOWN, "GearManagerDialogPopupButton")
	GearManagerDialogPopup:Point("TOPLEFT", PaperDollFrame, "TOPRIGHT", 1, 0)
	GearManagerDialogPopup:Size(282, 246)

	-- Bottom Tabs
	for i = 1, 4 do
		S:HandleTab(_G["CharacterFrameTab"..i])
	end

	-- Character Tabs
	PaperDollSidebarTabs:StripTextures()

	hooksecurefunc("PaperDollFrame_UpdateSidebarTabs", function()
		for i = 1, #PAPERDOLL_SIDEBARS do
			local tab = _G["PaperDollSidebarTab"..i]

			if tab and not tab.isSkinned then
				tab:CreateBackdrop("Default", true)

				tab.Highlight:SetTexture(1, 1, 1, 0.3)
				tab.Highlight:SetInside(tab.backdrop)

				tab.Hider:SetTexture(0, 0, 0, 0.8)
				tab.Hider:SetInside(tab.backdrop)

				tab.TabBg:Kill()

				if i == 1 or i == 2 then
					tab:Point("RIGHT", _G["PaperDollSidebarTab"..i + 1], "LEFT", E.PixelMode and -4 or -8, 0)

					if i == 1 then
						for x = 1, tab:GetNumRegions() do
							local region = select(x, tab:GetRegions())
							region:SetTexCoord(0.16, 0.86, 0.16, 0.86)
							region.SetTexCoord = E.noop
							region:SetInside(tab.backdrop)
						end
					end
				end

				tab.isSkinned = true
			end
		end
	end)

	-- Stat Panels
	CharacterStatsPane:StripTextures()

	S:HandleScrollBar(CharacterStatsPaneScrollBar)

	for i = 1, 7 do
		local frame = _G["CharacterStatsPaneCategory"..i]
		local name = _G["CharacterStatsPaneCategory"..i.."NameText"]
		frame.Toolbar = _G["CharacterStatsPaneCategory"..i.."Toolbar"]

		frame:StripTextures()

		S:HandleButton(frame.Toolbar, nil, nil, true)
		frame.Toolbar.backdrop:SetAllPoints()

		name:ClearAllPoints()
		name:Point("CENTER", frame.Toolbar, "CENTER")
		name:SetParent(frame.Toolbar.backdrop)

		_G["CharacterStatsPaneCategory"..i.."Stat1"]:Point("TOPLEFT", frame, "TOPLEFT", 16, -24)

		_G["CharacterStatsPaneCategory"..i.."ToolbarSortUpArrow"]:Kill()
		_G["CharacterStatsPaneCategory"..i.."ToolbarSortDownArrow"]:Kill()
	end

	hooksecurefunc("PaperDollFrame_ExpandStatCategory", function(frame)
		if not frame.collapsed then frame.Toolbar:SetAlpha(1) end
	end)

	hooksecurefunc("PaperDollFrame_CollapseStatCategory", function(frame)
		if frame.collapsed then frame.Toolbar:SetAlpha(0.3) end
	end)

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
		frame.War:SetTexture([[Interface\Buttons\UI-CheckBox-SwordCheck]])
		frame.War:Size(30)
		frame.War:Point("RIGHT", 32, -5)

		bar:StripTextures()
		bar:CreateBackdrop()
		bar:SetStatusBarTexture(E.media.normTex)
		E:RegisterStatusBar(bar)

		button:SetHighlightTexture(nil)

		button:SetNormalTexture(E.Media.Textures.Minus)
		button.SetNormalTexture = E.noop

		local normal = button:GetNormalTexture()
		normal:Size(16)
		normal:Point("LEFT", 4, 1)
	end

	hooksecurefunc("ReputationFrame_Update", function()
		local factionOffset = FauxScrollFrame_GetOffset(ReputationListScrollFrame)
		local numFactions = GetNumFactions()

		for i = 1, NUM_FACTIONS_DISPLAYED, 1 do
			local factionIndex = factionOffset + i

			if factionIndex <= numFactions then
				local _, _, _, _, _, _, atWarWith, canToggleAtWar, isHeader, isCollapsed = GetFactionInfo(factionIndex)

				_G["ReputationBar"..i.."ExpandOrCollapseButton"]:GetNormalTexture():SetTexture(isCollapsed and E.Media.Textures.Plus or E.Media.Textures.Minus)
				_G["ReputationBar"..i].War:SetShown(atWarWith and canToggleAtWar and not isHeader)
			end
		end
	end)

	-- Reputation Detail Frame
	ReputationDetailFrame:StripTextures()
	ReputationDetailFrame:SetTemplate("Transparent")
	ReputationDetailFrame:Point("TOPLEFT", ReputationFrame, "TOPRIGHT", 1, 0)

	S:HandleCheckBox(ReputationDetailMainScreenCheckBox)
	S:HandleCheckBox(ReputationDetailInactiveCheckBox)
	S:HandleCheckBox(ReputationDetailLFGBonusReputationCheckBox)

	S:HandleCheckBox(ReputationDetailAtWarCheckBox)
	ReputationDetailAtWarCheckBox:SetCheckedTexture([[Interface\Buttons\UI-CheckBox-SwordCheck]])

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

				button:CreateBackdrop()
				button.backdrop:SetOutside(button.icon)

				button.icon:SetTexCoord(unpack(E.TexCoords))
				button.icon:SetParent(button.backdrop)
				button.icon:Size(E.PixelMode and 16 or 12)

				button.stripe:SetTexture(E.Media.Textures.Highlight)
				button.stripe:SetAlpha(0.15)

				button.expandIcon:SetTexture(E.Media.Textures.Plus)
				button.expandIcon:SetTexCoord(0, 1, 0, 1)
				button.expandIcon:Size(16)
				button.expandIcon:Point("LEFT", 4, 1)

				button.isSkinned = true
			end

			button.backdrop:SetShown(not isHeader)

			if (name or name == "") and isHeader then
				button.expandIcon:SetTexture(isExpanded and E.Media.Textures.Minus or E.Media.Textures.Plus)
				button.expandIcon:SetTexCoord(0, 1, 0, 1)
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

	S:HandleFrameHighlight(PetPaperDollPetInfo, PetPaperDollPetInfo.backdrop)

	local petIcon = PetPaperDollPetInfo:GetRegions()
	petIcon:SetTexture([[Interface\Icons\Ability_Hunter_BeastTraining]])
	petIcon:SetTexCoord(unpack(E.TexCoords))
end

S:AddCallback("Character", LoadSkin)