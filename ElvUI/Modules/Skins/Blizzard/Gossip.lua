local E, L, V, P, G = unpack(select(2, ...))
local S = E:GetModule("Skins")

local _G = _G
local select = select
local find, gsub = string.find, string.gsub

local hooksecurefunc = hooksecurefunc

local function LoadSkin()
	if not E.private.skins.blizzard.enable or not E.private.skins.blizzard.gossip then return end

	GossipFrame:StripTextures()
	GossipFrame:SetTemplate("Transparent")

	GossipFrameInset:Kill()
	GossipFramePortrait:Kill()

	GossipFrameNpcNameText:ClearAllPoints()
	GossipFrameNpcNameText:Point("TOP", GossipFrame, 1, -1)

	GossipGreetingText:SetTextColor(1, 1, 1)

	GossipFrameGreetingPanel:StripTextures()

	GossipGreetingScrollFrame:StripTextures()
	GossipGreetingScrollFrame:CreateBackdrop("Transparent")
	GossipGreetingScrollFrame.backdrop:Point("TOPLEFT", 0, 1)
	GossipGreetingScrollFrame.backdrop:Point("BOTTOMRIGHT", 0, -2)
	GossipGreetingScrollFrame:Point("TOPLEFT", 6, -60)

	S:HandleScrollBar(GossipGreetingScrollFrameScrollBar)
	GossipGreetingScrollFrameScrollBar:ClearAllPoints()
	GossipGreetingScrollFrameScrollBar:Point("TOPRIGHT", GossipGreetingScrollFrame, 23, -17)
	GossipGreetingScrollFrameScrollBar:Point("BOTTOMRIGHT", GossipGreetingScrollFrame, 0, 16)

	S:HandleButton(GossipFrameGreetingGoodbyeButton)
	GossipFrameGreetingGoodbyeButton:Point("BOTTOMRIGHT", -78, 21)

	S:HandleCloseButton(GossipFrameCloseButton, GossipFrame.backdrop)

	for i = 1, NUMGOSSIPBUTTONS do
		local button = _G["GossipTitleButton"..i]

		S:HandleButtonHighlight(button)
		button.handledHighlight:SetVertexColor(1, 0.80, 0.10)

		select(3, button:GetRegions()):SetTextColor(1, 1, 1)
	end

	hooksecurefunc("GossipFrameUpdate", function()
		for i = 1, NUMGOSSIPBUTTONS do
			local button = _G["GossipTitleButton"..i]

			if button:GetFontString() then
				local text = button:GetText()

				if text and find(text, "|cff000000") then
					button:SetText(gsub(text, "|cff000000", "|cffFFFF00"))
				end
			end
		end
	end)

	NPCFriendshipStatusBar:StripTextures()
	NPCFriendshipStatusBar:CreateBackdrop()
	NPCFriendshipStatusBar:SetStatusBarTexture(E.media.normTex)
	NPCFriendshipStatusBar:Point("TOPLEFT", 50, -41)
end

S:AddCallback("Gossip", LoadSkin)