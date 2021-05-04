local E, L, V, P, G = unpack(select(2, ...))
local S = E:GetModule("Skins")

local pairs, unpack = pairs, unpack

local C_PetBattles_GetPetType = C_PetBattles.GetPetType
local C_PetBattles_GetNumAuras = C_PetBattles.GetNumAuras
local C_PetBattles_GetAuraInfo = C_PetBattles.GetAuraInfo

local PET_TYPE_SUFFIX = PET_TYPE_SUFFIX
local PET_BATTLE_PAD_INDEX = PET_BATTLE_PAD_INDEX
local LE_BATTLE_PET_ALLY = LE_BATTLE_PET_ALLY

local function SkinPetButton(self, bf, parent)
	if self.isSkinned then return end

	self:CreateBackdrop()
	self.backdrop:SetFrameStrata("LOW")
	self:SetParent(parent)
	self:SetFrameStrata("LOW")
	self:SetNormalTexture("")
	self:StyleButton(nil, nil, true)
	self.pushed:SetInside(self.backdrop)
	self.hover:SetInside(self.backdrop)

	self.SelectedHighlight:SetTexture(1, 1, 1, 0.30)
	self.SelectedHighlight:SetInside(self.backdrop)

	self.Icon:SetTexCoord(unpack(E.TexCoords))
	self.Icon:SetParent(self.backdrop)
	self.Icon:SetDrawLayer("BORDER")

	self.HotKey:SetTextColor(1, 1, 1)
	self.HotKey:FontTemplate(nil, 16, "OUTLINE")

	if self == bf.SwitchPetButton then
		local checked = self:GetCheckedTexture()

		checked:SetTexture(1, 1, 1, 0.3)
		checked:SetInside(self.backdrop)
	end

	self.isSkinned = true
end

