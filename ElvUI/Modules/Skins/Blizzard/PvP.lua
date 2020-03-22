local E, L, V, P, G = unpack(select(2, ...))
local S = E:GetModule("Skins")

local _G = _G
local pairs, unpack = pairs, unpack
local find = string.find

local function LoadSkin()
	PVPUIFrame:StripTextures()
	PVPUIFrame:SetTemplate("Transparent")
	PVPUIFrame.LeftInset:StripTextures()
	PVPUIFrame.Shadows:StripTextures()

	S:HandleCloseButton(PVPUIFrameCloseButton)

	for i = 1, 3 do
		local button = _G["PVPQueueFrameCategoryButton"..i]

		button:SetTemplate("Transparent")
		button:CreateBackdrop()
		button.backdrop:SetOutside(button.Icon)
		button.backdrop:SetFrameLevel(button.backdrop:GetFrameLevel() + 2)
		button:StyleButton()

		button.Icon:Size(58)
		button.Icon:SetTexCoord(0.15, 0.85, 0.15, 0.85)
		button.Icon:Point("LEFT", button, 1, 0)
		button.Icon:SetParent(button.backdrop)

		button.Ring:Kill()
		button.Background:Kill()
	end

	PVPQueueFrame.CategoryButton1.CurrencyIcon:SetTexture("Interface\\Icons\\PVPCurrency-Honor-"..E.myfaction)
	PVPQueueFrame.CategoryButton1.CurrencyIcon:SetTexCoord(unpack(E.TexCoords))
	PVPQueueFrame.CategoryButton1.CurrencyIcon:Size(20)
	PVPQueueFrame.CategoryButton1.CurrencyIcon:Point("TOPLEFT", PVPQueueFrame.CategoryButton1, "BOTTOMLEFT", 79, 30)

	PVPQueueFrame.CategoryButton1.CurrencyAmount:FontTemplate(nil, 13, "OUTLINE")
	PVPQueueFrame.CategoryButton1.CurrencyAmount:Point("LEFT", PVPQueueFrame.CategoryButton1.CurrencyIcon, "RIGHT", 7, 0)

	PVPQueueFrame.CategoryButton2.CurrencyIcon:SetTexture("Interface\\Icons\\PVPCurrency-Conquest-"..E.myfaction)
	PVPQueueFrame.CategoryButton2.CurrencyIcon:SetTexCoord(unpack(E.TexCoords))
	PVPQueueFrame.CategoryButton2.CurrencyIcon:Size(20)
	PVPQueueFrame.CategoryButton2.CurrencyIcon:Point("TOPLEFT", PVPQueueFrame.CategoryButton2, "BOTTOMLEFT", 79, 30)

	PVPQueueFrame.CategoryButton2.CurrencyAmount:FontTemplate(nil, 13, "OUTLINE")
	PVPQueueFrame.CategoryButton2.CurrencyAmount:Point("LEFT", PVPQueueFrame.CategoryButton2.CurrencyIcon, "RIGHT", 7, 0)

	-- Honor Frame
	S:HandleDropDownBox(HonorFrameTypeDropDown)
	HonorFrameTypeDropDown:Width(200)
	HonorFrameTypeDropDown:ClearAllPoints()
	HonorFrameTypeDropDown:Point("TOP", HonorFrameSoloQueueButton, "TOP", 143, 322)

	HonorFrame.Inset:StripTextures()

	S:HandleScrollBar(HonorFrameSpecificFrameScrollBar)
	HonorFrameSpecificFrameScrollBar:ClearAllPoints()
	HonorFrameSpecificFrameScrollBar:Point("TOPRIGHT", HonorFrameSpecificFrame, 22, -15)
	HonorFrameSpecificFrameScrollBar:Point("BOTTOMRIGHT", HonorFrameSpecificFrame, 0, 13)

	S:HandleButton(HonorFrameSoloQueueButton)
	HonorFrameSoloQueueButton:Point("BOTTOMLEFT", 4, 0)
	HonorFrameSoloQueueButton:Height(20)

	S:HandleButton(HonorFrameGroupQueueButton)
	HonorFrameGroupQueueButton:Point("BOTTOMRIGHT", -31, 0)
	HonorFrameGroupQueueButton:Height(20)

	hooksecurefunc("HonorFrameBonusFrame_Update", function()
		local hasData, _, _, _, _, winHonorAmount, winConquestAmount = GetHolidayBGInfo()

		if hasData then
			local rewardIndex = 0
			if winConquestAmount and winConquestAmount > 0 then
				rewardIndex = rewardIndex + 1
				local frame = HonorFrame.BonusFrame["BattlegroundReward"..rewardIndex]
				frame.Icon:SetTexture("Interface\\Icons\\PVPCurrency-Conquest-"..E.myfaction)
				frame.Icon:SetTexCoord(unpack(E.TexCoords))
				frame.Icon:Size(18)
				frame.Icon:Point("LEFT", 0, 0)

				frame.Amount:FontTemplate(nil, 13)
				frame.Amount:ClearAllPoints()
				frame.Amount:Point("LEFT", frame.Icon, -25, 0)
			end

			if winHonorAmount and winHonorAmount > 0 then
				rewardIndex = rewardIndex + 1
				local frame = HonorFrame.BonusFrame["BattlegroundReward"..rewardIndex]
				frame.Icon:SetTexture("Interface\\Icons\\PVPCurrency-Honor-"..E.myfaction)
				frame.Icon:SetTexCoord(unpack(E.TexCoords))
				frame.Icon:Size(18)

				frame.Amount:FontTemplate(nil, 13)
				frame.Amount:ClearAllPoints()
				frame.Amount:Point("LEFT", frame.Icon, -25, 0)
			end
		end
	end)

	HonorFrame.BonusFrame:StripTextures()
	HonorFrame.BonusFrame.ShadowOverlay:StripTextures()
	HonorFrame.BonusFrame.RandomBGButton:StripTextures()
	HonorFrame.BonusFrame.RandomBGButton:SetTemplate()
	HonorFrame.BonusFrame.RandomBGButton:StyleButton(nil, true)
	HonorFrame.BonusFrame.RandomBGButton.SelectedTexture:SetInside()
	HonorFrame.BonusFrame.RandomBGButton.SelectedTexture:SetTexture(0, 0.7, 1, 0.20)

	HonorFrame.BonusFrame.CallToArmsButton:StripTextures()
	HonorFrame.BonusFrame.CallToArmsButton:SetTemplate()
	HonorFrame.BonusFrame.CallToArmsButton:StyleButton(nil, true)
	HonorFrame.BonusFrame.CallToArmsButton.SelectedTexture:SetInside()
	HonorFrame.BonusFrame.CallToArmsButton.SelectedTexture:SetTexture(0, 0.7, 1, 0.20)

	HonorFrame.BonusFrame.DiceButton:DisableDrawLayer("ARTWORK")
	HonorFrame.BonusFrame.DiceButton:SetHighlightTexture("")

	HonorFrame.RoleInset:StripTextures()

	local honorFrameRoleIcons = {
		HonorFrame.RoleInset.DPSIcon,
		HonorFrame.RoleInset.TankIcon,
		HonorFrame.RoleInset.HealerIcon
	}

	for i = 1, #honorFrameRoleIcons do
		S:HandleCheckBox(honorFrameRoleIcons[i].checkButton, true)

		honorFrameRoleIcons[i]:StripTextures()
		honorFrameRoleIcons[i]:CreateBackdrop()
		honorFrameRoleIcons[i]:Size(50)
 
		honorFrameRoleIcons[i]:GetNormalTexture():SetTexCoord(unpack(E.TexCoords))
		honorFrameRoleIcons[i]:GetNormalTexture():SetInside(honorFrameRoleIcons[i].backdrop)
	end

	HonorFrame.RoleInset.TankIcon:SetNormalTexture("Interface\\Icons\\Ability_Defend")
	HonorFrame.RoleInset.HealerIcon:SetNormalTexture("Interface\\Icons\\SPELL_NATURE_HEALINGTOUCH")
	HonorFrame.RoleInset.DPSIcon:SetNormalTexture("Interface\\Icons\\INV_Knife_1H_Common_B_01")

	for i = 1, 2 do
		local button = HonorFrame.BonusFrame["WorldPVP"..i.."Button"]

		button:StripTextures()
		button:SetTemplate()
		button:StyleButton(nil, true)
		button.SelectedTexture:SetInside()
		button.SelectedTexture:SetTexture(0, 0.7, 1, 0.20)
	end

	HonorFrameSpecificFrame:CreateBackdrop("Transparent")
	HonorFrameSpecificFrame.backdrop:Point("TOPLEFT", -3, 1)
	HonorFrameSpecificFrame.backdrop:Point("BOTTOMRIGHT", -5, -3)

	for i = 1, 9 do
		local button = _G["HonorFrameSpecificFrameButton"..i]

		button:StripTextures()
		button:CreateBackdrop()
		button.backdrop:SetOutside(button.Icon)
		button:Width(300)

		S:HandleButtonHighlight(button)
		button.handledHighlight:SetInside()

		button.SelectedTexture:SetTexture(E.Media.Textures.Highlight)
		button.SelectedTexture:SetVertexColor(0, 0.7, 1, 0.35)
		button.SelectedTexture:SetInside()
		button.SelectedTexture:SetTexCoord(0, 1, 0, 1)

		button.Icon:Point("TOPLEFT", E.PixelMode and 3 or 5, E.PixelMode and -2 or -3)
		button.Icon:Size(E.PixelMode and 36 or 32)
		button.Icon:SetParent(button.backdrop)
	end

	-- Conquest Frame
	ConquestFrame.Inset:StripTextures()
	ConquestFrame:StripTextures()
	ConquestFrame.ShadowOverlay:StripTextures()

	ConquestFrame.NoSeason:StripTextures()
	ConquestFrame.NoSeason:CreateBackdrop()
	ConquestFrame.NoSeason:Point("BOTTOMRIGHT", E.PixelMode and 0 or -1, E.PixelMode and 5 or 6)

	ConquestPointsBar:StripTextures()
	ConquestPointsBar:CreateBackdrop()
	ConquestPointsBar.backdrop:Point("TOPLEFT", ConquestPointsBar.progress, "TOPLEFT", -1, 1)
	ConquestPointsBar.backdrop:Point("BOTTOMRIGHT", ConquestPointsBar, "BOTTOMRIGHT", 1, 2)
	ConquestPointsBar.progress:SetTexture(E.media.normTex)
	E:RegisterStatusBar(ConquestPointsBar.progress)

	ConquestFrame.ArenaReward.Icon:SetTexture("Interface\\Icons\\PVPCurrency-Conquest-"..E.myfaction)
	ConquestFrame.ArenaReward.Icon:SetTexCoord(unpack(E.TexCoords))
	ConquestFrame.ArenaReward.Icon:Size(18)
	ConquestFrame.ArenaReward.Amount:FontTemplate(nil, 14)
	ConquestFrame.ArenaReward.Amount:ClearAllPoints()
	ConquestFrame.ArenaReward.Amount:Point("LEFT", ConquestFrame.ArenaReward.Icon, -27, 0)

	ConquestFrame.RatedBGReward.Icon:SetTexture("Interface\\Icons\\PVPCurrency-Conquest-"..E.myfaction)
	ConquestFrame.RatedBGReward.Icon:SetTexCoord(unpack(E.TexCoords))
	ConquestFrame.RatedBGReward.Icon:Size(18)
	ConquestFrame.RatedBGReward.Amount:FontTemplate(nil, 14)
	ConquestFrame.RatedBGReward.Amount:ClearAllPoints()
	ConquestFrame.RatedBGReward.Amount:Point("LEFT", ConquestFrame.RatedBGReward.Icon, -27, 0)

	S:HandleButton(ConquestJoinButton)
	ConquestJoinButton:Point("BOTTOM", 0, 8)

	local function handleButton(button)
		button:StripTextures()
		button:SetTemplate()
		button:StyleButton(nil, true)
		button.SelectedTexture:SetInside()
		button.SelectedTexture:SetTexture(0, 0.7, 1, 0.20)
	end

	handleButton(ConquestFrame.RatedBG)
	handleButton(ConquestFrame.Arena2v2)
	handleButton(ConquestFrame.Arena3v3)
	handleButton(ConquestFrame.Arena5v5)

	ConquestFrame.Arena3v3:Point("TOP", ConquestFrame.Arena2v2, "BOTTOM", 0, -2)
	ConquestFrame.Arena5v5:Point("TOP", ConquestFrame.Arena3v3, "BOTTOM", 0, -2)

	-- Wargames Frame
	WarGamesFrame:StripTextures()
	WarGamesFrame.RightInset:StripTextures()
	WarGamesFrame.HorizontalBar:StripTextures()

	ConquestTooltip:SetTemplate("Transparent")

	S:HandleButton(WarGameStartButton)
	S:HandleScrollBar(WarGamesFrameScrollFrameScrollBar)

	WarGamesFrameScrollFrame:CreateBackdrop("Transparent")
	WarGamesFrameScrollFrame.backdrop:Point("TOPLEFT", -2, 2)
	WarGamesFrameScrollFrame.backdrop:Point("BOTTOMRIGHT", -5, -4)

	for i = 1, 8 do
		local button = _G["WarGamesFrameScrollFrameButton"..i]

		button.Entry:StripTextures()
		button.Entry:CreateBackdrop()
		button.Entry.backdrop:SetOutside(button.Entry.Icon)
		button.Entry:Width(300)

		S:HandleButtonHighlight(button.Entry)
		button.Entry.handledHighlight:SetInside()

		button.Entry.SelectedTexture:SetTexture(E.Media.Textures.Highlight)
		button.Entry.SelectedTexture:SetVertexColor(0, 0.7, 1, 0.35)
		button.Entry.SelectedTexture:SetInside()
		button.Entry.SelectedTexture:SetTexCoord(0, 1, 0, 1)

		button.Entry.Icon:Point("TOPLEFT", E.PixelMode and 2 or 5, -(E.PixelMode and 2 or 4))
		button.Entry.Icon:Size(E.PixelMode and 36 or 32)
		button.Entry.Icon:SetParent(button.Entry.backdrop)

		button.Header:SetNormalTexture(E.Media.Textures.Plus)
		button.Header.SetNormalTexture = E.noop
		button.Header:GetNormalTexture():Size(14)
		button.Header:GetNormalTexture():Point("LEFT", 3, 0)

		button.Header:SetHighlightTexture("")
		button.Header.SetHighlightTexture = E.noop

		hooksecurefunc(button.Header, "SetNormalTexture", function(self, texture)
			local normal = self:GetNormalTexture()

			if find(texture, "MinusButton") then
				normal:SetTexture(E.Media.Textures.Minus)
			elseif find(texture, "PlusButton") then
				normal:SetTexture(E.Media.Textures.Plus)
			end
		end)
	end
