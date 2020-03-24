local E, L, V, P, G = unpack(select(2, ...))
local S = E:GetModule("Skins")

local _G = _G
local select = select
local find, gsub = string.find, string.gsub

local hooksecurefunc = hooksecurefunc

local function LoadSkin()
	if not E.private.skins.blizzard.enable or not E.private.skins.blizzard.gossip then return end

	-- Item Text Frame
	ItemTextFrame:StripTextures(true)
	ItemTextFrame:SetTemplate("Transparent")

	ItemTextFrameInset:Kill()

	ItemTextPageText:SetTextColor(1, 1, 1)
	ItemTextPageText.SetTextColor = E.noop

	ItemTextCurrentPage:Point("TOP", -10, -35)

	ItemTextScrollFrame:StripTextures()
	ItemTextScrollFrame:Point("TOPRIGHT", -41, -63)
	ItemTextScrollFrame:CreateBackdrop("Transparent")
	ItemTextScrollFrame.backdrop:Point("TOPLEFT", -10, 0)
	ItemTextScrollFrame.backdrop:Point("BOTTOMRIGHT", 10, 0)

	S:HandleScrollBar(ItemTextScrollFrameScrollBar)
	ItemTextScrollFrameScrollBar:ClearAllPoints()
	ItemTextScrollFrameScrollBar:Point("TOPRIGHT", ItemTextScrollFrame, 33, -18)
	ItemTextScrollFrameScrollBar:Point("BOTTOMRIGHT", ItemTextScrollFrame, 0, 18)

	S:HandleNextPrevButton(ItemTextPrevPageButton, nil, nil, true)
	ItemTextPrevPageButton:Point("CENTER", ItemTextFrame, "TOPLEFT", 18, -41)
	ItemTextPrevPageButton:Size(28)

	S:HandleNextPrevButton(ItemTextNextPageButton, nil, nil, true)
	ItemTextNextPageButton:Point("CENTER", ItemTextFrame, "TOPRIGHT", -42, -41)
	ItemTextNextPageButton:Size(28)

	S:HandleCloseButton(ItemTextFrameCloseButton)

	-- Gossip Frame
	GossipFrameGreetingPanel:StripTextures()
	GossipFrame:StripTextures()
	GossipFrame:CreateBackdrop("Transparent")

	GossipFrameInset:Kill()
	GossipFramePortrait:Kill()

	GossipGreetingScrollFrame:StripTextures()

	GossipFrameNpcNameText:ClearAllPoints()
	GossipFrameNpcNameText:Point("TOP", GossipFrame, "TOP", 1, -1)

	GossipGreetingText:SetTextColor(1, 1, 1)

	S:HandleScrollBar(GossipGreetingScrollFrameScrollBar)
	GossipGreetingScrollFrameScrollBar:ClearAllPoints()
	GossipGreetingScrollFrameScrollBar:Point("TOPRIGHT", GossipGreetingScrollFrame, "TOPRIGHT", 24, -18)
	GossipGreetingScrollFrameScrollBar:Point("BOTTOMRIGHT", GossipGreetingScrollFrame, "BOTTOMRIGHT", 0, 18)

	S:HandleButton(GossipFrameGreetingGoodbyeButton)
	GossipFrameGreetingGoodbyeButton:Point("BOTTOMRIGHT", -54, 19)

	S:HandleCloseButton(GossipFrameCloseButton, GossipFrame.backdrop)

	for i = 1, NUMGOSSIPBUTTONS do
		local button = _G["GossipTitleButton"..i]
		local text = select(3, button:GetRegions())

		S:HandleButtonHighlight(button)

		text:SetTextColor(1, 1, 1)
	end

	hooksecurefunc("GossipFrameUpdate", function()
		for i = 1, NUMGOSSIPBUTTONS do
			local button = _G["GossipTitleButton"..i]

			if button:GetFontString() then
				if button:GetText() and find(button:GetText(), "|cff000000") then
					button:SetText(gsub(button:GetText(), "|cff000000", "|cffFFFF00"))
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