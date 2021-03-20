local E, L, V, P, G = unpack(select(2, ...))
local S = E:GetModule("Skins")

local SetDressUpBackground = SetDressUpBackground

local function LoadSkin()
	if not E.private.skins.blizzard.enable or not E.private.skins.blizzard.dressingroom then return end

	-- Dressing Room
	DressUpFrame:StripTextures()
	DressUpFrame:CreateBackdrop("Transparent")
	DressUpFrame.backdrop:Point("TOPLEFT", 10, -12)
	DressUpFrame.backdrop:Point("BOTTOMRIGHT", -33, 73)

	DressUpFramePortrait:Kill()

	S:HandleCloseButton(DressUpFrameCloseButton, DressUpFrame.backdrop)

	S:HandleButton(DressUpFrameResetButton)
	DressUpFrameResetButton:Point("RIGHT", DressUpFrameCancelButton, "LEFT", -3, 0)

	S:HandleButton(DressUpFrameCancelButton)
	DressUpFrameCancelButton:Point("CENTER", DressUpFrame, "TOPLEFT", 306, -423)

	DressUpFrameDescriptionText:Point("CENTER", DressUpFrameTitleText, "BOTTOM", -7, -22)

	DressUpModel:CreateBackdrop()
	DressUpModel.backdrop:SetOutside(DressUpBackgroundTopLeft, nil, nil, DressUpModel)

	-- Side Dressing Room
	SideDressUpFrame:StripTextures()
	SideDressUpFrame:CreateBackdrop("Transparent")
	SideDressUpFrame.backdrop:Point("TOPLEFT", 1, 9)
	SideDressUpFrame.backdrop:Point("BOTTOMRIGHT", -6, 5)

	SideDressUpModel:CreateBackdrop()
	SideDressUpModel.backdrop:Point("BOTTOMRIGHT", 1, -2)

	S:HandleButton(SideDressUpModelResetButton)
	SideDressUpModelResetButton:Point("BOTTOM", 0, 2)

	S:HandleCloseButton(SideDressUpModelCloseButton)
	SideDressUpModelCloseButton:Point("CENTER", SideDressUpFrame, "TOPRIGHT", -18, -2)

	-- Model Backgrounds
	hooksecurefunc("SetDressUpBackground", function(frame)
		if frame.BGTopLeft then
			frame.BGTopLeft:SetDesaturated(true)
		end
		if frame.BGTopRight then
			frame.BGTopRight:SetDesaturated(true)
		end
		if frame.BGBottomLeft then
			frame.BGBottomLeft:SetDesaturated(true)
		end
		if frame.BGBottomRight then
			frame.BGBottomRight:SetDesaturated(true)
		end
	end)

	-- Control Frame
	S:HandleModelControlFrame(DressUpModelControlFrame)
	S:HandleModelControlFrame(SideDressUpModelControlFrame)
end

S:AddCallback("DressingRoom", LoadSkin)