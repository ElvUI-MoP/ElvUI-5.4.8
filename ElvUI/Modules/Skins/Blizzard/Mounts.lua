local E, L, V, P, G = unpack(select(2, ...))
local S = E:GetModule("Skins")

local _G = _G
local unpack = unpack

local C_PetJournal_GetPetStats = C_PetJournal.GetPetStats
local C_PetJournal_GetPetInfoByIndex = C_PetJournal.GetPetInfoByIndex
local C_PetJournal_GetPetInfoByPetID = C_PetJournal.GetPetInfoByPetID
local C_PetJournal_GetPetLoadOutInfo = C_PetJournal.GetPetLoadOutInfo
local C_PetJournal_GetPetInfoBySpeciesID = C_PetJournal.GetPetInfoBySpeciesID

local ITEM_QUALITY_COLORS = ITEM_QUALITY_COLORS
local PET_TYPE_SUFFIX = PET_TYPE_SUFFIX

local function LoadSkin()
	if not E.private.skins.blizzard.enable or not E.private.skins.blizzard.mounts then return end

	PetJournalParent:StripTextures()
	PetJournalParent:SetTemplate("Transparent")

	PetJournalParentPortrait:Hide()

	for i = 1, 2 do
		S:HandleTab(_G["PetJournalParentTab"..i])
	end

	S:HandleCloseButton(PetJournalParentCloseButton)

	-- Mount Journal
	MountJournal:StripTextures()
	MountJournal.LeftInset:StripTextures()
	MountJournal.RightInset:StripTextures()

	MountJournal.MountCount:StripTextures()
	MountJournal.MountCount:SetTemplate("Transparent")
	MountJournal.MountCount:Point("TOPLEFT", 4, -25)

    MountJournal.MountDisplay:CreateBackdrop()
	MountJournal.MountDisplay.backdrop:Point("TOPLEFT", 0, -32)
	MountJournal.MountDisplay.backdrop:Point("BOTTOMRIGHT", 0, 0)

	MountJournal.MountDisplay.ShadowOverlay:SetInside(MountJournal.MountDisplay.backdrop)

	MountJournal.MountDisplay.YesMountsTex:SetInside(MountJournal.MountDisplay.backdrop)
	MountJournal.MountDisplay.YesMountsTex:SetTexCoord(0.01, 0.78, 0, 1)
	MountJournal.MountDisplay.YesMountsTex:SetDesaturated(true)

	MountJournal.MountDisplay.NoMountsTex:SetInside(MountJournal.MountDisplay.backdrop)
	MountJournal.MountDisplay.NoMountsTex:SetDesaturated(true)

	MountJournal.MountDisplay.ModelFrame:ClearAllPoints()
	MountJournal.MountDisplay.ModelFrame:SetInside(MountJournal.MountDisplay.backdrop)
	MountJournal.MountDisplay.ModelFrame:Point("TOPLEFT", MountJournal.MountDisplay.backdrop, 2, -3)
	MountJournal.MountDisplay.ModelFrame:Point("BOTTOMRIGHT", MountJournal.MountDisplay.backdrop, -3, 3)

	S:HandleButton(MountJournalMountButton)
	MountJournalMountButton:ClearAllPoints()
	MountJournalMountButton:Point("BOTTOM", MountJournal.MountDisplay.backdrop, 0, -25)
	MountJournalMountButton:Size(160, 22)

	MountJournal.MountDisplay.Name:ClearAllPoints()
	MountJournal.MountDisplay.Name:Point("TOP", MountJournal.MountDisplay.backdrop, 0, 22)

	MountJournal.MountDisplay.NoMounts:ClearAllPoints()
	MountJournal.MountDisplay.NoMounts:Point("CENTER",  MountJournal.bg)

	MountJournal.MountDisplay.ModelFrame.RotateLeftButton:Kill()
	MountJournal.MountDisplay.ModelFrame.RotateRightButton:Kill()

	S:HandleEditBox(MountJournalSearchBox)
	MountJournalSearchBox:Width(256)
	MountJournalSearchBox:Point("TOPLEFT", MountJournal.LeftInset, 1, -9)

	MountJournalListScrollFrame:StripTextures()
	MountJournalListScrollFrame:CreateBackdrop("Transparent")
	MountJournalListScrollFrame.backdrop:Point("TOPLEFT", -3, 1)
	MountJournalListScrollFrame.backdrop:Point("BOTTOMRIGHT", 0, -2)

	S:HandleScrollBar(MountJournalListScrollFrameScrollBar)
	MountJournalListScrollFrameScrollBar:ClearAllPoints()
	MountJournalListScrollFrameScrollBar:Point("TOPRIGHT", MountJournalListScrollFrame, 23, -15)
	MountJournalListScrollFrameScrollBar:Point("BOTTOMRIGHT", MountJournalListScrollFrame, 0, 14)

	for i = 1, #MountJournal.ListScrollFrame.buttons do
		local button = MountJournal.ListScrollFrame.buttons[i]

		S:HandleItemButton(button)
		button.pushed:SetInside(button.backdrop)

		button.icon:Size(40)

		S:HandleButtonHighlight(button)
		button.handledHighlight:SetInside()

		button.selectedTexture:SetTexture(E.Media.Textures.Highlight)
		button.selectedTexture:SetAlpha(0.35)
		button.selectedTexture:SetInside()
		button.selectedTexture:SetTexCoord(0, 1, 0, 1)

		button.stripe = button:CreateTexture(nil, "BACKGROUND")
		button.stripe:SetTexture(E.Media.Textures.Highlight)
		button.stripe:SetAlpha(0.10)
		button.stripe:SetInside()
	end

	hooksecurefunc("MountJournal_UpdateMountList", function()
		local offset = HybridScrollFrame_GetOffset(MountJournal.ListScrollFrame)
		local buttons = MountJournal.ListScrollFrame.buttons

		for i = 1, #buttons do
			local button = buttons[i]
			local displayIndex = i + offset

			if displayIndex <= #MountJournal.cachedMounts then
				local index = MountJournal.cachedMounts[displayIndex]
				local _, _, _, icon = GetCompanionInfo("MOUNT", index)

				button.icon:SetTexture(icon)
			else
				button.icon:SetTexture()
			end
		end
	end)

	local function ColorSelectedMount()
		local offset = HybridScrollFrame_GetOffset(MountJournal.ListScrollFrame)
		local buttons = MountJournal.ListScrollFrame.buttons

		for i = 1, #buttons do
			local button = buttons[i]

			if button.selectedTexture:IsShown() then
				button.backdrop:SetBackdropBorderColor(unpack(E.media.rgbvaluecolor))
				button.name:SetTextColor(unpack(E.media.rgbvaluecolor))
			else
				button.backdrop:SetBackdropBorderColor(unpack(E.media.bordercolor))
				button.name:SetTextColor(1, 1, 1)
			end

			if (i + offset) % 2 == 1 then
				button.stripe:Show()
			else
				button.stripe:Hide()
			end
		end
	end
	hooksecurefunc("MountJournal_UpdateMountList", ColorSelectedMount)

	MountJournalListScrollFrame:HookScript("OnVerticalScroll", ColorSelectedMount)
	MountJournalListScrollFrame:HookScript("OnMouseWheel", ColorSelectedMount)

	-- Pet Journal
	PetJournalRightInset:StripTextures()
	PetJournalLeftInset:StripTextures()

	PetJournal.PetCount:StripTextures()
	PetJournal.PetCount:SetTemplate("Transparent")
	PetJournal.PetCount:Point("TOPLEFT", 4, -25)

	S:HandleButton(PetJournalSummonButton)

	S:HandleButton(PetJournalFindBattle)
	PetJournalFindBattle:Point("BOTTOMRIGHT", -9, 4)

	PetJournalTutorialButton:Kill()

	S:HandleEditBox(PetJournalSearchBox)
	PetJournalSearchBox:Width(160)
	PetJournalSearchBox:Point("TOPLEFT", PetJournalLeftInset, 1, -9)

	S:HandleButton(PetJournalFilterButton, true)
	PetJournalFilterButton:ClearAllPoints()
	PetJournalFilterButton:Point("RIGHT", PetJournalSearchBox, 97, 0)

	PetJournalFilterButtonText:Point("CENTER")

	PetJournalAchievementStatus:DisableDrawLayer("BACKGROUND")

	S:HandleItemButton(PetJournalHealPetButton, true)
	PetJournalHealPetButton.texture:SetTexture([[Interface\Icons\spell_magic_polymorphrabbit]])

	E:RegisterCooldown(PetJournalHealPetButtonCooldown)

	-- Scroll Frame
	PetJournalListScrollFrame:StripTextures()
	PetJournalListScrollFrame:CreateBackdrop("Transparent")
	PetJournalListScrollFrame.backdrop:Point("TOPLEFT", -3, 1)
	PetJournalListScrollFrame.backdrop:Point("BOTTOMRIGHT", 0, -2)

	S:HandleScrollBar(PetJournalListScrollFrameScrollBar)
	PetJournalListScrollFrameScrollBar:ClearAllPoints()
	PetJournalListScrollFrameScrollBar:Point("TOPRIGHT", PetJournalListScrollFrame, 23, -15)
	PetJournalListScrollFrameScrollBar:Point("BOTTOMRIGHT", PetJournalListScrollFrame, 0, 14)

	for i = 1, #PetJournal.listScroll.buttons do
		local button = PetJournal.listScroll.buttons[i]

		S:HandleItemButton(button)
		button.pushed:SetInside(button.backdrop)

		button.dragButton.levelBG:SetAlpha(0)
		button.dragButton.favorite:SetParent(button.backdrop)

		button.isDead:SetTexture("Interface\\PetBattles\\DeadPetIcon")
		button.isDead:SetParent(button.backdrop)

		button.dragButton.level:SetTextColor(1, 1, 1)
		button.dragButton.level:SetParent(button.backdrop)
		button.dragButton.level:FontTemplate(nil, 12, "OUTLINE")

		button.icon:Size(40)

		S:HandleButtonHighlight(button)
		button.handledHighlight:SetInside()

		button.selectedTexture:SetTexture(E.Media.Textures.Highlight)
		button.selectedTexture:SetAlpha(0.35)
		button.selectedTexture:SetInside()
		button.selectedTexture:SetTexCoord(0, 1, 0, 1)
	end

	local function ColorSelectedPet()
		local petButtons = PetJournal.listScroll.buttons
		local isWild = PetJournal.isWild

		for i = 1, #petButtons do
			local button = petButtons[i]
			local index = button.index
			if not index then break end

			local petID, _, _, customName = C_PetJournal_GetPetInfoByIndex(index, isWild)

			if petID ~= nil then
				local quality = select(5, C_PetJournal_GetPetStats(petID))

				if quality then
					local color = ITEM_QUALITY_COLORS[quality - 1]

					button.selectedTexture:SetVertexColor(color.r, color.g, color.b)
					button.handledHighlight:SetVertexColor(color.r, color.g, color.b)
					button.backdrop:SetBackdropBorderColor(color.r, color.g, color.b)

					if customName then
						button.name:SetTextColor(1, 1, 1)
						button.subName:SetTextColor(color.r, color.g, color.b)
					else
						button.name:SetTextColor(color.r, color.g, color.b)
						button.subName:SetTextColor(1, 1, 1)
					end
				else
					button.selectedTexture:SetVertexColor(1, 1, 1)
					button.handledHighlight:SetVertexColor(1, 1, 1)
					button.name:SetTextColor(1, 1, 1)
					button.subName:SetTextColor(1, 1, 1)
					button.backdrop:SetBackdropBorderColor(unpack(E.media.bordercolor))
				end
			else
				button.selectedTexture:SetVertexColor(1, 1, 1)
				button.handledHighlight:SetVertexColor(1, 1, 1)
				button.name:SetTextColor(0.6, 0.6, 0.6)
				button.subName:SetTextColor(0.6, 0.6, 0.6)
				button.backdrop:SetBackdropBorderColor(unpack(E.media.bordercolor))
			end
		end
	end
	hooksecurefunc("PetJournal_UpdatePetList", ColorSelectedPet)

	PetJournalListScrollFrame:HookScript("OnVerticalScroll", ColorSelectedPet)
	PetJournalListScrollFrame:HookScript("OnMouseWheel", ColorSelectedPet)

	-- Loadout Pets
	PetJournalLoadoutBorder:StripTextures()

	PetJournalLoadoutBorderSlotHeaderText:Point("CENTER", PetJournalLoadoutBorderTop, "TOP", 0, 11)

	for i = 1, 3 do
		local frame = PetJournal.Loadout["Pet"..i]
		local model = _G["PetJournalLoadoutPet"..i.."ModelFrame"]

		frame:Width(405)
		frame:StripTextures()
		frame:SetTemplate("Transparent")
		frame:CreateBackdrop(nil, true)
		frame.backdrop:SetOutside(frame.icon)
		frame.backdrop:SetFrameLevel(frame.backdrop:GetFrameLevel() + 1)

		if i == 1 then
			frame:Point("TOP", 1, 3)
		elseif i == 2 then
			frame:Point("TOP", 1, -108)
		else
			frame:Point("TOP", 1, -219)
		end

		frame.petTypeIcon:Point("BOTTOMLEFT", 6, 12)
		frame.petTypeIcon:SetTexCoord(0, 1, 0, 1)
		frame.petTypeIcon:Size(36)
		frame.petTypeIcon:SetAlpha(0.8)

		frame.icon:SetTexCoord(unpack(E.TexCoords))
		frame.icon:Point("TOPLEFT", 4, -4)

		frame.helpFrame:StripTextures()
		frame.setButton:StripTextures()

		frame.dragButton:SetOutside(frame.icon)
		frame.dragButton:SetFrameLevel(frame.dragButton:GetFrameLevel() + 1)
		frame.dragButton:StyleButton()

		frame.level:FontTemplate(nil, 12, "OUTLINE")
		frame.level:SetTextColor(1, 1, 1)
		frame.levelBG:Point("BOTTOMRIGHT", frame.icon, "BOTTOMRIGHT", 4, -4)

		frame.healthFrame.healthBar:StripTextures()
		frame.healthFrame.healthBar:CreateBackdrop()
		frame.healthFrame.healthBar:SetStatusBarTexture(E.media.normTex)
		E:RegisterStatusBar(frame.healthFrame.healthBar)

		frame.xpBar:StripTextures()
		frame.xpBar:CreateBackdrop()
		frame.xpBar:SetStatusBarTexture(E.media.normTex)
		frame.xpBar:SetFrameLevel(frame.xpBar:GetFrameLevel() + 2)
		frame.xpBar:Width(205)
		E:RegisterStatusBar(frame.xpBar)

		frame.xpBar:Point("TOPLEFT", frame.healthFrame, "BOTTOMLEFT", 0, -8)

		model:Point("TOPRIGHT", -5, -5)

		for j = 1, 3 do
			local button = frame["spell"..j]

			S:HandleItemButton(button)

			button.icon:SetInside(button)
			button.LevelRequirement:FontTemplate(nil, 18)

			button.FlyoutArrow:SetTexture([[Interface\Buttons\ActionBarFlyoutButton]])
		end
	end

	hooksecurefunc("PetJournal_UpdatePetLoadOut", function()
		for i = 1, 3 do
			local petID = C_PetJournal_GetPetLoadOutInfo(i)

			if petID then
				local frame = PetJournal.Loadout["Pet"..i]
				local _, customName, _, _, _, _, _, _, _, petType = C_PetJournal_GetPetInfoByPetID(petID)
				local quality = select(5, C_PetJournal_GetPetStats(petID))

				frame.petTypeIcon:SetTexture(E.Media.BattlePetTypes[PET_TYPE_SUFFIX[petType]])

				if quality then
					local color = ITEM_QUALITY_COLORS[quality - 1]

					if customName then
						frame.name:SetTextColor(1, 1, 1)
						frame.subName:SetTextColor(color.r, color.g, color.b)
					else
						frame.name:SetTextColor(color.r, color.g, color.b)
						frame.subName:SetTextColor(1, 1, 1)
					end

					frame.backdrop:SetBackdropBorderColor(color.r, color.g, color.b)
				else
					frame.name:SetTextColor(1, 1, 1)
					frame.subName:SetTextColor(1, 1, 1)
					frame.backdrop:SetBackdropBorderColor(unpack(E.media.bordercolor))
				end
			end
		end
	end)

	-- Flyout Buttons
	for i = 1, 2 do
		local button = _G["PetJournalSpellSelectSpell"..i]
		local icon = _G["PetJournalSpellSelectSpell"..i.."Icon"]

		S:HandleItemButton(button)

		icon:SetInside(button)
		icon:SetDrawLayer("BORDER")

		button.LevelRequirement:FontTemplate(nil, 18)
	end

	PetJournalSpellSelect:StripTextures()

	-- Pet Card
	PetJournalPetCard:StripTextures()
	PetJournalPetCard:SetTemplate("Transparent")

	PetJournalPetCardInset:StripTextures()

	PetJournalPetCardPetInfo:CreateBackdrop(nil, true)
	PetJournalPetCardPetInfo.backdrop:SetOutside(PetJournalPetCardPetInfo.icon)
	PetJournalPetCardPetInfo:StyleButton()
	PetJournalPetCardPetInfo:Size(40)
	PetJournalPetCardPetInfo:Point("TOPLEFT", 2, -2)

	PetJournalPetCardPetInfo.icon:SetTexCoord(unpack(E.TexCoords))
	PetJournalPetCardPetInfo.icon:SetInside(PetJournalPetCardPetInfo)
	PetJournalPetCardPetInfo.icon:SetParent(PetJournalPetCardPetInfo.backdrop)

	PetJournalPetCardPetInfo.level:FontTemplate(nil, 12, "OUTLINE")
	PetJournalPetCardPetInfo.level:SetTextColor(1, 1, 1)
	PetJournalPetCardPetInfo.level:SetParent(PetJournalPetCardPetInfo.backdrop)

	PetJournalPetCardPetInfo.favorite:SetParent(PetJournalPetCardPetInfo.backdrop)

	PetJournalPetCardPetInfo.levelBG:SetAlpha(0)
	PetJournalPetCardPetInfo.qualityBorder:SetAlpha(0)

	PetJournalPetCardModelFrame:Point("TOPLEFT", 60, -10)

	PetJournalPetCardHealthFrame.healthBar:StripTextures()
	PetJournalPetCardHealthFrame.healthBar:CreateBackdrop()
	PetJournalPetCardHealthFrame.healthBar:SetStatusBarTexture(E.media.normTex)

	PetJournalPetCardXPBar:StripTextures()
	PetJournalPetCardXPBar:CreateBackdrop()
	PetJournalPetCardXPBar:SetStatusBarTexture(E.media.normTex)

	PetJournalPetCardTypeInfoTypeIcon:SetTexCoord(0, 1, 0, 1)
	PetJournalPetCardTypeInfoTypeIcon:SetAlpha(0.8)

	hooksecurefunc("PetJournal_UpdatePetCard", function(self)
		local _, customName, petType

		if self.petID then
			_, customName, _, _, _, _, _, _, _, petType = C_PetJournal_GetPetInfoByPetID(self.petID)
			local quality = select(5, C_PetJournal_GetPetStats(self.petID))

			if quality then
				local color = ITEM_QUALITY_COLORS[quality - 1]

				if customName then
					self.PetInfo.name:SetTextColor(1, 1, 1)
					self.PetInfo.subName:SetTextColor(color.r, color.g, color.b)
				else
					self.PetInfo.name:SetTextColor(color.r, color.g, color.b)
					self.PetInfo.subName:SetTextColor(1, 1, 1)
				end

				self.PetInfo.backdrop:SetBackdropBorderColor(color.r, color.g, color.b)
			else
				self.PetInfo.name:SetTextColor(1, 1, 1)
				self.PetInfo.subName:SetTextColor(1, 1, 1)
				self.PetInfo.backdrop:SetBackdropBorderColor(unpack(E.media.bordercolor))
			end
		else
			self.PetInfo.backdrop:SetBackdropBorderColor(unpack(E.media.bordercolor))
			self.PetInfo.name:SetTextColor(1, 1, 1)

			if self.speciesID then
				petType = select(3, C_PetJournal_GetPetInfoBySpeciesID(self.speciesID))
			else
				return
			end
		end

		self.TypeInfo.typeIcon:SetTexture(E.Media.BattlePetTypes[PET_TYPE_SUFFIX[petType]])
	end)

	for i = 1, 6 do
		local frame = _G["PetJournalPetCardSpell"..i]

		frame:SetFrameLevel(frame:GetFrameLevel() + 2)
		frame:DisableDrawLayer("BACKGROUND")

		frame:CreateBackdrop()
		frame.backdrop:SetAllPoints()

		frame:StyleButton(nil, true)

		frame.icon:SetTexCoord(unpack(E.TexCoords))
		frame.icon:SetInside(frame.backdrop)

		frame.LevelRequirement:FontTemplate(nil, 18)
	end
end

S:AddCallbackForAddon("Blizzard_PetJournal", "PetJournal", LoadSkin)