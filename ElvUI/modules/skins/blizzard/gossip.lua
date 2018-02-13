local E, L, V, P, G = unpack(select(2, ...))
local S = E:GetModule("Skins")

local _G = _G
local select = select
local find, gsub = string.find, string.gsub

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.gossip ~= true then return end

	--Item Text Frame
	ItemTextFrame:StripTextures()
	ItemTextFrame:SetTemplate("Transparent")

	ItemTextScrollFrame:StripTextures()
	ItemTextFrameInset:Kill()

	ItemTextPageText:SetTextColor(1, 1, 1)
	ItemTextPageText.SetTextColor = E.noop

	S:HandleNextPrevButton(ItemTextPrevPageButton)
	ItemTextPrevPageButton:Point("CENTER", ItemTextFrame, "TOPLEFT", 35, -41)

	S:HandleNextPrevButton(ItemTextNextPageButton)
	ItemTextNextPageButton:Point("CENTER", ItemTextFrame, "TOPRIGHT", -42, -41)

	ItemTextCurrentPage:Point("TOP", 0, -35)

	S:HandleScrollBar(ItemTextScrollFrameScrollBar)

	S:HandleCloseButton(ItemTextFrameCloseButton)

	--Gossip Frame
	GossipFrame:StripTextures()
	GossipFrame:SetTemplate("Transparent")

	GossipFrameInset:Kill()
	GossipFramePortrait:Kill()

	GossipFrameGreetingPanel:StripTextures()
	GossipGreetingScrollFrame:StripTextures()

	GossipGreetingText:SetTextColor(1, 1, 1)

	GossipFrameGreetingGoodbyeButton:StripTextures()
	S:HandleButton(GossipFrameGreetingGoodbyeButton)

	S:HandleScrollBar(GossipGreetingScrollFrameScrollBar, 5)

	S:HandleCloseButton(GossipFrameCloseButton)
	GossipFrameCloseButton:Point("CENTER", GossipFrame, "TOPRIGHT", -44, -22)

	for i = 1, NUMGOSSIPBUTTONS do
		local obj = select(3, _G["GossipTitleButton"..i]:GetRegions())
		obj:SetTextColor(1, 1, 1)
	end

	hooksecurefunc("GossipFrameUpdate", function()
		for i = 1, NUMGOSSIPBUTTONS do
			local button = _G["GossipTitleButton"..i]

			if button:GetFontString() then
				if(button:GetFontString():GetText() and button:GetFontString():GetText():find("|cff000000")) then
					button:GetFontString():SetText(gsub(button:GetFontString():GetText(), "|cff000000", "|cffFFFF00"))
				end
			end
		end
	end)

	NPCFriendshipStatusBar:StripTextures()
	NPCFriendshipStatusBar:CreateBackdrop("Default")
	NPCFriendshipStatusBar:SetStatusBarTexture(E["media"].normTex)
	NPCFriendshipStatusBar:Point("TOPLEFT", 50, -41)
end

S:AddCallback("Gossip", LoadSkin)