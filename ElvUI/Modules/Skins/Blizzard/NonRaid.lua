local E, L, V, P, G = unpack(select(2, ...))
local S = E:GetModule("Skins")

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.nonraid ~= true then return end

	local RaidInfoFrame = _G["RaidInfoFrame"]
	RaidInfoFrame:StripTextures(true)
	RaidInfoFrame:SetTemplate("Transparent")
	RaidInfoFrame:ClearAllPoints()
	RaidInfoFrame:Point("TOPLEFT", RaidFrame, "TOPRIGHT", 1, 0)

	RaidInfoInstanceLabel:StripTextures()
	RaidInfoIDLabel:StripTextures()

	local buttons = {
		"RaidFrameConvertToRaidButton",
		"RaidFrameRaidInfoButton",
		"RaidFrameNotInRaidRaidBrowserButton",
		"RaidInfoExtendButton",
		"RaidInfoCancelButton",
		"RaidFrameRaidBrowserButton"
	}

	for i = 1, #buttons do
		if _G[buttons[i]] then
			S:HandleButton(_G[buttons[i]])
		end
	end

	for i = 1, 7 do
		_G["RaidInfoScrollFrameButton"..i]:StyleButton()
	end

	S:HandleCloseButton(RaidInfoCloseButton, RaidInfoFrame)
	RaidInfoCloseButton:Point("TOPRIGHT", 2, 0)

	S:HandleScrollBar(RaidInfoScrollFrameScrollBar)

	S:HandleCheckBox(RaidFrameAllAssistCheckButton)
end

S:AddCallback("RaidInfo", LoadSkin)