end

S:AddCallbackForAddon("Blizzard_PVPUI", "PVPUI", LoadSkin)

local function LoadSecondarySkin()
	if not E.private.skins.blizzard.enable or not E.private.skins.blizzard.pvp then return end

	-- PvP Ready Dialog
	PVPReadyDialog:StripTextures()
	PVPReadyDialog:SetTemplate("Transparent")

	PVPReadyDialog.SetBackdrop = E.noop
	PVPReadyDialog.filigree:SetAlpha(0)
	PVPReadyDialog.bottomArt:SetAlpha(0)

	PVPReadyDialogBackground:Kill()

	S:HandleButton(PVPReadyDialogEnterBattleButton)
	S:HandleButton(PVPReadyDialogLeaveQueueButton)

	S:HandleCloseButton(PVPReadyDialogCloseButton)

	PVPReadyDialogRoleIcon:StripTextures()
	PVPReadyDialogRoleIcon:CreateBackdrop()
	PVPReadyDialogRoleIcon.backdrop:Point("TOPLEFT", 7, -7)
	PVPReadyDialogRoleIcon.backdrop:Point("BOTTOMRIGHT", -7, 7)

	hooksecurefunc("PVPReadyDialog_Display", function(self, _, _, _, queueType, _, role)
		if role == "DAMAGER" then
			self.roleIcon.texture:SetTexture("Interface\\Icons\\INV_Knife_1H_Common_B_01")
		elseif role == "TANK" then
			self.roleIcon.texture:SetTexture("Interface\\Icons\\Ability_Defend")
		elseif role == "HEALER" then
			self.roleIcon.texture:SetTexture("Interface\\Icons\\SPELL_NATURE_HEALINGTOUCH")
		end

		self.roleIcon.texture:SetTexCoord(unpack(E.TexCoords))
		self.roleIcon.texture:SetInside(self.roleIcon.backdrop)
		self.roleIcon.texture:SetParent(self.roleIcon.backdrop)

		if queueType == "ARENA" then
			self:Height(100)
		end
	end)
end

S:AddCallback("PVP", LoadSecondarySkin)