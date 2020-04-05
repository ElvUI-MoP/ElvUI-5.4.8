local E, L, V, P, G = unpack(select(2, ...))
local S = E:GetModule("Skins")

local _G = _G

local function LoadSkin()
	if not E.private.skins.blizzard.enable or not E.private.skins.blizzard.nonraid then return end

	RaidInfoInstanceLabel:StripTextures()
	RaidInfoIDLabel:StripTextures()

	RaidInfoFrame:StripTextures(true)
	RaidInfoFrame:SetTemplate("Transparent")
	RaidInfoFrame:ClearAllPoints()
	RaidInfoFrame:Point("TOPLEFT", RaidFrame, "TOPRIGHT", 1, 0)

	S:HandleCheckBox(RaidFrameAllAssistCheckButton)
	RaidFrameAllAssistCheckButton:Point("TOPLEFT", 15, -20)
	RaidFrameAllAssistCheckButtonText:Point("LEFT", RaidFrameAllAssistCheckButton, "RIGHT", 0, -1)

	RaidInfoScrollFrame:CreateBackdrop("Transparent")
	RaidInfoScrollFrame.backdrop:Point("TOPLEFT", -2, 1)
	RaidInfoScrollFrame.backdrop:Point("BOTTOMRIGHT", 0, -2)

	S:HandleScrollBar(RaidInfoScrollFrameScrollBar)
	RaidInfoScrollFrameScrollBar:ClearAllPoints()
	RaidInfoScrollFrameScrollBar:Point("TOPRIGHT", RaidInfoScrollFrame, 26, -15)
	RaidInfoScrollFrameScrollBar:Point("BOTTOMRIGHT", RaidInfoScrollFrame, -1, 14)

	for i = 1, 7 do
		local button = _G["RaidInfoScrollFrameButton"..i]

		S:HandleButtonHighlight(button)
		button.handledHighlight:Point("BOTTOMRIGHT", 21, 1)
	end

	local buttons = {
		"RaidFrameConvertToRaidButton",
		"RaidFrameRaidInfoButton",
		"RaidInfoExtendButton",
		"RaidInfoCancelButton",
		"RaidFrameRaidBrowserButton"
	}

	for i = 1, #buttons do
		S:HandleButton(_G[buttons[i]])
	end

	RaidInfoExtendButton:Point("BOTTOMLEFT", 14, 6)
	RaidInfoCancelButton:Point("BOTTOMRIGHT", -9, 6)

	S:HandleCloseButton(RaidInfoCloseButton, RaidInfoFrame)
end

S:AddCallback("RaidInfo", LoadSkin)