local function LoadSkin()
	if not E.private.skins.blizzard.enable or not E.private.skins.blizzard.petbattleui then return end

	local f = PetBattleFrame
	local bf = f.BottomFrame
	local infoBars = {f.ActiveAlly, f.ActiveEnemy}

	f:StripTextures()

	f.TopVersusText:ClearAllPoints()
	f.TopVersusText:Point("TOP", f, "TOP", 0, -42)

	-- Main Frames
	for index, infoBar in pairs(infoBars) do
		infoBar:CreateBackdrop("Transparent")

		infoBar.Border:SetAlpha(0)
		infoBar.Border2:SetAlpha(0)
		infoBar.LevelUnderlay:SetAlpha(0)
		infoBar.BorderFlash:Kill()
		infoBar.HealthBarBG:Kill()
		infoBar.HealthBarFrame:Kill()
		infoBar.healthBarWidth = 300

		infoBar.IconBackdrop = CreateFrame("Frame", nil, infoBar)
		infoBar.IconBackdrop:SetFrameLevel(infoBar:GetFrameLevel() - 1)
		infoBar.IconBackdrop:SetOutside(infoBar.Icon)
		infoBar.IconBackdrop:SetTemplate()

		hooksecurefunc(infoBar.Border, "SetVertexColor", function(_, r, g, b)
			infoBar.IconBackdrop:SetBackdropBorderColor(r, g, b)
		end)

		infoBar.Icon:SetTexCoord(unpack(E.TexCoords))
		infoBar.Icon.SetTexCoord = E.noop

		infoBar.HealthBarBackdrop = CreateFrame("Frame", nil, infoBar)
		infoBar.HealthBarBackdrop:SetFrameLevel(infoBar:GetFrameLevel() - 1)
		infoBar.HealthBarBackdrop:SetTemplate("Transparent")
		infoBar.HealthBarBackdrop:Width(infoBar.healthBarWidth + (E.Border * 2))

		infoBar.ActualHealthBar:ClearAllPoints()
		infoBar.ActualHealthBar:SetTexture(E.media.normTex)
		E:RegisterStatusBar(infoBar.ActualHealthBar)

		infoBar.Name:ClearAllPoints()

		infoBar.FirstAttack = infoBar:CreateTexture(nil, "ARTWORK")
		infoBar.FirstAttack:Size(30)
		infoBar.FirstAttack:SetTexture([[Interface\PetBattles\PetBattle-StatIcons]])

		infoBar.HealthText:ClearAllPoints()
		infoBar.HealthText:Point("CENTER", infoBar.HealthBarBackdrop, "CENTER")

		infoBar.PetTypeFrame = CreateFrame("Frame", nil, infoBar)
		infoBar.PetTypeFrame:Size(30)

		infoBar.PetType:ClearAllPoints()
		infoBar.PetType:SetAllPoints(infoBar.PetTypeFrame)
		infoBar.PetType:SetFrameLevel(infoBar.PetTypeFrame:GetFrameLevel() + 2)
		infoBar.PetType.Background:SetAlpha(0)
		infoBar.PetType.ActiveStatus:SetAlpha(0)

		infoBar.PetType.Icon:SetTexCoord(0, 1, 0, 1)
		infoBar.PetType.Icon:SetInside(infoBar.PetTypeFrame)
		infoBar.PetType.Icon:SetAlpha(0.8)

		infoBar.Level:FontTemplate(nil, 22, "OUTLINE")
		infoBar.Level:SetTextColor(1, 1, 1)
		infoBar.Level:ClearAllPoints()
		infoBar.Level:Point("BOTTOMLEFT", infoBar.Icon, "BOTTOMLEFT", 2, 2)

		if infoBar.SpeedIcon then
			infoBar.SpeedIcon:ClearAllPoints()
			infoBar.SpeedIcon:Point("CENTER")
			infoBar.SpeedIcon:SetAlpha(0)
			infoBar.SpeedUnderlay:SetAlpha(0)
		end

		if index == 1 then
			infoBar.backdrop:Point("TOPLEFT", -7, 0)
			infoBar.backdrop:Point("BOTTOMRIGHT", 115, 0)

			infoBar.HealthBarBackdrop:Point("TOPLEFT", infoBar.ActualHealthBar, "TOPLEFT", -E.Border, E.Border)
			infoBar.HealthBarBackdrop:Point("BOTTOMLEFT", infoBar.ActualHealthBar, "BOTTOMLEFT", -E.Border, -E.Border)

			f.Ally2.iconPoint = infoBar.IconBackdrop
			f.Ally3.iconPoint = infoBar.IconBackdrop

			infoBar.ActualHealthBar:SetVertexColor(0.68, 0.83, 0.45)
			infoBar.ActualHealthBar:Point("BOTTOMLEFT", infoBar.Icon, "BOTTOMRIGHT", 10, 0)

			infoBar.Name:Point("BOTTOMLEFT", infoBar.ActualHealthBar, "TOPLEFT", 0, 10)

			infoBar.PetTypeFrame:Point("BOTTOMRIGHT", infoBar.HealthBarBackdrop, "TOPRIGHT", 0, 4)

			infoBar.FirstAttack:SetTexture(E.Media.Textures.ArrowUp)
			infoBar.FirstAttack:Point("LEFT", infoBar.HealthBarBackdrop, "RIGHT", 5, 0)
			infoBar.FirstAttack:SetRotation(-1.57)
			infoBar.FirstAttack:Size(46)
		else
			infoBar.backdrop:Point("TOPLEFT", -115, 0)
			infoBar.backdrop:Point("BOTTOMRIGHT", 7, 0)

			infoBar.HealthBarBackdrop:Point("TOPRIGHT", infoBar.ActualHealthBar, "TOPRIGHT", E.Border, E.Border)
			infoBar.HealthBarBackdrop:Point("BOTTOMRIGHT", infoBar.ActualHealthBar, "BOTTOMRIGHT", E.Border, -E.Border)

			f.Enemy2.iconPoint = infoBar.IconBackdrop
			f.Enemy3.iconPoint = infoBar.IconBackdrop

			infoBar.ActualHealthBar:SetVertexColor(0.76, 0.12, 0.23)
			infoBar.ActualHealthBar:Point("BOTTOMRIGHT", infoBar.Icon, "BOTTOMLEFT", -10, 0)

			infoBar.Name:Point("BOTTOMRIGHT", infoBar.ActualHealthBar, "TOPRIGHT", 0, 10)

			infoBar.PetTypeFrame:Point("BOTTOMLEFT", infoBar.HealthBarBackdrop, "TOPLEFT", 2, 4)

			infoBar.FirstAttack:SetTexture(E.Media.Textures.ArrowUp)
			infoBar.FirstAttack:Point("RIGHT", infoBar.HealthBarBackdrop, "LEFT", -5, 0)
			infoBar.FirstAttack:SetRotation(1.57)
			infoBar.FirstAttack:Size(46)
		end
	end

	-- Secondary Frames
	for _, infoBar in pairs({f.Ally2, f.Ally3, f.Enemy2, f.Enemy3}) do
		infoBar.BorderAlive:SetAlpha(0)
		infoBar.HealthBarBG:SetAlpha(0)
		infoBar.HealthDivider:SetAlpha(0)

		infoBar:CreateBackdrop()
		infoBar:StyleButton(nil, true)
		infoBar:GetHighlightTexture():SetAllPoints()
		infoBar:Size(50)
		infoBar:ClearAllPoints()

		hooksecurefunc(infoBar.BorderAlive, "SetVertexColor", function(_, r, g, b)
			infoBar.backdrop:SetBackdropBorderColor(r, g, b)
		end)

		infoBar.Icon:SetTexCoord(unpack(E.TexCoords))
		infoBar.Icon.SetTexCoord = E.noop

		infoBar.BorderDead:SetTexture("Interface\\PetBattles\\DeadPetIcon")
		infoBar.BorderDead:SetTexCoord(1, 0, 1, 0)

		infoBar.healthBarWidth = 50

		infoBar.HealthBarBackdrop = CreateFrame("Frame", nil, infoBar)
		infoBar.HealthBarBackdrop:SetTemplate()
		infoBar.HealthBarBackdrop:Size(E.PixelMode and 52 or 54, E.PixelMode and 9 or 11)
		infoBar.HealthBarBackdrop:Point("TOPLEFT", infoBar, "BOTTOMLEFT", -(E.PixelMode and 1 or 2), -(E.PixelMode and 4 or 6))
		infoBar.HealthBarBackdrop:SetFrameLevel(infoBar:GetFrameLevel() - 1)

		infoBar.ActualHealthBar:ClearAllPoints()
		infoBar.ActualHealthBar:Point("TOPLEFT", infoBar.HealthBarBackdrop, "TOPLEFT", E.PixelMode and 1 or 2, E.PixelMode and -1 or -2)
		infoBar.ActualHealthBar:SetTexture(E.media.normTex)
		E:RegisterStatusBar(infoBar.ActualHealthBar)
	end

	f.Ally2:Point("TOPRIGHT", f.Ally2.iconPoint, "TOPLEFT", -15, -2)
	f.Ally3:Point("TOPRIGHT", f.Ally2, "TOPLEFT", -13, 0)

	f.Enemy2:Point("TOPLEFT", f.Enemy2.iconPoint, "TOPRIGHT", 15, -2)
	f.Enemy3:Point("TOPLEFT", f.Enemy2, "TOPRIGHT", 13, 0)

	-- Speed Indicator
	hooksecurefunc("PetBattleFrame_UpdateSpeedIndicators", function()
		if not f.ActiveAlly.SpeedIcon:IsShown() and not f.ActiveEnemy.SpeedIcon:IsShown() then
			f.ActiveAlly.FirstAttack:Hide()
			f.ActiveEnemy.FirstAttack:Hide()

			return
		end

		for _, infoBar in pairs(infoBars) do
			infoBar.FirstAttack:Show()

			if infoBar.SpeedIcon:IsShown() then
				infoBar.FirstAttack:SetVertexColor(0, 1, 0, 1)
			else
				infoBar.FirstAttack:SetVertexColor(0.8, 0, 0.3, 1)
			end
		end
	end)

	-- Pet Type
	hooksecurefunc("PetBattleUnitFrame_UpdatePetType", function(self)
		if self.PetType then
			local petType = C_PetBattles_GetPetType(self.petOwner, self.petIndex)

			if self.PetTypeFrame then
				self.PetType.Icon:SetTexture(E.Media.BattlePetTypes[PET_TYPE_SUFFIX[petType]])
			end
		end
	end)

	-- Auras
	local function SkinAuras(frame)
		if frame.isSkinned then return end

		frame:CreateBackdrop()
		frame.backdrop:SetOutside(frame.Icon)
		frame:SetHitRectInsets(15, 15, -2, 18)

		frame.Icon:SetTexCoord(unpack(E.TexCoords))

		frame.DebuffBorder:SetAlpha(0)

		frame.Duration:FontTemplate(E.media.normFont, 12, "OUTLINE")
		frame.Duration:ClearAllPoints()
		frame.Duration:Point("TOP", frame.Icon, "BOTTOM", 1, -4)

		S:HandleFrameHighlight(frame, frame.backdrop)

		frame.isSkinned = true
	end

	hooksecurefunc("PetBattleAuraHolder_Update", function(self)
		if not self.petOwner or not self.petIndex then return end

		local nextFrame = 1
		for i = 1, C_PetBattles_GetNumAuras(self.petOwner, self.petIndex) do
			local _, _, turnsRemaining, isBuff = C_PetBattles_GetAuraInfo(self.petOwner, self.petIndex, i)

			if (isBuff and self.displayBuffs) or (not isBuff and self.displayDebuffs) then
				local frame = self.frames[nextFrame]

				SkinAuras(frame)

				frame.backdrop:SetBackdropBorderColor(isBuff and 0 or 1, isBuff and 1 or 0, 0)

				if turnsRemaining > 0 then
					frame.Duration:SetText(turnsRemaining)
				end

				nextFrame = nextFrame + 1
			end
		end
	end)

	-- Weather
	PetBattleFrame.WeatherFrame:ClearAllPoints()
	PetBattleFrame.WeatherFrame:Point("TOP", E.UIParent, 0, -15)

	PetBattleFrame.WeatherFrame.Duration:ClearAllPoints()
	PetBattleFrame.WeatherFrame.Duration:Point("TOP", E.UIParent, -1, -10)
	PetBattleFrame.WeatherFrame.Duration:FontTemplate(nil, 20)
	PetBattleFrame.WeatherFrame.Duration:SetTextColor(1, 1, 1)

	PetBattleFrame.WeatherFrame.Name:Hide()
	PetBattleFrame.WeatherFrame.Label:Hide()
	PetBattleFrame.WeatherFrame.DurationShadow:Hide()
	PetBattleFrame.WeatherFrame.Icon:Hide()

	-- Action Bar
	local bar = CreateFrame("Frame", "ElvUIPetBattleActionBar", f)
	bar:Size(382, 72)
	bar:EnableMouse(true)
	bar:SetTemplate("Transparent")
	bar:Point("BOTTOM", E.UIParent, "BOTTOM", 0, 4)
	bar:SetFrameLevel(0)
	bar:SetFrameStrata("BACKGROUND")

	if bar.backdropTexture then
		bar.backdropTexture:SetDrawLayer("BACKGROUND", 0)
	end

	bar:SetScript("OnShow", function(self)
		if not self.initialShow then
			self.initialShow = true
			return
		end

		if self.backdropTexture then
			self.backdropTexture:SetDrawLayer("BACKGROUND", 1)
		end
	end)

	bf:StripTextures()
	bf.TurnTimer:StripTextures()
	bf.TurnTimer.SkipButton:SetParent(bar)
	S:HandleButton(bf.TurnTimer.SkipButton)

	bf.TurnTimer.SkipButton:Width(bar:GetWidth())
	bf.TurnTimer.SkipButton:ClearAllPoints()
	bf.TurnTimer.SkipButton:Point("BOTTOM", bar, "TOP", 0, E.PixelMode and 1 or 3)
	hooksecurefunc(bf.TurnTimer.SkipButton, "SetPoint", function(_, point, _, anchorPoint, xOffset, yOffset)
		if point ~= "BOTTOM" or anchorPoint ~= "TOP" or xOffset ~= 0 or yOffset ~= (E.PixelMode and 1 or 3) then
			bf.TurnTimer.SkipButton:ClearAllPoints()
			bf.TurnTimer.SkipButton:SetPoint("BOTTOM", bar, "TOP", 0, E.PixelMode and 1 or 3)
		end
	end)

	bf.TurnTimer:Size(bf.TurnTimer.SkipButton:GetWidth(), bf.TurnTimer.SkipButton:GetHeight())
	bf.TurnTimer:ClearAllPoints()
	bf.TurnTimer:Point("TOP", E.UIParent, "TOP", 0, -140)
	bf.TurnTimer.TimerText:Point("CENTER")

	bf.FlowFrame:StripTextures()
	bf.Delimiter:StripTextures()
	bf.MicroButtonFrame:Kill()

	bf.xpBar:SetParent(bar)
	bf.xpBar:Width(bar:GetWidth() - (E.Border * 2))
	bf.xpBar:CreateBackdrop("Transparent")
	bf.xpBar:ClearAllPoints()
	bf.xpBar:Point("BOTTOM", bf.TurnTimer.SkipButton, "TOP", 0, E.PixelMode and 2 or 5)
	bf.xpBar:SetScript("OnShow", function(self)
		self:StripTextures()
		self:SetStatusBarTexture(E.media.normTex)
	end)
	E:RegisterStatusBar(bf.xpBar)

	hooksecurefunc("PetBattleFrame_UpdateActionBarLayout", function(self)
		for i = 1, NUM_BATTLE_PET_ABILITIES do
			local button = bf.abilityButtons[i]

			SkinPetButton(button, bf, bar)
			button:ClearAllPoints()

			if i == 1 then
				button:Point("BOTTOMLEFT", 10, 10)
			else
				local previous = bf.abilityButtons[i - 1]
				button:Point("LEFT", previous, "RIGHT", 10, 0)
			end
		end

		bf.SwitchPetButton:ClearAllPoints()
		bf.SwitchPetButton:Point("LEFT", bf.abilityButtons[3], "RIGHT", 10, 0)
		SkinPetButton(bf.SwitchPetButton, bf, bar)

		bf.CatchButton:ClearAllPoints()
		bf.CatchButton:Point("LEFT", bf.SwitchPetButton, "RIGHT", 10, 0)
		SkinPetButton(bf.CatchButton, bf, bar)

		bf.ForfeitButton:ClearAllPoints()
		bf.ForfeitButton:Point("LEFT", bf.CatchButton, "RIGHT", 10, 0)
		SkinPetButton(bf.ForfeitButton, bf, bar)
	end)

	-- Pet Selection
	for i = 1, 3 do
		local pet = bf.PetSelectionFrame["Pet"..i]

		pet:CreateBackdrop()
		pet.backdrop:SetAllPoints(pet.HealthBarBG)

		pet.bg = CreateFrame("Frame", nil, pet)
		pet.bg:CreateBackdrop()
		pet.bg:Point("TOPLEFT", pet.Icon, 0, 0)
		pet.bg:Point("BOTTOMRIGHT", pet.Icon, 0, 0)

		pet.bg2 = CreateFrame("Frame", nil, pet)
		pet.bg2:CreateBackdrop("Transparent")
		pet.bg2:Point("TOPLEFT", pet.Icon, 0, 0)
		pet.bg2:Point("BOTTOMRIGHT", pet.Icon, E.PixelMode and 130 or 131, 0)

		pet.HealthBarBG:SetAlpha(0)
		pet.HealthBarBG:ClearAllPoints()
		pet.HealthBarBG:Point("BOTTOMLEFT", pet.Icon, E.PixelMode and 31 or 32, 0)

		pet.ActualHealthBar:ClearAllPoints()
		pet.ActualHealthBar:Point("BOTTOMLEFT", pet.Icon, E.PixelMode and 31 or 32, 0)
		pet.ActualHealthBar:SetTexture(E.media.normTex)
		E:RegisterStatusBar(pet.ActualHealthBar)

		pet.MouseoverHighlight:SetTexture(1, 1, 1, 0.40)
		pet.MouseoverHighlight:ClearAllPoints()
		pet.MouseoverHighlight:Point("TOPLEFT", pet.Icon, E.PixelMode and 31 or 32, 0)
		pet.MouseoverHighlight:Point("BOTTOMRIGHT", pet.Icon, 131, E.PixelMode and 11 or 12)

		pet.Icon:SetTexCoord(unpack(E.TexCoords))
		pet.Icon.SetTexCoord = E.noop

		pet.Name:ClearAllPoints()
		pet.Name:Point("TOPRIGHT", pet.Icon, "TOPRIGHT", 134, -1)

		pet.HealthText:ClearAllPoints()
		pet.HealthText:Point("CENTER", pet.HealthBarBG, "CENTER", 0, -1)
		pet.HealthText:FontTemplate(nil, 12, "OUTLINE")

		pet.Level:FontTemplate(nil, 12, "OUTLINE")
		pet.Level:SetTextColor(1, 1, 1)

		pet.SelectedTexture:SetTexture(0.1, 0.9, 0.5, 0.20)
		pet.SelectedTexture:ClearAllPoints()
		pet.SelectedTexture:Point("TOPLEFT", pet.Icon, E.PixelMode and 31 or 32, 0)
		pet.SelectedTexture:Point("BOTTOMRIGHT", pet.Icon, 131, E.PixelMode and 11 or 12)

		pet.PetModel:CreateBackdrop("Transparent")
		pet.PetModel:Size(E.PixelMode and 159 or 160, 150)
		pet.PetModel:ClearAllPoints()
		pet.PetModel:Point("TOPLEFT", pet.Icon, 0, E.PixelMode and 154 or 157)

		pet.HealthDivider:SetAlpha(0)
		pet.Framing:SetAlpha(0)
		pet.DeadOverlay:SetAlpha(0)
	end

	hooksecurefunc("PetBattlePetSelectionFrame_Show", function()
		bf.PetSelectionFrame:ClearAllPoints()
		bf.PetSelectionFrame:Point("BOTTOM", bf.xpBar, "TOP", 0, 5)
	end)

	-- Pet Queue Battle Ready
	PetBattleQueueReadyFrame:StripTextures()
	PetBattleQueueReadyFrame:SetTemplate("Transparent")

	S:HandleButton(PetBattleQueueReadyFrame.AcceptButton)
	S:HandleButton(PetBattleQueueReadyFrame.DeclineButton)

	PetBattleQueueReadyFrame.Art:SetTexture([[Interface\PetBattles\PetBattlesQueue]])
end

S:AddCallback("PetBattle", LoadSkin)