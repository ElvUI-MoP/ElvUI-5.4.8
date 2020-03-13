local E, L, V, P, G = unpack(select(2, ...))
local S = E:GetModule("Skins")

local _G = _G
local unpack = unpack

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.stable ~= true then return end

	NUM_PET_STABLE_SLOTS = 50
	NUM_PET_STABLE_PAGES = 1

	local PetStableFrame = _G["PetStableFrame"]
	PetStableFrame:StripTextures()
	PetStableFrame:CreateBackdrop("Transparent")
	PetStableFrame:Size(460, 480)
	PetStableFrame.page = 1

	PetStableFrameInset:StripTextures()
	PetStableFrameInset:Point("BOTTOMRIGHT", -6, 142)

	PetStableLeftInset:StripTextures()

	PetStableModel:CreateBackdrop("Transparent")

	PetStableModelShadow:Kill()

	PetStableFrameModelBg:Size(358, 265)

	PetStableNextPageButton:Hide()
	PetStablePrevPageButton:Hide()

	PetStableModelRotateRightButton:Hide()
	PetStableModelRotateLeftButton:Hide()

	PetStablePetInfo:CreateBackdrop()
	PetStablePetInfo.backdrop:SetOutside(PetStableSelectedPetIcon)

	PetStableSelectedPetIcon:SetTexCoord(unpack(E.TexCoords))
	PetStableSelectedPetIcon:Point("TOPLEFT", PetStablePetInfo, "TOPLEFT", 0, 2)

	PetStableDiet:StripTextures()
	PetStableDiet:CreateBackdrop()
	PetStableDiet:Point("TOPRIGHT", 42, 2)
	PetStableDiet:Size(40)

	PetStableDiet.icon = PetStableDiet:CreateTexture(nil, "OVERLAY")
	PetStableDiet.icon:SetTexture("Interface\\Icons\\Ability_Hunter_BeastTraining")
	PetStableDiet.icon:SetTexCoord(unpack(E.TexCoords))
	PetStableDiet.icon:SetInside(PetStableDiet.backdrop)

	PetStableBottomInset:StripTextures()
	PetStableBottomInset:CreateBackdrop("Default")
	PetStableBottomInset.backdrop:Point("TOPLEFT", 4, 40)
	PetStableBottomInset.backdrop:Point("BOTTOMRIGHT", -4, 6)

	S:HandleCloseButton(PetStableFrameCloseButton)

	local function PetButtons(btn)
		local button = _G[btn]
		local icon = _G[btn.."IconTexture"]
		local highlight = button:GetHighlightTexture()

		button:StripTextures()

		if button.Checked then
			button.Checked:SetTexture(unpack(E.media.rgbvaluecolor))
			button.Checked:SetAllPoints(icon)
			button.Checked:SetAlpha(0.3)
		end

		if highlight then
			highlight:SetTexture(1, 1, 1, 0.3)
			highlight:SetAllPoints(icon)
		end

		if icon then
			icon:SetTexCoord(unpack(E.TexCoords))
			icon:ClearAllPoints()
			icon:Point("TOPLEFT", E.PixelMode and 1 or 2, -(E.PixelMode and 1 or 2))
			icon:Point("BOTTOMRIGHT", -(E.PixelMode and 1 or 2), E.PixelMode and 1 or 2)

			button:SetFrameLevel(button:GetFrameLevel() + 2)
			if not button.backdrop then
				button:CreateBackdrop("Default", true)
				button.backdrop:SetAllPoints()
			end
		end
	end

	for i = 1, NUM_PET_ACTIVE_SLOTS do
		PetButtons("PetStableActivePet"..i)
	end

	for i = 11, 50 do 
		if not _G["PetStableStabledPet"..i] then
			CreateFrame("Button", "PetStableStabledPet"..i, PetStableFrame, "PetStableSlotTemplate", i)
		end
	end

	for i = 1, NUM_PET_STABLE_SLOTS do
		local button = _G["PetStableStabledPet"..i]

		PetButtons("PetStableStabledPet"..i)

		if i > 1 then
			button:ClearAllPoints()
			button:Point("LEFT", _G["PetStableStabledPet"..i - 1], "RIGHT", 7, 0)
		end

		button:Size(28)
	end

	PetStableStabledPet1:ClearAllPoints()
	PetStableStabledPet1:Point("TOPLEFT", PetStableBottomInset, 10, 34)

	PetStableStabledPet11:ClearAllPoints()
	PetStableStabledPet11:Point("TOPLEFT", PetStableStabledPet1, "BOTTOMLEFT", 0, -5)

	PetStableStabledPet21:ClearAllPoints()
	PetStableStabledPet21:Point("TOPLEFT", PetStableStabledPet11, "BOTTOMLEFT", 0, -5)

	PetStableStabledPet31:ClearAllPoints()
	PetStableStabledPet31:Point("TOPLEFT", PetStableStabledPet21, "BOTTOMLEFT", 0, -5)

	PetStableStabledPet41:ClearAllPoints()
	PetStableStabledPet41:Point("TOPLEFT", PetStableStabledPet31, "BOTTOMLEFT", 0, -5)
end

S:AddCallback("Stable", LoadSkin)