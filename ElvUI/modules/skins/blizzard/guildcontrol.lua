local E, L, V, P, G = unpack(select(2, ...));
local S = E:GetModule("Skins")

local _G = _G
local unpack = unpack

local GuildControlGetNumRanks = GuildControlGetNumRanks
local MAX_BUY_GUILDBANK_TABS = MAX_BUY_GUILDBANK_TABS

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.guildcontrol ~= true then return end

	GuildControlUI:StripTextures()
	GuildControlUI:SetTemplate("Transparent")

	GuildControlUIRankBankFrameInset:StripTextures()
	GuildControlUIRankBankFrameInset:SetTemplate("Transparent", true)

	GuildControlUIRankBankFrameInsetScrollFrame:StripTextures()
	S:HandleScrollBar(GuildControlUIRankBankFrameInsetScrollFrameScrollBar);

	GuildControlUIHbar:StripTextures()

	local function SkinGuildRanks()
		for i = 1, GuildControlGetNumRanks() do
			local rankFrame = _G["GuildControlUIRankOrderFrameRank"..i]
			if(rankFrame) then
				S:HandleButton(rankFrame.downButton)
				S:HandleButton(rankFrame.upButton)
				S:HandleButton(rankFrame.deleteButton)

				if(not rankFrame.nameBox.backdrop) then
					S:HandleEditBox(rankFrame.nameBox)
				end

				rankFrame.nameBox.backdrop:Point("TOPLEFT", -2, -4)
				rankFrame.nameBox.backdrop:Point("BOTTOMRIGHT", -4, 4)
			end
		end
	end
	hooksecurefunc("GuildControlUI_RankOrder_Update", SkinGuildRanks)

	GuildControlUIRankOrderFrameNewButton:HookScript("OnClick", function()
		E.Delay(1, SkinGuildRanks)
	end)

	S:HandleDropDownBox(GuildControlUINavigationDropDown)
	S:HandleDropDownBox(GuildControlUIRankSettingsFrameRankDropDown, 180)

	GuildControlUINavigationDropDownButton:Width(20)
	GuildControlUIRankSettingsFrameRankDropDownButton:Width(20)

	for i = 1, NUM_RANK_FLAGS do
		if(_G["GuildControlUIRankSettingsFrameCheckbox"..i]) then
			S:HandleCheckBox(_G["GuildControlUIRankSettingsFrameCheckbox"..i])
		end
	end

	S:HandleButton(GuildControlUIRankOrderFrameNewButton)

	S:HandleEditBox(GuildControlUIRankSettingsFrameGoldBox)
	GuildControlUIRankSettingsFrameGoldBox.backdrop:Point("TOPLEFT", -2, -4)
	GuildControlUIRankSettingsFrameGoldBox.backdrop:Point("BOTTOMRIGHT", 2, 4)
	GuildControlUIRankSettingsFrameGoldBox:StripTextures()

	local function fixSkin(frame)
		frame.backdrop:Hide();
		if(not E.PixelMode) then
			frame.bg1 = frame:CreateTexture(nil, "BACKGROUND")
			frame.bg1:SetDrawLayer("BACKGROUND", 4)
			frame.bg1:SetTexture(E["media"].normTex)
			E:RegisterStatusBar(frame.bg1)
			frame.bg1:SetVertexColor(unpack(E["media"].backdropcolor))
			frame.bg1:Point("TOPLEFT", frame.backdrop, "TOPLEFT", E.mult*4, -E.mult*4)
			frame.bg1:Point("BOTTOMRIGHT", frame.backdrop, "BOTTOMRIGHT", -E.mult*4, E.mult*4)

			frame.bg2 = frame:CreateTexture(nil, "BACKGROUND")
			frame.bg2:SetDrawLayer("BACKGROUND", 3)
			frame.bg2:SetTexture(0, 0, 0)
			frame.bg2:Point("TOPLEFT", frame.backdrop, "TOPLEFT", E.mult*3, -E.mult*3)
			frame.bg2:Point("BOTTOMRIGHT", frame.backdrop, "BOTTOMRIGHT", -E.mult*3, E.mult*3)

			frame.bg3 = frame:CreateTexture(nil, "BACKGROUND")
			frame.bg3:SetDrawLayer("BACKGROUND", 2)
			frame.bg3:SetTexture(unpack(E["media"].bordercolor))
			frame.bg3:Point("TOPLEFT", frame.backdrop, "TOPLEFT", E.mult*2, -E.mult*2)
			frame.bg3:Point("BOTTOMRIGHT", frame.backdrop, "BOTTOMRIGHT", -E.mult*2, E.mult*2)

			frame.bg4 = frame:CreateTexture(nil, "BACKGROUND")
			frame.bg4:SetDrawLayer("BACKGROUND", 1)
			frame.bg4:SetTexture(0 ,0 ,0)
			frame.bg4:Point("TOPLEFT", frame.backdrop, "TOPLEFT", E.mult, -E.mult)
			frame.bg4:Point("BOTTOMRIGHT", frame.backdrop, "BOTTOMRIGHT", -E.mult, E.mult)
		else
			frame.bg1 = frame:CreateTexture(nil, "BACKGROUND")
			frame.bg1:SetDrawLayer("BACKGROUND", 4)
			frame.bg1:SetTexture(E["media"].normTex)
			E:RegisterStatusBar(frame.bg1)
			frame.bg1:SetVertexColor(unpack(E["media"].backdropcolor))
			frame.bg1:SetInside(frame.backdrop, E.mult)

			frame.bg3 = frame:CreateTexture(nil, "BACKGROUND")
			frame.bg3:SetDrawLayer("BACKGROUND", 2)
			frame.bg3:SetTexture(unpack(E["media"].bordercolor))
			frame.bg3:SetAllPoints(frame.backdrop)
		end
	end

	local once = false
	hooksecurefunc("GuildControlUI_BankTabPermissions_Update", function()
		local numTabs = GetNumGuildBankTabs()
		if(numTabs < MAX_BUY_GUILDBANK_TABS) then
			numTabs = numTabs + 1
		end
		for i = 1, numTabs do
			local tab = _G["GuildControlBankTab"..i.."Owned"]
			local icon = tab.tabIcon
			local editbox = tab.editBox

			icon:SetTexCoord(unpack(E.TexCoords))

			if(once == false) then
				S:HandleButton(_G["GuildControlBankTab"..i.."BuyPurchaseButton"])
				S:HandleEditBox(_G["GuildControlBankTab"..i.."OwnedStackBox"])
				S:HandleCheckBox(_G["GuildControlBankTab"..i.."OwnedViewCheck"])
				S:HandleCheckBox(_G["GuildControlBankTab"..i.."OwnedDepositCheck"])
				S:HandleCheckBox(_G["GuildControlBankTab"..i.."OwnedUpdateInfoCheck"])

				fixSkin(_G["GuildControlBankTab"..i.."OwnedStackBox"])
				fixSkin(_G["GuildControlBankTab"..i.."OwnedViewCheck"])
				fixSkin(_G["GuildControlBankTab"..i.."OwnedDepositCheck"])
				fixSkin(_G["GuildControlBankTab"..i.."OwnedUpdateInfoCheck"])
			end
		end
		once = true
	end)

	S:HandleDropDownBox(GuildControlUIRankBankFrameRankDropDown, 180)
	GuildControlUIRankBankFrameRankDropDownButton:Width(20)

	S:HandleCloseButton(GuildControlUICloseButton)
	GuildControlUICloseButton:ClearAllPoints()
	GuildControlUICloseButton:SetPoint("TOPRIGHT", GuildControlUI, "TOPRIGHT", 2, 2)
end

S:AddCallbackForAddon("Blizzard_GuildControlUI", "GuildControl", LoadSkin);