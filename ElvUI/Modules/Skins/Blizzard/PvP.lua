local E, L, V, P, G = unpack(select(2, ...))
local S = E:GetModule("Skins")

local _G = _G
local pairs, unpack = pairs, unpack
local find = string.find

local function LoadSkin()
	if not E.private.skins.blizzard.enable or not E.private.skins.blizzard.pvp then return end

	PVPUIFrame:StripTextures()
	PVPUIFrame:SetTemplate("Transparent")
	PVPUIFrame.LeftInset:StripTextures()
	PVPUIFrame.Shadows:StripTextures()

	S:HandleCloseButton(PVPUIFrameCloseButton)

	-- Side Buttons
	for i = 1, 3 do
		local button = _G["PVPQueueFrameCategoryButton"..i]

		button:SetTemplate("Transparent")
		button:CreateBackdrop()
		button.backdrop:SetOutside(button.Icon)
		button.backdrop:SetFrameLevel(button.backdrop:GetFrameLevel() + 3)
		button:StyleButton()

		button.Icon:Size(58)
		button.Icon:SetTexCoord(0.15, 0.85, 0.15, 0.85)
		button.Icon:Point("LEFT", button, 1, 0)
		button.Icon:SetParent(button.backdrop)

		button.Ring:Kill()
		button.Background:Kill()

		if i == 1 or i == 2 then
			button.bg1 = CreateFrame("Frame", nil, button)
			button.bg1:CreateBackdrop()
			button.bg1:SetAllPoints(button.CurrencyIcon)

			if i == 1 then
				button.CurrencyIcon:SetTexture("Interface\\Icons\\PVPCurrency-Honor-"..E.myfaction)
			else
				button.CurrencyIcon:SetTexture("Interface\\Icons\\PVPCurrency-Conquest-"..E.myfaction)
			end

			button.CurrencyIcon:SetTexCoord(unpack(E.TexCoords))
			button.CurrencyIcon:Size(20)
			button.CurrencyIcon:Point("TOPLEFT", button, "BOTTOMLEFT", 79, 30)

			button.CurrencyAmount:Point("LEFT", button.CurrencyIcon, "RIGHT", 7, 0)
		end
	end

	hooksecurefunc("PVPQueueFrame_SelectButton", function(index)
		for i = 1, 3 do
			local button = PVPQueueFrame["CategoryButton"..i]
			local border = i == index and E.media.rgbvaluecolor or E.media.bordercolor

			button:SetBackdropBorderColor(unpack(border))
			button.backdrop:SetBackdropBorderColor(unpack(border))
		end
	end)

	PVPQueueFrame_ShowFrame()

	-- Honor Frame
	HonorFrame.Inset:StripTextures()
	HonorFrame.RoleInset:StripTextures()

	S:HandleRoleButton(HonorFrame.RoleInset.TankIcon, 44, "Tank")
	S:HandleRoleButton(HonorFrame.RoleInset.HealerIcon, 44, "Healer")
	S:HandleRoleButton(HonorFrame.RoleInset.DPSIcon, 44, "Damager")

	S:HandleDropDownBox(HonorFrameTypeDropDown)
	HonorFrameTypeDropDown:Width(200)
	HonorFrameTypeDropDown:ClearAllPoints()
	HonorFrameTypeDropDown:Point("TOP", HonorFrameSoloQueueButton, "TOP", 130, 322)

	HonorFrame.BonusFrame.DiceButton:DisableDrawLayer("ARTWORK")
	HonorFrame.BonusFrame.DiceButton:SetHighlightTexture("")
	HonorFrame.BonusFrame.DiceButton:ClearAllPoints()
	HonorFrame.BonusFrame.DiceButton:Point("LEFT", HonorFrameTypeDropDown, "RIGHT", -8, 2)

	for i = 1, 2 do
		local button = HonorFrame.BonusFrame["BattlegroundReward"..i]

		button:CreateBackdrop()
		button.backdrop:SetOutside(button.Icon)

		button.Icon:SetTexCoord(unpack(E.TexCoords))
		button.Icon:Size(22)

		if i == 1 then
			button.Icon:Point("LEFT", 28, -4)
		end

		button.Amount:ClearAllPoints()
		button.Amount:Point("LEFT", button.Icon, -29, 0)
	end

	hooksecurefunc("HonorFrameBonusFrame_Update", function()
		local hasData, _, _, _, _, winHonorAmount, winConquestAmount = GetHolidayBGInfo()

		if hasData then
			local rewardIndex = 0
			if winConquestAmount and winConquestAmount > 0 then
				rewardIndex = rewardIndex + 1
				local frame = HonorFrame.BonusFrame["BattlegroundReward"..rewardIndex]
				frame.Icon:SetTexture("Interface\\Icons\\PVPCurrency-Conquest-"..E.myfaction)
			end

			if winHonorAmount and winHonorAmount > 0 then
				rewardIndex = rewardIndex + 1
				local frame = HonorFrame.BonusFrame["BattlegroundReward"..rewardIndex]
				frame.Icon:SetTexture("Interface\\Icons\\PVPCurrency-Honor-"..E.myfaction)
			end
		end
	end)

	S:HandleScrollBar(HonorFrameSpecificFrameScrollBar)
	HonorFrameSpecificFrameScrollBar:ClearAllPoints()
	HonorFrameSpecificFrameScrollBar:Point("TOPRIGHT", HonorFrameSpecificFrame, 22, -15)
	HonorFrameSpecificFrameScrollBar:Point("BOTTOMRIGHT", HonorFrameSpecificFrame, 0, 13)

	S:HandleButton(HonorFrameSoloQueueButton)
	HonorFrameSoloQueueButton:Height(20)
	HonorFrameSoloQueueButton:Point("BOTTOMLEFT", 17, 0)

	S:HandleButton(HonorFrameGroupQueueButton)
	HonorFrameGroupQueueButton:Height(20)
	HonorFrameGroupQueueButton:Point("BOTTOMRIGHT", -19, 0)

	HonorFrame.BonusFrame:StripTextures()
	HonorFrame.BonusFrame.ShadowOverlay:StripTextures()

	HonorFrame.BonusFrame.bg1 = CreateFrame("Frame", nil, HonorFrame.BonusFrame)
	HonorFrame.BonusFrame.bg1:CreateBackdrop("Transparent")
	HonorFrame.BonusFrame.bg1:Point("TOPLEFT", 10, -94)
	HonorFrame.BonusFrame.bg1:Point("BOTTOMRIGHT", -11, 128)

	HonorFrame.BonusFrame.bg2 = CreateFrame("Frame", nil, HonorFrame.BonusFrame)
	HonorFrame.BonusFrame.bg2:CreateBackdrop("Transparent")
	HonorFrame.BonusFrame.bg2:Point("TOPLEFT", 10, -258)
	HonorFrame.BonusFrame.bg2:Point("BOTTOMRIGHT", -11, 6)

	for _, frame in pairs({"RandomBGButton", "CallToArmsButton", "WorldPVP1Button", "WorldPVP2Button"}) do
		local button = HonorFrame.BonusFrame[frame]

		button:StripTextures()
		S:HandleButtonHighlight(button)

		button.SelectedTexture:SetTexture(E.Media.Textures.Highlight)
		button.SelectedTexture:SetVertexColor(0, 0.7, 1, 0.35)
		button.SelectedTexture:SetTexCoord(0, 1, 0, 1)
		button.SelectedTexture:SetAllPoints()
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

	for _, frame in pairs({"ArenaReward", "RatedBGReward"}) do
		local button = ConquestFrame[frame]

		button:CreateBackdrop()
		button.backdrop:SetOutside(button.Icon)

		button.Icon:SetTexCoord(unpack(E.TexCoords))
		button.Icon:Size(22)
		button.Icon:Point("LEFT", -2, -2)

		button.Amount:ClearAllPoints()
		button.Amount:Point("LEFT", button.Icon, -29, 0)
	end

	ConquestFrame.ArenaReward.Icon:SetTexture("Interface\\Icons\\PVPCurrency-Conquest-"..E.myfaction)
	ConquestFrame.RatedBGReward.Icon:SetTexture("Interface\\Icons\\PVPCurrency-Conquest-"..E.myfaction)

	S:HandleButton(ConquestJoinButton)
	ConquestJoinButton:Point("BOTTOM", 0, 7)

	ConquestFrame.bg = CreateFrame("Frame", nil, ConquestFrame)
	ConquestFrame.bg:CreateBackdrop("Transparent")
	ConquestFrame.bg:Point("TOPLEFT", 21, -87)
	ConquestFrame.bg:Point("BOTTOMRIGHT", -18, 148)

	for _, frame in pairs({"RatedBG", "Arena2v2", "Arena3v3", "Arena5v5"}) do
		local button = ConquestFrame[frame]

		button:StripTextures()
		S:HandleButtonHighlight(button)

		button.SelectedTexture:SetTexture(E.Media.Textures.Highlight)
		button.SelectedTexture:SetVertexColor(0, 0.7, 1, 0.35)
		button.SelectedTexture:SetTexCoord(0, 1, 0, 1)
		button.SelectedTexture:SetAllPoints()
	end

	ConquestFrame.RatedBG:CreateBackdrop("Transparent")

	ConquestFrame.Arena3v3:Point("TOP", ConquestFrame.Arena2v2, "BOTTOM", 0, -2)
	ConquestFrame.Arena5v5:Point("TOP", ConquestFrame.Arena3v3, "BOTTOM", 0, -2)

	-- Wargames Frame
	WarGamesFrame:StripTextures()
	WarGamesFrame.RightInset:StripTextures()
	WarGamesFrame.HorizontalBar:StripTextures()

	ConquestTooltip:SetTemplate("Transparent")

	S:HandleButton(WarGameStartButton)
	WarGameStartButton:Point("BOTTOM", 0, 2)

	WarGamesFrameScrollFrame:CreateBackdrop("Transparent")
	WarGamesFrameScrollFrame.backdrop:Point("TOPLEFT", -2, 2)
	WarGamesFrameScrollFrame.backdrop:Point("BOTTOMRIGHT", -5, -4)

	S:HandleScrollBar(WarGamesFrameScrollFrameScrollBar)
	WarGamesFrameScrollFrameScrollBar:ClearAllPoints()
	WarGamesFrameScrollFrameScrollBar:Point("TOPRIGHT", WarGamesFrameScrollFrame, 21, -14)
	WarGamesFrameScrollFrameScrollBar:Point("BOTTOMRIGHT", WarGamesFrameScrollFrame, 0, 12)

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
		button.Header:GetNormalTexture():Size(18)
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
	PVPReadyDialogRoleIcon:Size(60)

	PVPReadyDialogRoleIcon.texture:SetTexCoord(unpack(E.TexCoords))
	PVPReadyDialogRoleIcon.texture.SetTexCoord = E.noop
	PVPReadyDialogRoleIcon.texture:SetInside(PVPReadyDialogRoleIcon.backdrop)
	PVPReadyDialogRoleIcon.texture:SetParent(PVPReadyDialogRoleIcon.backdrop)

	hooksecurefunc("PVPReadyDialog_Display", function(self, _, _, _, queueType, _, role)
		if role == "DAMAGER" then
			self.roleIcon.texture:SetTexture([[Interface\Icons\INV_Knife_1H_Common_B_01]])
		elseif role == "TANK" then
			self.roleIcon.texture:SetTexture([[Interface\Icons\Ability_Defend]])
		elseif role == "HEALER" then
			self.roleIcon.texture:SetTexture([[Interface\Icons\SPELL_NATURE_HEALINGTOUCH]])
		end

		if queueType == "ARENA" then
			self:Height(100)
		end
	end)
end

S:AddCallback("PVP", LoadSecondarySkin)