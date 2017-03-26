local E, L, V, P, G = unpack(select(2, ...));
local S = E:GetModule("Skins");

local _G = _G;
local unpack = unpack;

local function LoadSkin()
	if(E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.stable ~= true) then return; end

	PetStableFrame:StripTextures()
	PetStableFrame:SetTemplate("Transparent")

	PetStableFrameInset:StripTextures()
	PetStableFrameInset:CreateBackdrop("Transparent", true)

	PetStableLeftInset:StripTextures()
	PetStableBottomInset:StripTextures()

	S:HandleCloseButton(PetStableFrameCloseButton)

	S:HandleButton(PetStablePrevPageButton)
	S:HandleButton(PetStableNextPageButton)

	S:HandleRotateButton(PetStableModelRotateRightButton)
	S:HandleRotateButton(PetStableModelRotateLeftButton)

	PetStableDiet:StripTextures()
	PetStableDiet:CreateBackdrop()
	PetStableDiet:Point("TOPRIGHT", -2, -2)

	PetStableDiet.icon = PetStableDiet:CreateTexture(nil, "OVERLAY");
	PetStableDiet.icon:SetTexCoord(unpack(E.TexCoords))
	PetStableDiet.icon:SetAllPoints()
	PetStableDiet.icon:SetTexture("Interface\\Icons\\Ability_Hunter_BeastTraining")

	for i = 1, NUM_PET_ACTIVE_SLOTS do
	   S:HandleItemButton(_G["PetStableActivePet" .. i], true)
	end

	for i = 1, NUM_PET_STABLE_SLOTS do
	   S:HandleItemButton(_G["PetStableStabledPet" .. i], true)
	end

	PetStableSelectedPetIcon:SetTexCoord(unpack(E.TexCoords))
end

S:AddCallback("Stable", LoadSkin);