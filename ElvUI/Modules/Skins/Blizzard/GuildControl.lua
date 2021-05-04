local E, L, V, P, G = unpack(select(2, ...))
local S = E:GetModule("Skins")

local _G = _G
local unpack = unpack

local GuildControlGetNumRanks = GuildControlGetNumRanks
local GetNumGuildBankTabs = GetNumGuildBankTabs
local hooksecurefunc = hooksecurefunc

local function SkinGuildRanks()
	for i = 1, GuildControlGetNumRanks() do
		local frame = _G["GuildControlUIRankOrderFrameRank"..i]

		if frame and not frame.isSkinned then
			S:HandleNextPrevButton(frame.downButton)
			frame.downButton:Size(24)

			S:HandleNextPrevButton(frame.upButton)
			frame.upButton:Size(24)

			S:HandleButton(frame.deleteButton)
			frame.deleteButton:Size(24)

			frame.deleteButton.icon:SetTexture(E.Media.Textures.Close)
			frame.deleteButton.icon:SetTexCoord(0, 1, 0, 1)

			S:HandleEditBox(frame.nameBox)
			frame.nameBox.backdrop:ClearAllPoints()
			frame.nameBox.backdrop:Point("TOPLEFT", -2, -4)
			frame.nameBox.backdrop:Point("BOTTOMRIGHT", -4, 4)

			frame.isSkinned = true
		end
	end
end

local function LoadSkin()
	if not E.private.skins.blizzard.enable or not E.private.skins.blizzard.guildcontrol then return end

	GuildControlUI:StripTextures()
	GuildControlUI:SetTemplate("Transparent")
	GuildControlUI:Point("TOPLEFT", GuildFrame, "TOPRIGHT", 1, 0)

	GuildControlUIHbar:StripTextures()

	S:HandleDropDownBox(GuildControlUINavigationDropDown, 210)

	S:HandleCloseButton(GuildControlUICloseButton)
	GuildControlUICloseButton:Point("TOPRIGHT", 4, 6)

	-- Rank Tab
	GuildControlUIRankOrderFrame:CreateBackdrop("Transparent")

	hooksecurefunc("GuildControlUI_RankOrder_Update", SkinGuildRanks)

	S:HandleButton(GuildControlUIRankOrderFrameNewButton)
	GuildControlUIRankOrderFrameNewButton:HookScript("OnClick", function() E:Delay(0.6, SkinGuildRanks) end)

	-- Permissions Tab
	GuildControlUIRankSettingsFrame:CreateBackdrop("Transparent")

	S:HandleDropDownBox(GuildControlUIRankSettingsFrameRankDropDown, 195)

	for i = 1, NUM_RANK_FLAGS do
		local checkBox = _G["GuildControlUIRankSettingsFrameCheckbox"..i]
		if checkBox then S:HandleCheckBox(checkBox) end
	end

	GuildControlUIRankSettingsFrameGoldBox:StripTextures()
	S:HandleEditBox(GuildControlUIRankSettingsFrameGoldBox)
	GuildControlUIRankSettingsFrameGoldBox.backdrop:Point("TOPLEFT", -2, -4)
	GuildControlUIRankSettingsFrameGoldBox.backdrop:Point("BOTTOMRIGHT", 2, 4)

	-- Bank Tab
	GuildControlUIRankBankFrame:CreateBackdrop("Transparent")
	GuildControlUIRankBankFrameInset:StripTextures()

	S:HandleDropDownBox(GuildControlUIRankBankFrameRankDropDown)
	GuildControlUIRankBankFrameRankDropDown:Point("TOPLEFT", 86, -10)

	GuildControlUIRankBankFrameInsetScrollFrame:StripTextures()
	GuildControlUIRankBankFrameInsetScrollFrame:CreateBackdrop("Transparent")

	S:HandleScrollBar(GuildControlUIRankBankFrameInsetScrollFrameScrollBar)
	GuildControlUIRankBankFrameInsetScrollFrameScrollBar:ClearAllPoints()
	GuildControlUIRankBankFrameInsetScrollFrameScrollBar:Point("TOPRIGHT", GuildControlUIRankBankFrameInsetScrollFrame, 24, E.PixelMode and -17 or -16)
	GuildControlUIRankBankFrameInsetScrollFrameScrollBar:Point("BOTTOMRIGHT", GuildControlUIRankBankFrameInsetScrollFrame, 0, E.PixelMode and 17 or 16)

	hooksecurefunc("GuildControlUI_BankTabPermissions_Update", function()
		local numTabs = GetNumGuildBankTabs()
		if numTabs < MAX_BUY_GUILDBANK_TABS then numTabs = numTabs + 1 end

		for i = 1, numTabs do
			local tab = _G["GuildControlBankTab"..i]

			if not tab.isSkinned then
				tab:StripTextures()

				tab.owned:CreateBackdrop()
				tab.owned.backdrop:SetOutside(tab.owned.tabIcon)

				tab.owned.tabIcon:SetTexCoord(unpack(E.TexCoords))
				tab.owned.tabIcon:SetParent(tab.owned.backdrop)

				S:HandleCheckBox(tab.owned.viewCB, true)
				tab.owned.viewCB:Size(14)
				tab.owned.viewCB:Point("TOPRIGHT", -90, -3)

				S:HandleCheckBox(tab.owned.depositCB, true)
				tab.owned.depositCB:Size(14)

				S:HandleCheckBox(tab.owned.infoCB, true)
				tab.owned.infoCB:Size(14)

				local editBoxName = tab.owned.editBox:GetName()
				_G[editBoxName.."Left"]:Kill()
				_G[editBoxName.."Middle"]:Kill()
				_G[editBoxName.."Right"]:Kill()
				tab.owned.editBox:SetTemplate()
				tab.owned.editBox:Height(18)

				S:HandleButton(tab.buy)

				tab.isSkinned = true
			end
		end
	end)
end

S:AddCallbackForAddon("Blizzard_GuildControlUI", "GuildControl", LoadSkin)