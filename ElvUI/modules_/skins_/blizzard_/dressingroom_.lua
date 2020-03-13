local E, L, V, P, G = unpack(select(2, ...))
local S = E:GetModule("Skins")

local _G = _G

local SetDressUpBackground = SetDressUpBackground

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.dressingroom ~= true then return end

	-- Dressing Room
	local DressUpFrame = _G["DressUpFrame"]
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

	DressUpModel:CreateBackdrop("Default")
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

	--Model Backgrounds
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
	DressUpModelControlFrame:StripTextures()
	DressUpModelControlFrame:Size(123, 23)

	SideDressUpModelControlFrame:StripTextures()
	SideDressUpModelControlFrame:Size(123, 23)

	local controlbuttons = {
		"DressUpModelControlFrameZoomInButton",
		"DressUpModelControlFrameZoomOutButton",
		"DressUpModelControlFramePanButton",
		"DressUpModelControlFrameRotateLeftButton",
		"DressUpModelControlFrameRotateRightButton",
		"DressUpModelControlFrameRotateResetButton",
		"SideDressUpModelControlFrameZoomInButton",
		"SideDressUpModelControlFrameZoomOutButton",
		"SideDressUpModelControlFramePanButton",
		"SideDressUpModelControlFrameRotateRightButton",
		"SideDressUpModelControlFrameRotateLeftButton",
		"SideDressUpModelControlFrameRotateResetButton"
	}

	for i = 1, #controlbuttons do
		S:HandleButton(_G[controlbuttons[i]])
		_G[controlbuttons[i].."Bg"]:Hide()
	end

	DressUpModelControlFrameZoomOutButton:Point("LEFT", "DressUpModelControlFrameZoomInButton", "RIGHT", 2, 0)
	DressUpModelControlFramePanButton:Point("LEFT", "DressUpModelControlFrameZoomOutButton", "RIGHT", 2, 0)
	DressUpModelControlFrameRotateRightButton:Point("LEFT", "DressUpModelControlFramePanButton", "RIGHT", 2, 0)
	DressUpModelControlFrameRotateLeftButton:Point("LEFT", "DressUpModelControlFrameRotateRightButton", "RIGHT", 2, 0)
	DressUpModelControlFrameRotateResetButton:Point("LEFT", "DressUpModelControlFrameRotateLeftButton", "RIGHT", 2, 0)

	SideDressUpModelControlFrameZoomOutButton:Point("LEFT", "SideDressUpModelControlFrameZoomInButton", "RIGHT", 2, 0)
	SideDressUpModelControlFramePanButton:Point("LEFT", "SideDressUpModelControlFrameZoomOutButton", "RIGHT", 2, 0)
	SideDressUpModelControlFrameRotateRightButton:Point("LEFT", "SideDressUpModelControlFramePanButton", "RIGHT", 2, 0)
	SideDressUpModelControlFrameRotateLeftButton:Point("LEFT", "SideDressUpModelControlFrameRotateRightButton", "RIGHT", 2, 0)
	SideDressUpModelControlFrameRotateResetButton:Point("LEFT", "SideDressUpModelControlFrameRotateLeftButton", "RIGHT", 2, 0)
end

S:AddCallback("DressingRoom", LoadSkin)