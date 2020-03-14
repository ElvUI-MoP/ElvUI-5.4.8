local E, L, V, P, G = unpack(select(2, ...))
local S = E:GetModule("Skins")

local _G = _G

local function LoadSkin()
	if not E.private.skins.blizzard.enable or not E.private.skins.blizzard.petition then return end

	PetitionFrame:StripTextures(true)
	PetitionFrame:SetTemplate("Transparent")

	PetitionFrameInset:Kill()

	S:HandleButton(PetitionFrameSignButton)
	S:HandleButton(PetitionFrameRequestButton)
	S:HandleButton(PetitionFrameRenameButton)
	S:HandleButton(PetitionFrameCancelButton)
	S:HandleCloseButton(PetitionFrameCloseButton)

	PetitionFrameCharterTitle:SetTextColor(1, 0.80, 0.10)
	PetitionFrameCharterName:SetTextColor(1, 1, 1)
	PetitionFrameMasterTitle:SetTextColor(1, 0.80, 0.10)
	PetitionFrameMasterName:SetTextColor(1, 1, 1)
	PetitionFrameMemberTitle:SetTextColor(1, 0.80, 0.10)

	for i = 1, 9 do
		_G["PetitionFrameMemberName"..i]:SetTextColor(1, 1, 1)
	end

	PetitionFrameInstructions:SetTextColor(1, 1, 1)

	PetitionFrameRenameButton:Point("LEFT", PetitionFrameRequestButton, "RIGHT", 3, 0)
	PetitionFrameRenameButton:Point("RIGHT", PetitionFrameCancelButton, "LEFT", -3, 0)
end

S:AddCallback("Petition", LoadSkin)