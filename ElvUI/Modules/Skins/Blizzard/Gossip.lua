local E, L, V, P, G = unpack(select(2, ...))
local S = E:GetModule("Skins")

local _G = _G
local select = select
local find, gsub = string.find, string.gsub

local hooksecurefunc = hooksecurefunc

local function LoadSkin()
	if not E.private.skins.blizzard.enable or not E.private.skins.blizzard.gossip then return end

	-- Item Text Frame
	ItemTextScrollFrame:StripTextures()

	ItemTextFrame:StripTextures(true)
	ItemTextFrame:SetTemplate("Transparent")

	ItemTextFrameInset:Kill()

	ItemTextPageText:SetTextColor(1, 1, 1)
	ItemTextPageText.SetTextColor = E.noop

	ItemTextPageText:EnableMouseWheel(true)
	ItemTextPageText:SetScript("OnMouseWheel", function(_, value)
		if value > 0 then
			if ItemTextPrevPageButton:IsShown() and ItemTextPrevPageButton:IsEnabled() == 1 then
				ItemTextPrevPage()
			end
		else
			if ItemTextNextPageButton:IsShown() and ItemTextNextPageButton:IsEnabled() == 1 then
				ItemTextNextPage()
			end
		end
	end)

	ItemTextCurrentPage:Point("TOP", 0, -35)

	S:HandleScrollBar(ItemTextScrollFrameScrollBar)

	S:HandleNextPrevButton(ItemTextPrevPageButton)
	ItemTextPrevPageButton:Point("CENTER", ItemTextFrame, "TOPLEFT", 35, -41)

	S:HandleNextPrevButton(ItemTextNextPageButton)
	ItemTextNextPageButton:Point("CENTER", ItemTextFrame, "TOPRIGHT", -42, -41)

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