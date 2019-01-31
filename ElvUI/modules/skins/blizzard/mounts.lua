local E, L, V, P, G = unpack(select(2, ...))
local S = E:GetModule("Skins")

local _G = _G
local unpack = unpack

local C_PetJournal_GetPetStats = C_PetJournal.GetPetStats
local C_PetJournal_GetPetInfoByIndex = C_PetJournal.GetPetInfoByIndex
local ITEM_QUALITY_COLORS = ITEM_QUALITY_COLORS

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.mounts ~= true then return end

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
	MountJournal.MountCount:SetTemplate("Default")

    MountJournal.MountDisplay:CreateBackdrop("Default")
    MountJournal.MountDisplay.backdrop:Point("TOPLEFT", 2, -40)
    MountJournal.MountDisplay.backdrop:Point("BOTTOMRIGHT", 1, 30)

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
	MountJournalMountButton:Point("BOTTOM", MountJournal.MountDisplay.backdrop, 0, -30)
	MountJournalMountButton:Size(160, 25)

	MountJournal.bg = CreateFrame("Frame", nil, MountJournal)
	MountJournal.bg:CreateBackdrop("Default", true)
	MountJournal.bg:Point("TOPLEFT", MountJournal.MountDisplay.ModelFrame, E.PixelMode and -1 or 0, E.PixelMode and 43 or 42)
	MountJournal.bg:Point("BOTTOMRIGHT", MountJournal.MountDisplay.ModelFrame, E.PixelMode and 2 or 1, 445)

	MountJournal.MountDisplay.Name:ClearAllPoints()
	MountJournal.MountDisplay.Name:Point("CENTER",  MountJournal.bg)

	MountJournal.MountDisplay.NoMounts:ClearAllPoints()
	MountJournal.MountDisplay.NoMounts:Point("CENTER",  MountJournal.bg)

	MountJournal.MountDisplay.ModelFrame.RotateLeftButton:Kill()
	MountJournal.MountDisplay.ModelFrame.RotateRightButton:Kill()

	S:HandleEditBox(MountJournalSearchBox)

	S:HandleScrollBar(MountJournalListScrollFrameScrollBar)

	for i = 1, #MountJournal.ListScrollFrame.buttons do
		local button = _G["MountJournalListScrollFrameButton"..i]

		S:HandleItemButton(button)

		button.icon:Size(40)
		button.icon:SetTexCoord(unpack(E.TexCoords))

		button.selectedTexture:SetTexture(1, 1, 1, 0.30)
		button.selectedTexture:SetInside()

		button.stripe = button:CreateTexture(nil, "BACKGROUND")
		button.stripe:SetTexture(0.9, 0.9, 1, 0.10)
		button.stripe:SetInside()
	end

	hooksecurefunc("MountJournal_UpdateMountList", function()
		local scrollFrame = MountJournal.ListScrollFrame
		local offset = HybridScrollFrame_GetOffset(scrollFrame)
		local buttons = scrollFrame.buttons
		local showMounts = true

		for i = 1, #buttons do
			local button = buttons[i]
			local displayIndex = i + offset
			if displayIndex <= #MountJournal.cachedMounts and showMounts then
				local index = MountJournal.cachedMounts[displayIndex]
				local _, _, _, icon = GetCompanionInfo("MOUNT", index)

				button.icon:SetTexture(icon)
			else
				button.icon:SetTexture(nil)
			end
		end
	end)

	local function ColorSelectedMount()
		local scrollFrame = MountJournal.ListScrollFrame
		local offset = HybridScrollFrame_GetOffset(scrollFrame)
		for i = 1, #MountJournal.ListScrollFrame.buttons do
			local button = _G["MountJournalListScrollFrameButton"..i]
			local name = _G["MountJournalListScrollFrameButton"..i.."Name"]

			if button.selectedTexture:IsShown() then
				name:SetTextColor(1, 1, 0)
				button.backdrop:SetBackdropBorderColor(1, 1, 0)
			else
				name:SetTextColor(1, 1, 1)
				button.backdrop:SetBackdropBorderColor(unpack(E.media.bordercolor))
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
	PetJournalSummonButton:StripTextures()
	PetJournalFindBattle:StripTextures()
	PetJournalRightInset:StripTextures()
	PetJournalLeftInset:StripTextures()
	PetJournalListScrollFrame:StripTextures()
	PetJournalFilterButton:StripTextures(true)
	PetJournalTutorialButton:Kill()

	PetJournal.PetCount:StripTextures()
	PetJournal.PetCount:SetTemplate("Default")

	S:HandleButton(PetJournalSummonButton)
	S:HandleButton(PetJournalFindBattle)

	S:HandleEditBox(PetJournalSearchBox)

	S:HandleButton(PetJournalFilterButton)
	PetJournalFilterButton:ClearAllPoints()
	PetJournalFilterButton:Point("RIGHT",PetJournalSearchBox, 97, 0)

	PetJournalFilterButtonText:Point("CENTER")

	S:HandleScrollBar(PetJournalListScrollFrameScrollBar)

	for i = 1, #PetJournal.listScroll.buttons do
		local button = _G["PetJournalListScrollFrameButton"..i]

		S:HandleItemButton(button)

		button.dragButton.levelBG:SetAlpha(0)
		button.dragButton.favorite:SetParent(button.backdrop)

		button.dragButton.level:SetTextColor(1, 1, 1)
		button.dragButton.level:SetParent(button.backdrop)
		button.dragButton.level:FontTemplate(nil, 12, "OUTLINE")

		button.icon:Size(40)
		button.icon:SetTexCoord(unpack(E.TexCoords))

		button.selectedTexture:SetTexture(1, 1, 1, 0.30)
		button.selectedTexture:SetInside()
	end

	local function ColorSelectedPet()
		local petButtons = PetJournal.listScroll.buttons
		local isWild = PetJournal.isWild

		for i = 1, #petButtons do
			local index = petButtons[i].index
			if not index then break end

			local button = _G["PetJournalListScrollFrameButton"..i]
			local name = _G["PetJournalListScrollFrameButton"..i.."Name"]
			local petID = C_PetJournal_GetPetInfoByIndex(index, isWild)

			if petID ~= nil then
				local _, _, _, _, rarity = C_PetJournal_GetPetStats(petID)
				if rarity then
					local color = ITEM_QUALITY_COLORS[rarity-1]
					button.backdrop:SetBackdropBorderColor(color.r, color.g, color.b)
					name:SetTextColor(color.r, color.g, color.b)
				else
					button.backdrop:SetBackdropBorderColor(0, 0, 0)
					name:SetTextColor(1, 1, 1)
				end
			else
				button.backdrop:SetBackdropBorderColor(unpack(E.media.bordercolor))
				name:SetTextColor(0.6, 0.6, 0.6)
			end
		end
	end
	hooksecurefunc("PetJournal_UpdatePetList", ColorSelectedPet)

	PetJournalListScrollFrame:HookScript("OnVerticalScroll", ColorSelectedPet)
	PetJournalListScrollFrame:HookScript("OnMouseWheel", ColorSelectedPet)

	PetJournalAchievementStatus:DisableDrawLayer("BACKGROUND")

	S:HandleItemButton(PetJournalHealPetButton, true)
	PetJournalHealPetButton.texture:SetTexture([[Interface\Icons\spell_magic_polymorphrabbit]])
	E:RegisterCooldown(PetJournalHealPetButtonCooldown)

	PetJournalLoadoutBorder:StripTextures()

	PetJournalLoadoutBorderSlotHeaderText:Point("CENTER", PetJournalLoadoutBorderTop, "TOP", 0, 11)

	PetJournalLoadoutPet1:Point("TOP", 1, 3)
	PetJournalLoadoutPet2:Point("TOP", 1, -108)
	PetJournalLoadoutPet3:Point("TOP", 1, -219)

	for i = 1, 3 do
		local loadoutPet = _G["PetJournalLoadoutPet"..i]
		local loadoutPetIcon = _G["PetJournalLoadoutPet"..i.."Icon"]
		local loadoutPetHealth = _G["PetJournalLoadoutPet"..i.."HealthFrame"]
		local loadoutPetXP = _G["PetJournalLoadoutPet"..i.."XPBar"]
		local loadoutPetLevel = _G["PetJournalLoadoutPet"..i.."Level"]

		_G["PetJournalLoadoutPet"..i.."HelpFrame"]:StripTextures()

		loadoutPet:StripTextures()
		loadoutPet:SetTemplate("Transparent")
		loadoutPet:Width(405)

		loadoutPet.hover = true
		loadoutPet.pushed = true
		loadoutPet.checked = true

		S:HandleItemButton(loadoutPet)
		loadoutPet.backdrop:SetFrameLevel(loadoutPet.backdrop:GetFrameLevel() + 1)

		loadoutPet.setButton:StripTextures()
		loadoutPet.petTypeIcon:Point("BOTTOMLEFT", 5, 5)

		loadoutPet.dragButton:SetOutside(loadoutPetIcon)
		loadoutPet.dragButton:SetFrameLevel(loadoutPet.dragButton:GetFrameLevel() + 1)
		loadoutPet.dragButton:StyleButton()

		loadoutPetLevel:FontTemplate(nil, 12, "OUTLINE")
		loadoutPetLevel:SetTextColor(1, 1, 1)
		_G["PetJournalLoadoutPet"..i.."LevelBG"]:Point("BOTTOMRIGHT", loadoutPetIcon, "BOTTOMRIGHT", 4, -4)

		loadoutPetHealth.healthBar:StripTextures()
		loadoutPetHealth.healthBar:CreateBackdrop("Default")
		loadoutPetHealth.healthBar:SetStatusBarTexture(E.media.normTex)
		E:RegisterStatusBar(loadoutPetHealth.healthBar)

		loadoutPetXP:StripTextures()
		loadoutPetXP:CreateBackdrop("Default")	
		loadoutPetXP:SetStatusBarTexture(E.media.normTex)
		loadoutPetXP:SetFrameLevel(loadoutPetXP:GetFrameLevel() + 2)
		E:RegisterStatusBar(loadoutPetXP)

		_G["PetJournalLoadoutPet"..i.."ModelFrame"]:Point("TOPRIGHT", -3, -3)

		for index = 1, 3 do
			local frame = _G["PetJournalLoadoutPet"..i.."Spell"..index]
			S:HandleItemButton(frame)
			frame.FlyoutArrow:SetTexture([[Interface\Buttons\ActionBarFlyoutButton]])
			_G["PetJournalLoadoutPet"..i.."Spell"..index.."Icon"]:SetInside(frame)
		end
	end

	local function ColorLoadoutPets()
		for i = 1, 3 do
			local pet = _G["PetJournalLoadoutPet"..i]
			local petName = _G["PetJournalLoadoutPet"..i.."Name"]
			local subName = _G["PetJournalLoadoutPet"..i.."SubName"]
			local petID = C_PetJournal.GetPetLoadOutInfo(i)

			if petID then
				local _, _, _, _, rarity = C_PetJournal.GetPetStats(petID)

				if rarity then
					local color = ITEM_QUALITY_COLORS[rarity - 1]

					pet.backdrop:SetBackdropBorderColor(color.r, color.g, color.b)
					petName:SetTextColor(color.r, color.g, color.b)
					subName:SetTextColor(color.r, color.g, color.b)
				else
					pet.backdrop:SetBackdropBorderColor(0, 0, 0)
					petName:SetTextColor(1, 1, 1)
					subName:SetTextColor(1, 1, 1)
				end
			end
		end
	end
	hooksecurefunc("PetJournal_UpdatePetLoadOut", ColorLoadoutPets)

	for i = 1, 2 do
		local button = _G["PetJournalSpellSelectSpell"..i]
		local icon = _G["PetJournalSpellSelectSpell"..i.."Icon"]

		S:HandleItemButton(button)

		icon:SetInside(button)
		icon:SetDrawLayer("BORDER")
	end

	PetJournalSpellSelect:StripTextures()

	PetJournalPetCard:StripTextures()
	PetJournalPetCard:SetTemplate("Transparent")

	PetJournalPetCardInset:StripTextures()

	PetJournalPetCardPetInfo:CreateBackdrop()
	PetJournalPetCardPetInfo.backdrop:SetOutside(PetJournalPetCardPetInfoIcon)
	PetJournalPetCardPetInfo:StyleButton()
	PetJournalPetCardPetInfo:Size(40)
	PetJournalPetCardPetInfo:Point("TOPLEFT", 2, -2)

	PetJournalPetCardModelFrame:Point("TOPLEFT", 60, -10)

	PetJournalPetCardPetInfoIcon:SetTexCoord(unpack(E.TexCoords))
	PetJournalPetCardPetInfoIcon:SetInside(PetJournalPetCardPetInfo)
	PetJournalPetCardPetInfoIcon:SetParent(PetJournalPetCardPetInfo.backdrop)

	PetJournalPetCardPetInfo.level:FontTemplate(nil, 12, "OUTLINE")
	PetJournalPetCardPetInfo.level:SetTextColor(1, 1, 1)
	PetJournalPetCardPetInfo.level:SetParent(PetJournalPetCardPetInfo.backdrop)

	PetJournalPetCardPetInfo.favorite:SetParent(PetJournalPetCardPetInfo.backdrop)

	PetJournalPetCardPetInfo.levelBG:SetAlpha(0)
	PetJournalPetCardPetInfo.qualityBorder:SetAlpha(0)

	PetJournalPetCardTypeInfo:Size(65, 40)

	PetJournalPetCardTypeInfoTypeIcon:SetTexCoord(0.200, 0.710, 0.746, 0.917)
	PetJournalPetCardTypeInfoTypeIcon:SetInside(PetJournalPetCardTypeInfo)

	hooksecurefunc(PetJournalPetCardPetInfoQualityBorder, "SetVertexColor", function(_, r, g, b)
		PetJournalPetCardPetInfo.backdrop:SetBackdropBorderColor(r, g, b)
		PetJournalPetCardPetInfo.name:SetTextColor(r, g, b)
	end)

	local tt = PetJournalPrimaryAbilityTooltip

	tt.Background:SetTexture(nil)

	if tt.Delimiter1 then
		tt.Delimiter1:SetTexture(nil)
		tt.Delimiter2:SetTexture(nil)
	end

	tt.BorderTop:SetTexture(nil)
	tt.BorderTopLeft:SetTexture(nil)
	tt.BorderTopRight:SetTexture(nil)
	tt.BorderLeft:SetTexture(nil)
	tt.BorderRight:SetTexture(nil)
	tt.BorderBottom:SetTexture(nil)
	tt.BorderBottomRight:SetTexture(nil)
	tt.BorderBottomLeft:SetTexture(nil)
	tt:SetTemplate("Transparent")

	for i = 1, 6 do
		local frame = _G["PetJournalPetCardSpell"..i]

		frame:SetFrameLevel(frame:GetFrameLevel() + 2)
		frame:DisableDrawLayer("BACKGROUND")

		frame:CreateBackdrop("Default")
		frame.backdrop:SetAllPoints()

		frame:StyleButton(nil, true)

		frame.icon:SetTexCoord(unpack(E.TexCoords))
		frame.icon:SetInside(frame.backdrop)
	end

	PetJournalPetCardHealthFrame.healthBar:StripTextures()
	PetJournalPetCardHealthFrame.healthBar:CreateBackdrop("Default")
	PetJournalPetCardHealthFrame.healthBar:SetStatusBarTexture(E.media.normTex)

	PetJournalPetCardXPBar:StripTextures()
	PetJournalPetCardXPBar:CreateBackdrop("Default")
	PetJournalPetCardXPBar:SetStatusBarTexture(E.media.normTex)
end

S:AddCallbackForAddon("Blizzard_PetJournal", "PetJournal", LoadSkin)