local E, L, V, P, G = unpack(select(2, ...));
local S = E:GetModule("Skins")

local _G = _G;

local SetDressUpBackground = SetDressUpBackground;

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.dressingroom ~= true then return end

	-- Dressing Room
	DressUpFrame:CreateBackdrop("Transparent");
	DressUpFrame.backdrop:Point("TOPLEFT", 10, -12);
	DressUpFrame.backdrop:Point("BOTTOMRIGHT", -33, 73);

	DressUpFrame:StripTextures();
	DressUpFramePortrait:Kill();

	S:HandleCloseButton(DressUpFrameCloseButton, DressUpFrame.backdrop);

	S:HandleButton(DressUpFrameResetButton);
	DressUpFrameResetButton:Point("RIGHT", DressUpFrameCancelButton, "LEFT", -3, 0);

	S:HandleButton(DressUpFrameCancelButton);
	DressUpFrameCancelButton:Point("CENTER", DressUpFrame, "TOPLEFT", 306, -423);

	DressUpFrameDescriptionText:Point("CENTER", DressUpFrameTitleText, "BOTTOM", -7, -22);

	DressUpModel:CreateBackdrop("Default");
	DressUpModel.backdrop:SetOutside(DressUpBackgroundTopLeft, nil, nil, DressUpModel);

	-- Side Dressing Room
	SideDressUpFrame:StripTextures();
	SideDressUpFrame:CreateBackdrop("Transparent");
	SideDressUpFrame.backdrop:Point("TOPLEFT", 1, 5);
	SideDressUpFrame.backdrop:Point("BOTTOMRIGHT", -4, 3);

	S:HandleButton(SideDressUpModelResetButton);

	if(SideDressUpFrameUndressButton) then
		SideDressUpModelResetButton:Point("BOTTOM", 43, 0);
	else
		SideDressUpModelResetButton:Point("BOTTOM", 0, 0);
	end

	S:HandleCloseButton(SideDressUpModelCloseButton);

	--Model Backgrounds
	hooksecurefunc("SetDressUpBackground", function(frame)
		if(frame.BGTopLeft) then
			frame.BGTopLeft:SetDesaturated(true);
		end
		if(frame.BGTopRight) then
			frame.BGTopRight:SetDesaturated(true);
		end
		if(frame.BGBottomLeft) then
			frame.BGBottomLeft:SetDesaturated(true);
		end
		if(frame.BGBottomRight) then
			frame.BGBottomRight:SetDesaturated(true);
		end
	end)

	-- Control Frame
	DressUpModelControlFrame:StripTextures();
	SideDressUpModelControlFrame:StripTextures();

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
	};

	for i = 1, #controlbuttons do
		S:HandleButton(_G[controlbuttons[i]]);
		_G[controlbuttons[i]]:StyleButton();
		_G[controlbuttons[i].."Bg"]:Hide();
	end
end

S:AddCallback("DressingRoom", LoadSkin);