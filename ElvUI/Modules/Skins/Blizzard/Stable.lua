local E, L, V, P, G = unpack(select(2, ...))
local S = E:GetModule("Skins")

local _G = _G
local unpack = unpack

local function LoadSkin()
	if not E.private.skins.blizzard.enable or not E.private.skins.blizzard.stable then return end

	NUM_PET_STABLE_SLOTS = 50
	NUM_PET_STABLE_PAGES = 1

	PetStableFrame:StripTextures()
	PetStableFrame:CreateBackdrop("Transparent")
	PetStableFrame:Size(460, 480)
	PetStableFrame.page = 1

	PetStableFrameInset:StripTextures()
	PetStableFrameInset:Point("BOTTOMRIGHT", -6, 142)

	PetStableLeftInset:StripTextures()

	PetStableModel:CreateBackdrop("Transparent")
	PetStableModel.backdrop:Point("BOTTOMRIGHT", 2, -2)

	PetStableModelShadow:Kill()

	PetStableFrameModelBg:Size(E.PixelMode and 357 or 356, 265)
	PetStableFrameModelBg:Point("TOPLEFT", PetStableFrameInset, E.PixelMode and 3 or 4, -3)

	PetStableNextPageButton:Hide()
	PetStablePrevPageButton:Hide()

	PetStableModelRotateRightButton:Hide()
	PetStableModelRotateLeftButton:Hide()

	PetStablePetInfo:CreateBackdrop()
	PetStablePetInfo.backdrop:SetOutside(PetStableSelectedPetIcon)

	PetStableSelectedPetIcon:SetTexCoord(unpack(E.TexCoords))
	PetStableSelectedPetIcon:Point("TOPLEFT", PetStablePetInfo, 0, E.PixelMode and 2 or 4)

	PetStableDiet:StripTextures()
	PetStableDiet:CreateBackdrop()
	PetStableDiet:Point("TOPRIGHT", E.PixelMode and 43 or 41, E.PixelMode and 2 or 4)
	PetStableDiet:Size(40)

	S:HandleFrameHighlight(PetStableDiet, PetStableDiet.backdrop)

	PetStableDiet.icon = PetStableDiet:CreateTexture(nil, "ARTWORK")
	PetStableDiet.icon:SetTexture([[Interface\Icons\Ability_Hunter_BeastTraining]])
	PetStableDiet.icon:SetTexCoord(unpack(E.TexCoords))
	PetStableDiet.icon:SetInside(PetStableDiet.backdrop)

	PetStableBottomInset:StripTextures()
	PetStableBottomInset:CreateBackdrop()
	PetStableBottomInset.backdrop:Point("TOPLEFT", 4, 42)
	PetStableBottomInset.backdrop:Point("BOTTOMRIGHT", -4, 0)

	S:HandleCloseButton(PetStableFrameCloseButton)

	local function PetButtons(btn)
		local button = _G[btn]
		local icon = _G[btn.."IconTexture"]
		local highlight = button:GetHighlightTexture()

		button:StripTextures()

		if button.Checked then
			button.Checked:SetTexture(1, 1, 1, 0.3)
			button.Checked:SetAllPoints(icon)
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

		button:Size(32)
		button:ClearAllPoints()

		if i ~= 1 and i ~= 11 and i ~= 21 and i ~= 31 and i ~= 41 then
			button:Point("LEFT", _G["PetStableStabledPet"..i - 1], "RIGHT", 3, 0)
		end
	end

	PetStableStabledPet1:Point("TOPLEFT", PetStableBottomInset, 8, 38)
	PetStableStabledPet11:Point("TOPLEFT", PetStableStabledPet1, "BOTTOMLEFT", 0, -3)
	PetStableStabledPet21:Point("TOPLEFT", PetStableStabledPet11, "BOTTOMLEFT", 0, -3)
	PetStableStabledPet31:Point("TOPLEFT", PetStableStabledPet21, "BOTTOMLEFT", 0, -3)
	PetStableStabledPet41:Point("TOPLEFT", PetStableStabledPet31, "BOTTOMLEFT", 0, -3)
end

S:AddCallback("Stable", LoadSkin)